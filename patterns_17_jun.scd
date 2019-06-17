Server


(
SynthDef(\mydelay, { arg in, delaytime=1.0, feedback=1.5;
	var input = In.ar(in);
	Out.ar(0, Pan2.ar(AllpassN.ar(input, 5.0, delaytime, feedback)));
}).add;
)

~delayBus = Bus.audio(s, 1);
~delayBus
~delay = Synth(\mydelay, [\in, ~delayBus]);
~delay.set(\delaytime, 0.1);
~delay.set(\feedback, 2.0);

(
SynthDef(\mysynth, { arg out, freq, attack=0.01, sustain=1, amp=1, pan, cutoff=20000;
    var env = EnvGen.kr(
		Env.perc(attack, sustain), 1,
		doneAction: Done.freeSelf);
	var sin = SinOsc.ar(freq, 1.0, amp * env);
	var saw = DPW4Saw.ar(freq, amp * env);
	var signal = LPF.ar(Select.ar(freq > 300, [sin, saw]), cutoff);

	Out.ar(0, Pan2.ar(signal, Lag.kr(pan, 0.1)));

	//signal = DPW4Saw.ar(freq, amp * env);
	Out.ar(~delayBus, signal);
	//Out.ar(0, Pan2.ar(signal, Lag.kr(pan, 0.1)));
}).add;

)

~delay.set(\delaytime, 10.0)
~delay.set(\feedback, 10.0)
(instrument: \mysynth, amp: 1, freq: 400).play

(

SynthDef(\mybass, { arg out, freq, attack=0.01, sustain=1, amp=1, pan, cutoff=20000, gate=1;
    var env = EnvGen.kr(
		Env.adsr(attack, 0.1, 1.0, sustain), gate,
		doneAction: Done.freeSelf);
	Out.ar(out, Pan2.ar(LPF.ar(DPW4Saw.ar(freq, 1.0, amp * env), cutoff), pan));
}).add;
)
s.freeAll
Env.adsr(0.1, 0.3, 1.0, 1.0).plot

(instrument: \mysynth, freq: 400, amp: 1).play;

TempoClock.default.tempo = 120/60
(
var seq = [400, 200, 300, 270];
var n_stutter = 14.0;
var bass_duration = 4.0;
Pdef(\melody1,
	Pbind(
		\instrument, \mysynth,
		\freq, Pstutter(n_stutter, Pseq(seq, inf)) * Prand([0.5, 1.0, 2.0, 1.5, 1.33333],inf) ,
		//\amp, 1,
		\amp, Pbjorklund(9, 16),
		\sustain, 0.1,
		\cutoff, Pwhite(10.0, 6000),
		\pan, Pwhite(-1.0, 1.0),
		\dur, bass_duration / n_stutter,
	);
).play;

Pdef(\bass1,
	Pbind(
		\instrument, \mybass,
		\freq, Pseq(seq*0.5, inf),
		\amp, 1,
		//\amp, Pbjorklund(16, 16),
		\sustain, 2.0,
		\attack, 0.1,
		\cutoff, 300,
		\dur, bass_duration
	);
).stop;
)



p = Pwhite(-1.0, 1.0).asStream

p.next(())









(
Ndef(\mynsynth, { arg freq=400, sustain=1, pan;
    var env = EnvGen.kr(
		Env.perc(0.01, sustain), 1,
		doneAction: Done.freeSelf);
    Pan2.ar(SinOsc.ar(freq, 0.5pi, env), pan);
}).play;
)

Ndef(\mynsynth).gui