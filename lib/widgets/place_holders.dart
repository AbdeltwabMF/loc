import 'package:flutter/material.dart';

class EmptySpace extends StatelessWidget {
  const EmptySpace({
    required this.comment,
    super.key,
  });

  final String comment;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        comment,
        style: TextStyle(
          fontSize: 32,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
    );
  }
}
