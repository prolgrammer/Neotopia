import 'package:flutter/material.dart';
import 'dart:math';

class CardModel {
  final String imagePath;
  final bool isFlipped;
  final bool isMatched;

  CardModel({
    required this.imagePath,
    this.isFlipped = false,
    this.isMatched = false,
  });

  CardModel copyWith({
    bool? isFlipped,
    bool? isMatched,
  }) {
    return CardModel(
      imagePath: imagePath,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}

class CardWidget extends StatelessWidget {
  final CardModel card;

  const CardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      child: card.isMatched
          ? Container()
          : Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(card.isFlipped ? 0 : pi),
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            color: card.isFlipped ? Colors.white : const Color(0xFF2E0352),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: card.isFlipped
              ? Padding(
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                card.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image ${card.imagePath}: $error');
                  return Container(
                    color: Colors.red,
                    child: const Center(
                      child: Text(
                        'X',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
              : const Center(
            child: Icon(
              Icons.star,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }
}