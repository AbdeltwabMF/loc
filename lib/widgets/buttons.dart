import 'package:flutter/material.dart';
import 'package:loc/styles/colors.dart';

class PickLocationButton extends StatelessWidget {
  const PickLocationButton({required this.onPressed, Key? key})
      : super(key: key);

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 8,
        left: 8,
        right: 8,
        bottom: 0,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(AppColors.darkGreen),
          elevation: MaterialStateProperty.all(0),
          padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 12)),
        ),
        child: const Text(
          'Pick a location',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class MapPickLocationButton extends StatelessWidget {
  const MapPickLocationButton({required this.onPressed, Key? key})
      : super(key: key);

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 8,
        left: 8,
        right: 8,
        bottom: 8,
      ),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(AppColors.darkGreen),
          elevation: MaterialStateProperty.all(0),
          padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 12)),
        ),
        onPressed: onPressed,
        child: const Text(
          'Set destination',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
