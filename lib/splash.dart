import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/start.mp4')
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.setLooping(false);
        _controller.play();
        // Переход на экран логина через 5 секунд или по окончании видео
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration) {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          }
        });
      }).catchError((error) {
        print('Error initializing video: $error');
        // В случае ошибки видео переходим на логин через 2 секунды
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black, // Фон на случай, если видео не загрузится
        child: Center(
          child: _isInitialized
              ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
              : const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
}