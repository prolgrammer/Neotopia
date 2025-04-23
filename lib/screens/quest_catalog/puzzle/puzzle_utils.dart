import 'package:flutter/material.dart';

const int gridRows = 3;
const int gridColumns = 3;
const int totalPieces = 9;
const int coinsForCompletion = 50;
const double imageAspectRatio = 333 / 188;

const List<String> pieceImages = [
  'assets/images/puzzle/piece_0.png',
  'assets/images/puzzle/piece_1.png',
  'assets/images/puzzle/piece_2.png',
  'assets/images/puzzle/piece_3.png',
  'assets/images/puzzle/piece_4.png',
  'assets/images/puzzle/piece_5.png',
  'assets/images/puzzle/piece_6.png',
  'assets/images/puzzle/piece_7.png',
  'assets/images/puzzle/piece_8.png',
];

BorderRadius getBorderRadius(int index) {
  final row = index ~/ gridColumns;
  final col = index % gridColumns;
  if (row == 0 && col == 0) {
    return const BorderRadius.only(topLeft: Radius.circular(16));
  } else if (row == 0 && col == gridColumns - 1) {
    return const BorderRadius.only(topRight: Radius.circular(16));
  } else if (row == gridRows - 1 && col == 0) {
    return const BorderRadius.only(bottomLeft: Radius.circular(16));
  } else if (row == gridRows - 1 && col == gridColumns - 1) {
    return const BorderRadius.only(bottomRight: Radius.circular(16));
  }
  return BorderRadius.zero;
}