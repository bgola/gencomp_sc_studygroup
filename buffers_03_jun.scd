// Reads an MP3 or OGG file to buffer (needs MP3 quark and lame/vorbis-tools)
~buffer1 = MP3.readToBuffer(s, "/home/bgola/Downloads/tamborzao_160.mp3");

// Reads a WAV file to buffer.
~buffer2 = Buffer.read(s, "/home/bgola/Downloads/tamborzao_160.wav");


~buffer1.free
~buffer2.free

// Listen to buffer
~buffer1.play

// See the buffer data
~buffer1.plot

// Duration in seconds of the sound file
~buffer1.duration

(
Ndef(\playBuffer, { |rate=1, trigger_speed=1| //, slices=100|
	var slices = 10;
	var slice_dur=(~buffer1.duration / slices);
	var trigger = Impulse.kr(trigger_speed);

	PlayBuf.ar(
		~buffer1.numChannels,  // Channels
		~buffer1,  // Buffer
		rate, // rate (speed of playing the sample)
		trigger: trigger,
		startPos: 0,
		loop: 1
	);
}).play;
)


Ndef(\playBuffer).set(\rate, 1);
Ndef(\playBuffer).gui
Ndef(\playBuffer).scope


(
Ndef(\sliceBuffer, { |rate=1|
	var slices = 10;
	var slice_dur=(~buffer1.duration / slices);
	var trigger = Impulse.kr(1 / (slice_dur/rate));
	// Generates a list of index slices from 0 to the number of slices (like: [0, 1, 2, ...] and scramble/random this list
	var possible_slices = (0..slices-1).scramble;
	// Creates a sequence out of the scrambled list and go over it one by one
	var slice_number = Demand.kr(
		trigger,
		0,
		Dseq(possible_slices, 1) // Change the 1 to 2, 3... or inf to play for 2, 3 times or forever
	);

	// Makes the sound stop after playing all slices
	Line.ar(0, 1,
		~buffer1.duration/rate,
		doneAction: Done.freeSelf
	);

	PlayBuf.ar(
		2,  // Channels
		~buffer1,  // Buffer
		// rate (speed of playback)
		rate * (~buffer1.sampleRate / s.sampleRate),
		trigger: trigger,
		startPos: ((~buffer1.sampleRate * slice_dur) * slice_number),
		loop: 0
	);
}).play;
)

Ndef(\sliceBuffer).set(\rate, 1);
Ndef(\sliceBuffer).gui
Ndef(\sliceBuffer).scope

