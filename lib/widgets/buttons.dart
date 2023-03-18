import 'package:flutter/material.dart';

class SelectDestinationButton extends StatelessWidget {
  const SelectDestinationButton({required this.onPressed, Key? key})
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
          // backgroundColor: MaterialStateProperty.all(
          // ),
          elevation: MaterialStateProperty.all(0),
          padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 12)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
            ),
            Text(
              ' Select Destination',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ZoomInFloatingButton extends StatelessWidget {
  const ZoomInFloatingButton({
    super.key,
    required this.onPressed,
  });

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 0,
      heroTag: 'zoomIn',
      onPressed: onPressed,
      tooltip: 'Zoom in',
      child: const Icon(
        Icons.zoom_in_map_rounded,
      ),
    );
  }
}

class ZoomOutFloatingButton extends StatelessWidget {
  const ZoomOutFloatingButton({
    super.key,
    required this.onPressed,
  });

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 0,
      heroTag: 'zoomOut',
      onPressed: onPressed,
      tooltip: 'Zoom out',
      child: const Icon(
        Icons.zoom_out_map_rounded,
      ),
    );
  }
}

class MyLocationFloatingButton extends StatelessWidget {
  const MyLocationFloatingButton({
    super.key,
    required this.onPressed,
  });

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 0,
      heroTag: 'myLocation',
      onPressed: onPressed,
      tooltip: 'My location',
      child: const Icon(
        Icons.my_location_rounded,
      ),
    );
  }
}

class ChooseOnMapButton extends StatelessWidget {
  const ChooseOnMapButton({required this.onPressed, Key? key})
      : super(key: key);

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.map_rounded,
            ),
            Text(
              ' Choose on map',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddReminderButton extends StatelessWidget {
  const AddReminderButton({
    required this.onPressed,
    this.buttonText = ' Add Reminder',
    Key? key,
  }) : super(key: key);

  final void Function() onPressed;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_alarm,
            ),
            Text(
              buttonText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
