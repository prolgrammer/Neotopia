import 'package:flutter/material.dart';
import 'puzzle_piece.dart';
import 'puzzle_utils.dart';

class PuzzleGameWidget extends StatelessWidget {
  final List<PuzzlePiece> pieces;
  final List<PuzzlePiece?> grid;
  final bool showFullImage;
  final bool isGameOver;
  final Map<int, AnimationController> highlightControllers;
  final Map<int, Animation<double>> highlightAnimations;
  final Function(int, PuzzlePiece, {bool fromGrid}) onPieceDropped;

  const PuzzleGameWidget({
    super.key,
    required this.pieces,
    required this.grid,
    required this.showFullImage,
    required this.isGameOver,
    required this.highlightControllers,
    required this.highlightAnimations,
    required this.onPieceDropped,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 74),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth * 0.95;
              final maxHeight = (constraints.maxHeight - 74) * 0.75;
              final cardWidth = maxWidth / gridColumns;
              final cardHeight = maxHeight / gridRows;
              final cardSize = cardWidth / imageAspectRatio;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: gridColumns * cardSize * imageAspectRatio,
                      maxHeight: gridRows * cardSize + 16,
                    ),
                    child: showFullImage
                        ? buildFullImage()
                        : Padding(
                      padding: const EdgeInsets.all(8),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                            animation: highlightControllers[index]!,
                            builder: (context, child) {
                              final highlightOpacity = highlightAnimations[index]!.value;
                              return Container(
                                decoration: BoxDecoration(
                                  border: highlightOpacity > 0
                                      ? Border.all(
                                    color: Colors.amber.withOpacity(highlightOpacity),
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
                                        borderRadius: getBorderRadius(index),
                                        child: Container(
                                          width: cardSize * imageAspectRatio,
                                          height: cardSize,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color(0xFF4A1A7A),
                                              width: 1,
                                            ),
                                            borderRadius: getBorderRadius(index),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: getBorderRadius(index),
                                            child: Image.asset(
                                              piece.imagePath,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                      ),
                                      childWhenDragging: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: getBorderRadius(index),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: const Color(0xFF4A1A7A),
                                            width: 1,
                                          ),
                                        ),
                                        child: const Center(
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
                                          borderRadius: getBorderRadius(index),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: const Color(0xFF4A1A7A),
                                            width: 1,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: getBorderRadius(index),
                                          child: Image.asset(
                                            piece.imagePath,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      onDragCompleted: () {
                                        print('Drag completed for piece ${piece.imagePath} from grid index $index');
                                        grid[index] = null;
                                      },
                                      maxSimultaneousDrags: isCorrect ? 0 : 1,
                                    )
                                        : Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: getBorderRadius(index),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: const Color(0xFF4A1A7A),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.grey,
                                          size: 40,
                                        ),
                                      ),
                                    );
                                  },
                                  onWillAccept: (_) => !isCorrect,
                                  onAccept: (droppedPiece) {
                                    onPieceDropped(
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
                  ),
                  const SizedBox(height: 16),
                  if (!showFullImage && pieces.isNotEmpty)
                    Container(
                      height: cardSize + 8,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: pieces.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Draggable<PuzzlePiece>(
                              data: pieces[index],
                              feedback: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.zero,
                                child: Container(
                                  width: cardSize * imageAspectRatio,
                                  height: cardSize,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF4A1A7A),
                                      width: 1,
                                    ),
                                  ),
                                  child: Image.asset(
                                    pieces[index].imagePath,
                                    fit: BoxFit.fill,
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
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: const Color(0xFF4A1A7A),
                                    width: 1,
                                  ),
                                ),
                                child: Image.asset(
                                  pieces[index].imagePath,
                                  fit: BoxFit.fill,
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
    );
  }

  static Widget buildFullImage() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridColumns,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
        childAspectRatio: imageAspectRatio,
      ),
      itemCount: totalPieces,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: getBorderRadius(index),
          child: Image.asset(
            pieceImages[index],
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading image ${pieceImages[index]}: $error');
              return Container(
                color: Colors.red,
                child: const Center(child: Text('X', style: TextStyle(color: Colors.white))),
              );
            },
          ),
        );
      },
    );
  }
}