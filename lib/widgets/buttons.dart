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
          backgroundColor: MaterialStateProperty.all(AppColors.ashGray),
          elevation: MaterialStateProperty.all(0),
          padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 12)),
          side: MaterialStateProperty.all(
            BorderSide(
              color: AppColors.fg.withOpacity(0.6),
              width: 2,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          'Set destination',
          style: TextStyle(
            color: AppColors.fg.withOpacity(0.9),
            fontSize: 18,
          ),
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
        left: 4,
        right: 4,
        bottom: 8,
      ),
      child: ElevatedButton(
        onPressed: isListening == true ? null : onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            isListening
                ? AppColors.desertSand.withOpacity(0.6)
                : AppColors.yellowRed.withOpacity(0.6),
          ),
          elevation: MaterialStateProperty.all(0),
          padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 12)),
        ),
        child: const Text(
          'Open Map',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.fg,
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
        right: 4,
        bottom: 8,
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
                  : 'Calculating ...'
              : 'Start Tracking',
          style: TextStyle(
            fontSize: 18,
            color: isListening == true
                ? isLocationValid == true
                    ? AppColors.bg
                    : AppColors.fg
                : AppColors.fg,
          ),
        ),
      ),
    );
  }
}
