import 'package:flutter/material.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;
  final String tag;

  ImagePreviewScreen({required this.imageUrl, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Hero(
          tag: tag,
          child: Image.asset(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.error,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}