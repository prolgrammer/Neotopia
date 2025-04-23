import 'package:flutter/material.dart';

class MazePainter extends CustomPainter {
  final List<List<dynamic>> maze;
  final List<int> playerPosition;

  MazePainter(this.maze, this.playerPosition);

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 10;
    final wallPaint = Paint()
      ..color = const Color(0xFF4A1A7A)
      ..style = PaintingStyle.fill;
    final pathPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFFDE683C), const Color(0xFF2E0352)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final playerPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;
    final startPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final exitPaint = Paint()
      ..color = Colors.green.shade700
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (int row = 0; row < 10; row++) {
      for (int col = 0; col < 10; col++) {
        final rect = Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize);
        if (maze[row][col] == 1) {
          canvas.drawRect(rect.shift(const Offset(2, 2)), shadowPaint);
          canvas.drawRect(rect, wallPaint);
        } else if (maze[row][col] == 'E') {
          canvas.drawRect(rect, exitPaint);
        } else if (maze[row][col] == 'S') {
          canvas.drawRect(rect, startPaint);
        } else {
          canvas.drawRect(rect, pathPaint);
        }
      }
    }

    canvas.drawCircle(
      Offset(
        playerPosition[1] * cellSize + cellSize / 2,
        playerPosition[0] * cellSize + cellSize / 2,
      ),
      cellSize / 3,
      playerPaint,
    );
    canvas.drawCircle(
      Offset(
        playerPosition[1] * cellSize + cellSize / 2,
        playerPosition[0] * cellSize + cellSize / 2,
      ),
      cellSize / 2.5,
      Paint()
        ..color = Colors.amber.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}