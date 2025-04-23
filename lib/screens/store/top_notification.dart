import 'package:flutter/material.dart';

class TopNotification {
  static void show(
      BuildContext context, {
        required String message,
        bool isError = false,
        Duration duration = const Duration(seconds: 5),
      }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    // Create the OverlayEntry
    overlayEntry = OverlayEntry(
      builder: (context) => _TopNotificationWidget(
        message: message,
        isError: isError,
        duration: duration,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    // Insert the OverlayEntry into the overlay
    overlay.insert(overlayEntry);

    // Automatically remove after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class _TopNotificationWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final Duration duration;
  final VoidCallback onDismiss;

  _TopNotificationWidget({
    required this.message,
    required this.isError,
    required this.duration,
    required this.onDismiss,
  });

  @override
  _TopNotificationWidgetState createState() => _TopNotificationWidgetState();
}

class _TopNotificationWidgetState extends State<_TopNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isError ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  widget.isError ? Icons.error : Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    _controller.reverse().then((_) => widget.onDismiss());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}