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
        bottom: 0,
      ),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(AppColors.babyBlue),
          elevation: MaterialStateProperty.all(0),
          padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 12)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          side: MaterialStateProperty.all(
            const BorderSide(
              color: AppColors.blue,
              width: 1,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(
              Icons.location_searching,
              color: AppColors.fg,
            ),
            Text(
              ' Select Destination',
              style: TextStyle(
                color: AppColors.fg,
                fontSize: 20,
              ),
            ),
          ],
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
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevation: MaterialStateProperty.all(0),
          padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 12)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.map_rounded,
              color: AppColors.fg,
            ),
            Text(
              ' Open Map',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.fg,
              ),
            ),
          ],
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
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevation: MaterialStateProperty.all(0),
          padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isListening == true
                  ? isLocationValid == true
                      ? Icons.stop_circle_rounded
                      : Icons.calculate_rounded
                  : Icons.navigation_rounded,
              color: AppColors.fg,
            ),
            Text(
              isListening == true
                  ? isLocationValid == true
                      ? ' Stop'
                      : ' Calculating'
                  : ' Start',
              style: const TextStyle(
                fontSize: 20,
                color: AppColors.fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
