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
        left: 4,
        right: 4,
        bottom: 8,
      ),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(AppColors.babyBlue),
          elevation: MaterialStateProperty.all(0),
          padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 12)),
          side: MaterialStateProperty.all(
            const BorderSide(
              color: AppColors.lavender,
              width: 1,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          'Set destination',
          style: TextStyle(
              color: AppColors.fg.withOpacity(0.9),
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class OpenMapButton extends StatelessWidget {
  const OpenMapButton(
      {required this.onPressed, Key? key, this.isListening = false})
      : super(key: key);

  final void Function() onPressed;
  final bool isListening;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 8,
        right: 4,
      ),
      child: ElevatedButton(
        onPressed: isListening == true ? null : onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            isListening ? AppColors.blue : AppColors.babyBlue,
          ),
          elevation: MaterialStateProperty.all(0),
          padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 12)),
        ),
        child: Text(
          'Open Map',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isListening
                ? AppColors.fg.withOpacity(0.5)
                : AppColors.fg.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}

class StartButton extends StatelessWidget {
  const StartButton(
      {required this.onPressed,
      Key? key,
      this.isListening = false,
      this.isLocationValid = false})
      : super(key: key);

  final void Function() onPressed;
  final bool isLocationValid;
  final bool isListening;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 8,
        left: 4,
      ),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            isListening == true
                ? isLocationValid == true
                    ? AppColors.coral
                    : AppColors.linen
                : AppColors.ashGray,
          ),
          elevation: MaterialStateProperty.all(0),
          padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 12)),
        ),
        child: Text(
          isListening == true
              ? isLocationValid == true
                  ? 'Stop'
                  : 'Calculating...'
              : 'Start',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isListening == true
                ? isLocationValid == true
                    ? AppColors.rose
                    : AppColors.fg
                : AppColors.fg.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}
