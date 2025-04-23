import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import '../../../cubits/game_cubit.dart';
import '../../constants.dart';
import 'pair_match_result.dart';

class PairMatchScreen extends StatefulWidget {
  const PairMatchScreen({super.key});

  @override
  _PairMatchScreenState createState() => _PairMatchScreenState();
}

class _PairMatchScreenState extends State<PairMatchScreen> with TickerProviderStateMixin {
  static const int gridRows = 4;
  static const int gridColumns = 3;
  static const int totalPairs = 6;
  static const int coinsForCompletion = 50;

  List<String> cardImages = [
    'assets/images/pairs/card1.png',
    'assets/images/pairs/card2.png',
    'assets/images/pairs/card3.png',
    'assets/images/pairs/card4.png',
    'assets/images/pairs/card5.png',
    'assets/images/pairs/card6.png',
  ];

  List<CardModel> cards = [];
  int? firstFlippedIndex;
  int? secondFlippedIndex;
  bool isProcessing = false;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    print('Initializing game with $gridRows rows and $gridColumns columns');
    cards.clear();
    final List<String> duplicatedImages = [...cardImages, ...cardImages];
    duplicatedImages.shuffle(Random());
    for (int i = 0; i < gridRows * gridColumns; i++) {
      cards.add(CardModel(
        imagePath: duplicatedImages[i],
        isFlipped: false,
        isMatched: false,
      ));
    }
    print('Cards initialized: ${cards.map((c) => c.imagePath).toList()}');
    setState(() {});
  }

  void _onCardTapped(int index) async {
    print('Tapped card $index: isProcessing=$isProcessing, isFlipped=${cards[index].isFlipped}, isMatched=${cards[index].isMatched}, isGameOver=$isGameOver');
    if (isProcessing || isGameOver || cards[index].isFlipped || cards[index].isMatched) {
      print('Tap ignored due to conditions');
      return;
    }

    setState(() {
      cards[index] = cards[index].copyWith(isFlipped: true);
      print('Card $index flipped');
    });

    if (firstFlippedIndex == null) {
      firstFlippedIndex = index;
      print('First card flipped: $index');
    } else if (secondFlippedIndex == null) {
      secondFlippedIndex = index;
      isProcessing = true;
      print('Second card flipped: $index');

      if (cards[firstFlippedIndex!].imagePath == cards[secondFlippedIndex!].imagePath) {
        print('Match found!');
        setState(() {
          cards[firstFlippedIndex!] = cards[firstFlippedIndex!].copyWith(isMatched: true);
          cards[secondFlippedIndex!] = cards[secondFlippedIndex!].copyWith(isMatched: true);
        });
        _resetSelection();
        if (cards.every((card) => card.isMatched)) {
          print('Game over! Awarding $coinsForCompletion coins');
          setState(() {
            isGameOver = true;
          });
          await context.read<GameCubit>().addCoins(coinsForCompletion);
        }
      } else {
        print('No match, flipping back');
        await Future.delayed(const Duration(milliseconds: 1000));
        setState(() {
          cards[firstFlippedIndex!] = cards[firstFlippedIndex!].copyWith(isFlipped: false);
          cards[secondFlippedIndex!] = cards[secondFlippedIndex!].copyWith(isFlipped: false);
        });
        _resetSelection();
      }
    }
  }

  void _resetSelection() {
    firstFlippedIndex = null;
    secondFlippedIndex = null;
    isProcessing = false;
    print('Selection reset');
  }

  void _restartGame() {
    setState(() {
      isGameOver = false;
      firstFlippedIndex = null;
      secondFlippedIndex = null;
      isProcessing = false;
      _initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Найди пары'),
        backgroundColor: const Color(0xFF2E0352),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kAppGradient),
        child: isGameOver
            ? PairMatchResult(
          coinsEarned: coinsForCompletion,
          onRestart: _restartGame,
          onBack: () => Navigator.pop(context),
        )
            : Center(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 54),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth * 0.9;
                  final maxHeight = (constraints.maxHeight - 54) * 0.65;
                  final cardWidth = maxWidth / gridColumns;
                  final cardHeight = maxHeight / gridRows;
                  final cardSize = min(cardWidth, cardHeight);

                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: gridColumns * cardSize,
                      maxHeight: gridRows * cardSize,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridColumns,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: gridRows * gridColumns,
                        itemBuilder: (context, index) {
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                print('InkWell tapped for card $index');
                                _onCardTapped(index);
                              },
                              child: CardWidget(card: cards[index]),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
            borderRadius: card.isFlipped ? BorderRadius.circular(4) : BorderRadius.zero,
            border: Border.all(
              color: const Color(0xFF4A1A7A),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: card.isFlipped
              ? Image.asset(
            card.imagePath,
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
          )
              : const Center(
            child: Icon(
              Icons.lightbulb,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }
}