import 'package:flutter/material.dart';

class UnreadCounter extends StatelessWidget {
  const UnreadCounter({
    required this.unreadCount,
    super.key,
  });

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final unreadString = (unreadCount > 99) ? '99+' : unreadCount.toString();
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Text(
        unreadString,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
    );
  }
}
