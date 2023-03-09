import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class EmptySpace extends StatelessWidget {
  const EmptySpace({
    required this.comment,
    super.key,
  });

  final String comment;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          flex: 2,
          child: RiveAnimation.asset(
            'assets/raw/cat.riv',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        Expanded(
          child: Text(
            comment,
            style: TextStyle(
              fontSize: 32,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ),
      ],
    );
  }
}
