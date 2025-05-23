import 'package:flutter/material.dart';

class MainCard extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback? onTap;
  final Widget? child;

  MainCard({
    required this.title,
    required this.icon,
    this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipPath(
        clipper: CardClipper(),
        child: Container(
          height: child != null ? null : 120,
          padding: child != null ? EdgeInsets.all(16) : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: child ??
              Row(
                children: [
                  Container(
                    width: 80,
                    color: Colors.purple.shade100,
                    child: Center(
                      child: Text(
                        icon,
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

class CardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = 20.0;

    path.moveTo(radius, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}