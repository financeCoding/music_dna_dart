/**
 * Copyright 2014 Google Inc. All Rights Reserved.
 * For licensing see http://lab.aerotwist.com/canvas/music-dna/LICENSE
 */

part of audio;

class AudioParser {

  AudioContext audioContext;
  AnalyserNode analyser;
  GainNode gainNode;
  AudioBufferSourceNode sourceNode;
  int timePlaybackStarted = 0;

  AudioParser(int dataSize) {
    audioContext = new AudioContext();
    analyser = audioContext.createAnalyser();
    gainNode = audioContext.createGain();
    analyser.smoothingTimeConstant = 0.2;
    analyser.fftSize = dataSize;
    gainNode.gain.value = 0.5;
  }

  AudioBuffer onDecodeData(AudioBuffer buffer) {

    // Kill any existing audio
    if (sourceNode != null) {
      if (sourceNode.playbackState == AudioBufferSourceNode.PLAYING_STATE)
        sourceNode.stop();

      sourceNode = null;
    }

    // Make a new source
    if (sourceNode == null) {
      sourceNode = audioContext.createBufferSource();
      sourceNode.loop = false;

      sourceNode.connectNode(gainNode);
      gainNode.connectNode(analyser);
      analyser.connectNode(audioContext.destination);
    }

    // Set it up and play it
    sourceNode
      ..buffer = buffer
      ..start(0);

    timePlaybackStarted = new DateTime.now().millisecondsSinceEpoch;

    // we do this to make the future chain easier in parseArrayBuffer
    return buffer;
  }

  void getAnalyserAudioData(Uint8List arrayBuffer) {
    analyser.getByteFrequencyData(arrayBuffer);
  }

  // See https://code.google.com/p/dart/issues/detail?id=17956
  Future<AudioBuffer> parseArrayBuffer(TypedData arrayBuffer) {
    return audioContext.decodeAudioData(arrayBuffer.buffer).then(onDecodeData);
  }

  double get time {
    return (new DateTime.now().millisecondsSinceEpoch - timePlaybackStarted) * 0.001;
  }

}