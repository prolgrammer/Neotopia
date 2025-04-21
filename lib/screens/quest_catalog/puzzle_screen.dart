import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import '../../cubits/game_cubit.dart';

class PuzzleScreen extends StatefulWidget {
  @override
  _PuzzleScreenState createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> with TickerProviderStateMixin {
  static const int gridRows = 3;
  static const int gridColumns = 3;
  static const int totalPieces = 9;
  static const int coinsForCompletion = 50;
  static const double imageAspectRatio = 333 / 188; // Aspect ratio of 333x188 images

  List<String> pieceImages = List.generate(
    totalPieces,
        (index) => 'assets/images/puzzle/piece_$index.png',
  );

  List<PuzzlePiece> pieces = [];
  List<PuzzlePiece?> grid = List.filled(totalPieces, null);
  bool isGameOver = false;
  bool showFullImage = false;
  bool showPreview = true;
  late AnimationController _previewController;
  late Animation<double> _previewFade;
  Map<int, AnimationController> _highlightControllers = {};
  Map<int, Animation<double>> _highlightAnimations = {};

  @override
  void initState() {
    super.initState();
    // Initialize preview animation
    _previewController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _previewFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _previewController, curve: Curves.easeInOut),
    );
    // Initialize highlight animations for all slots
    for (int i = 0; i < totalPieces; i++) {
      _highlightControllers[i] = AnimationController(
        duration: Duration(milliseconds: 500),
        vsync: this,
      );
      _highlightAnimations[i] = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _highlightControllers[i]!, curve: Curves.easeInOut),
      );
    }
    // Start preview timer
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showPreview = false;
        });
        _previewController.forward().then((_) {
          _initializeGame();
        });
      }
    });
  }

  void _initializeGame() {
    print('Initializing puzzle game');
    pieces.clear();
    grid = List.filled(totalPieces, null);
    // Create pieces
    for (int i = 0; i < totalPieces; i++) {
      pieces.add(PuzzlePiece(
        imagePath: pieceImages[i],
        correctIndex: i,
      ));
    }
    // Shuffle pieces
    pieces.shuffle(Random());
    print('Pieces shuffled: ${pieces.map((p) => p.imagePath).toList()}');
    setState(() {});
  }

  void _onPieceDropped(int gridIndex, PuzzlePiece piece, {bool fromGrid = false}) {
    print('Dropped piece ${piece.imagePath} at gridIndex=$gridIndex, fromGrid=$fromGrid');
    setState(() {
      // If dropping from the pieces list
      if (!fromGrid) {
        pieces.remove(piece);
      }
      // If the grid slot is occupied, move the existing piece back to pieces
      if (grid[gridIndex] != null) {
        pieces.add(grid[gridIndex]!);
      }
      // Place the dropped piece in the grid
      grid[gridIndex] = piece;
      // Check if the piece is in the correct position
      if (piece.correctIndex == gridIndex) {
        print('Piece ${piece.imagePath} placed correctly at index $gridIndex');
        _highlightControllers[gridIndex]!.forward().then((_) {
          _highlightControllers[gridIndex]!.reset();
        });
      }
      // Check if the puzzle is complete
      _checkCompletion();
    });
  }

  void _checkCompletion() {
    bool isComplete = true;
    for (int i = 0; i < totalPieces; i++) {
      if (grid[i] == null || grid[i]!.correctIndex != i) {
        isComplete = false;
        break;
      }
    }
    if (isComplete) {
      print('Puzzle completed!');
      setState(() {
        isGameOver = true;
        showFullImage = true;
      });
      // Show full image for 2 seconds
      Future.delayed(Duration(seconds: 2), () async {
        if (mounted) {
          setState(() {
            showFullImage = false;
          });
          await context.read<GameCubit>().addCoins(coinsForCompletion);
        }
      });
    }
  }

  void _restartGame() {
    setState(() {
      isGameOver = false;
      showFullImage = false;
      showPreview = true;
      _previewController.reset();
      // Reset highlight animations
      _highlightControllers.forEach((index, controller) {
        controller.reset();
      });
      // Start preview timer again
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            showPreview = false;
          });
          _previewController.forward().then((_) {
            _initializeGame();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _previewController.dispose();
    _highlightControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Собери пазл Neoflex'),
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
        child: showPreview
            ? Center(
          child: FadeTransition(
            opacity: _previewFade,
            child: _buildFullImage(),
          ),
        )
            : isGameOver && !showFullImage
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
                  'Вы собрали пазл и заработали $coinsForCompletion неокоинов! 🎉',
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
            padding: EdgeInsets.only(top: 32),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth * 0.95;
                final maxHeight = (constraints.maxHeight - 32) * 0.75;
                final cardWidth = maxWidth / gridColumns;
                final cardHeight = maxHeight / gridRows;
                final cardSize = min(cardWidth, cardHeight * imageAspectRatio) / imageAspectRatio;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Puzzle Grid
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: gridColumns * cardSize * imageAspectRatio,
                        maxHeight: gridRows * cardSize,
                      ),
                      child: showFullImage
                          ? _buildFullImage()
                          : GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridColumns,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: imageAspectRatio,
                        ),
                        itemCount: totalPieces,
                        itemBuilder: (context, index) {
                          final piece = grid[index];
                          final isCorrect = piece != null && piece.correctIndex == index;
                          return AnimatedBuilder(
                            animation: _highlightControllers[index]!,
                            builder: (context, child) {
                              final highlightOpacity = _highlightAnimations[index]!.value;
                              return Container(
                                decoration: BoxDecoration(
                                  border: highlightOpacity > 0
                                      ? Border.all(
                                    color: Colors.yellow.withOpacity(highlightOpacity),
                                    width: 4,
                                  )
                                      : null,
                                ),
                                child: DragTarget<PuzzlePiece>(
                                  builder: (context, candidateData, rejectedData) {
                                    return piece != null
                                        ? Draggable<PuzzlePiece>(
                                      data: piece,
                                      feedback: Material(
                                        elevation: 8,
                                        borderRadius: _getBorderRadius(index),
                                        child: Container(
                                          width: cardSize * imageAspectRatio,
                                          height: cardSize,
                                          child: ClipRRect(
                                            borderRadius: _getBorderRadius(index),
                                            child: Image.asset(
                                              piece.imagePath,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                      childWhenDragging: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: _getBorderRadius(index),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.grey,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: _getBorderRadius(index),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: _getBorderRadius(index),
                                          child: Image.asset(
                                            piece.imagePath,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      onDragCompleted: () {
                                        print('Drag completed for piece ${piece.imagePath} from grid index $index');
                                        setState(() {
                                          grid[index] = null;
                                        });
                                      },
                                      // Disable dragging if correctly placed
                                      maxSimultaneousDrags: isCorrect ? 0 : 1,
                                    )
                                        : Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: _getBorderRadius(index),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.grey,
                                          size: 40,
                                        ),
                                      ),
                                    );
                                  },
                                  // Disable DragTarget if correctly placed
                                  onWillAccept: (_) => !isCorrect,
                                  onAccept: (droppedPiece) {
                                    _onPieceDropped(
                                      index,
                                      droppedPiece,
                                      fromGrid: grid.contains(droppedPiece),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    // Available Pieces
                    if (!showFullImage && pieces.isNotEmpty)
                      Container(
                        height: cardSize + 16,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: pieces.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Draggable<PuzzlePiece>(
                                data: pieces[index],
                                feedback: Material(
                                  elevation: 8,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: cardSize * imageAspectRatio,
                                    height: cardSize,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        pieces[index].imagePath,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                childWhenDragging: Container(
                                  width: cardSize * imageAspectRatio,
                                  height: cardSize,
                                  color: Colors.grey[200],
                                ),
                                child: Container(
                                  width: cardSize * imageAspectRatio,
                                  height: cardSize,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      pieces[index].imagePath,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullImage() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridColumns,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
        childAspectRatio: imageAspectRatio,
      ),
      itemCount: totalPieces,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: _getBorderRadius(index),
          child: Image.asset(
            pieceImages[index],
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading image ${pieceImages[index]}: $error');
              return Container(
                color: Colors.red,
                child: Center(child: Text('X', style: TextStyle(color: Colors.white))),
              );
            },
          ),
        );
      },
    );
  }

  BorderRadius _getBorderRadius(int index) {
    final row = index ~/ gridColumns;
    final col = index % gridColumns;
    if (row == 0 && col == 0) {
      return BorderRadius.only(topLeft: Radius.circular(16));
    } else if (row == 0 && col == gridColumns - 1) {
      return BorderRadius.only(topRight: Radius.circular(16));
    } else if (row == gridRows - 1 && col == 0) {
      return BorderRadius.only(bottomLeft: Radius.circular(16));
    } else if (row == gridRows - 1 && col == gridColumns - 1) {
      return BorderRadius.only(bottomRight: Radius.circular(16));
    }
    return BorderRadius.zero;
  }
}

class PuzzlePiece {
  final String imagePath;
  final int correctIndex;

  PuzzlePiece({
    required this.imagePath,
    required this.correctIndex,
  });
}