import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import '../../cubits/game_cubit.dart';

class PairMatchScreen extends StatefulWidget {
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
    // Duplicate images for pairs
    final List<String> duplicatedImages = [...cardImages, ...cardImages];
    // Shuffle images
    duplicatedImages.shuffle(Random());
    // Create card models
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

      // Check for match
      if (cards[firstFlippedIndex!].imagePath == cards[secondFlippedIndex!].imagePath) {
        print('Match found!');
        setState(() {
          cards[firstFlippedIndex!] = cards[firstFlippedIndex!].copyWith(isMatched: true);
          cards[secondFlippedIndex!] = cards[secondFlippedIndex!].copyWith(isMatched: true);
        });
        _resetSelection();
        // Check if game is over
        if (cards.every((card) => card.isMatched)) {
          print('Game over! Awarding $coinsForCompletion coins');
          setState(() {
            isGameOver = true;
          });
          await context.read<GameCubit>().addCoins(coinsForCompletion);
        }
      } else {
        print('No match, flipping back');
        // Not a match, flip back after delay
        await Future.delayed(Duration(milliseconds: 1000));
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
        title: Text('Найти пары'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade300, Colors.purple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isGameOver
            ? Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Поздравляем!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Вы нашли все пары и заработали $coinsForCompletion неокоинов! 🎉',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    _restartGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade800,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text('Играть снова'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade800,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text('Вернуться'),
                ),
              ],
            ),
          ),
        )
            : Center(
          child: Padding(
            padding: EdgeInsets.only(top: 32), // Lift cards higher
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate card size based on screen width, leaving margin
                final maxWidth = constraints.maxWidth * 0.9; // 90% of screen width
                final maxHeight = (constraints.maxHeight - 32) * 0.65; // 65% of height
                final cardWidth = maxWidth / gridColumns;
                final cardHeight = maxHeight / gridRows;
                final cardSize = min(cardWidth, cardHeight); // Ensure square cards

                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: gridColumns * cardSize,
                    maxHeight: gridRows * cardSize,
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                          child: CardWidget(
                            card: cards[index],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
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

  CardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 1000),
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
            color: card.isFlipped ? Colors.white : Colors.purple.shade800,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: card.isFlipped
              ? Padding(
            padding: EdgeInsets.all(8), // Padding to fit image
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                card.imagePath,
                fit: BoxFit.contain, // Fit image without clipping
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image ${card.imagePath}: $error');
                  return Container(
                    color: Colors.red,
                    child: Center(
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
              : Center(
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