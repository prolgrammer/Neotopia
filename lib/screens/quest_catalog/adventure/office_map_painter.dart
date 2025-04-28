import 'package:flutter/material.dart';

class OfficeMapPainter extends CustomPainter {
  final List<List<dynamic>> officeMap;

  OfficeMapPainter(this.officeMap);

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 10;
    final floorPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF821464), const Color(0xFFD2005A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final wallPaint = Paint()
      ..color = const Color(0xFF5E0B4B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final textPaint = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int row = 0; row < 10; row++) {
      for (int col = 0; col < 10; col++) {
        final rect = Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize);
        if (officeMap[row][col] != 1) {
          canvas.drawRect(rect, floorPaint);
          if (officeMap[row][col] == 0 || officeMap[row][col] == 'E') {
            canvas.drawCircle(
              Offset(col * cellSize + cellSize / 2, row * cellSize + cellSize / 2),
              cellSize / 10,
              Paint()
                ..color = Colors.white.withOpacity(0.3)
                ..style = PaintingStyle.fill,
            );
          }
        }
      }
    }

    for (int row = 0; row < 10; row++) {
      for (int col = 0; col < 10; col++) {
        if (officeMap[row][col] == 1) {
          // Тени стен (оставляем только для внутренних стен)
          if (col < 9 && officeMap[row][col + 1] != 1) {
            canvas.drawLine(
              Offset((col + 1) * cellSize + 2, row * cellSize),
              Offset((col + 1) * cellSize + 2, (row + 1) * cellSize),
              shadowPaint,
            );
          }
          if (row < 9 && officeMap[row + 1][col] != 1) {
            canvas.drawLine(
              Offset(col * cellSize, (row + 1) * cellSize + 2),
              Offset((col + 1) * cellSize, (row + 1) * cellSize + 2),
              shadowPaint,
            );
          }

          // Основные стенки (убираем граничные)
          if (col < 9 && officeMap[row][col + 1] != 1) {
            canvas.drawLine(
              Offset((col + 1) * cellSize, row * cellSize),
              Offset((col + 1) * cellSize, (row + 1) * cellSize),
              wallPaint,
            );
          }
          if (row < 9 && officeMap[row + 1][col] != 1) {
            canvas.drawLine(
              Offset(col * cellSize, (row + 1) * cellSize),
              Offset((col + 1) * cellSize, (row + 1) * cellSize),
              wallPaint,
            );
          }
          // Убираем автоматическое рисование левой стенки (col == 0)
          if (col > 0 && officeMap[row][col - 1] != 1) {  // ← Только если не левый край
            canvas.drawLine(
              Offset(col * cellSize, row * cellSize),
              Offset(col * cellSize, (row + 1) * cellSize),
              wallPaint,
            );
          }
          // Убираем автоматическое рисование верхней стенки (row == 0)
          if (row > 0 && officeMap[row - 1][col] != 1) {  // ← Только если не верхний край
            canvas.drawLine(
              Offset(col * cellSize, row * cellSize),
              Offset((col + 1) * cellSize, row * cellSize),
              wallPaint,
            );
          }
        }
      }
    }

    for (int row = 0; row < 10; row++) {
      for (int col = 0; col < 10; col++) {
        if (officeMap[row][col] == 'E') {
          canvas.drawRect(
            Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize),
            Paint()
              ..color = const Color(0xFF4A1A7A)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3,
          );
          textPaint.text = const TextSpan(
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          );
          textPaint.layout();
          textPaint.paint(canvas, Offset(col * cellSize + 10, row * cellSize + cellSize));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}