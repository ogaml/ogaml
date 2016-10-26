Notes for OgamlAudio

There are some problems with OpenAL:
  - The number of audio sources existing at the same time is limited (to at least 16)
  - There is no way to raise a callback when a sound has finished playing

Hence, the user is supposed to reuse the sources, by explicitly calling destroy 
for example. Unfortunately, I feel like it does not really follow the 
philosophy of OGaml. Here is a possible solution, by providing two modules
AudioSource and AudioContext.

AudioSource:
  An AudioSource.t is a lightweight object that is not necessarily associated 
  to an OpenAL source. Hence, it is possible to create an AudioSource for
  every world entity that may emit a sound for example.
  We can then call [AudioSource.play (`Music m) ~position ~loop ...] to play
  a music from this source.
  An OpenAL source will only be associated to the AudioSource.t when we call play.
  Of course, if a source is already associated, then we do not have to 
  re-associate one. 
  We can even check if the position of the previously associated source is
  the same as the new position, to avoid redundant openAL calls.
  We can of course also call AudioSource.stop, AudioSource.pause and 
  AudioSource.resume.

AudioContext:
  We still need to pool the available OpenAL sources to associate them to
  an AudioSource.t. This is what the AudioContext is for.
  When creating an AudioSource.t, you have to pass an AudioContext.t that is
  created by initializing OpenAL (much like OgamlGraphics.Context).
  When playing a music/sound from a source, the AudioSource.t asks the AudioContext.t
  for an available OpenAL source S to associate.
  The AudioContext then marks S as being unavailable for the duration of the
  sound/music (or infinite if the sound is looped).
  Basically, we have a list of type (float * float * source), where 
  (start, dur, src) means that the source [src] is unavailable for [dur], starting
  at [start]. The list is sorted by increasing [start + dur].
  Hence, checking if a source is available is always constant time (if the first
  one is not available, none will be), and allocating a source is linear in the
  number of allocated sources (weighted insertion in a list), which should be reasonable.

Note that an AudioContext will probably also contain stuff related to the OpenAL
state, like the main listener, or the audio device. Or maybe AudioContext could be
renamed in AudioDevice to be coherent with OpenAL, IDK. :)
