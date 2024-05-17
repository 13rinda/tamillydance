import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  var videoPath = "";
  VideoPlayerScreen(String videoPath1) {
    this.videoPath = videoPath1;
  }

  @override
  _VideoPlayerState createState() => _VideoPlayerState(videoPath);
}

class _VideoPlayerState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  var videoPath = "";
  _VideoPlayerState(String videoPath1) {
    this.videoPath = videoPath1;
  }

  @override
  void initState() {
    _controller = VideoPlayerController.network(videoPath)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
