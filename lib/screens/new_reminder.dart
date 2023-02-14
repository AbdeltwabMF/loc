import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loc/screens/home.dart';
import 'package:loc/styles/colors.dart';
import 'package:loc/utils/location.dart';
import 'package:loc/utils/states.dart';
import 'package:loc/utils/types.dart';
import 'package:loc/widgets/buttons.dart';
import 'package:provider/provider.dart';
import 'package:loc/screens/osm_map_view.dart';
import 'package:uuid/uuid.dart';

class NewReminderScreen extends StatelessWidget {
  NewReminderScreen({super.key});

  final _locationFormKey = GlobalKey<FormState>();
  final _titleFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStates>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Reminder settings',
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.only(
            top: 16,
            left: 12,
            right: 12,
            bottom: 16,
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    Form(
                      key: _titleFormKey,
                      child: TextFormField(
                        controller: provider.title,
                        cursorColor: AppColors.fg,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.only(
                            left: 8,
                            right: 8,
                          ),
                          errorStyle: TextStyle(
                            color: AppColors.lightRed,
                            fontFamily: 'Fantasque',
                            fontWeight: FontWeight.bold,
                          ),
                          filled: true,
                          hintText: 'e.g. Remind me when I am there!',
                        ),
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Fantasque',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty == true) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        bottom: 16,
                      ),
                      child: const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.fg,
                        ),
                      ),
                    ),
                    Form(
                      key: _locationFormKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: provider.latitude,
                                cursorColor: AppColors.fg,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.only(
                                    top: 4,
                                    bottom: 4,
                                    left: 8,
                                    right: 8,
                                  ),
                                  errorStyle: TextStyle(
                                    color: AppColors.lightRed,
                                    fontFamily: 'Fantasque',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  filled: true,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  hintText: 'e.g. 3.14',
                                  labelText: 'Latitude',
                                  labelStyle: TextStyle(
                                    color: AppColors.fg,
                                    fontFamily: 'Fantasque',
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                      RegExp(r'^[+\-]?[0]{1}[^.]')),
                                ],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  signed: true,
                                  decimal: true,
                                ),
                                style: const TextStyle(
                                  color: AppColors.fg,
                                  fontFamily: 'Fantasque',
                                ),
                                validator: (value) {
                                  return validateNumber(
                                    value,
                                    message: 'Invalid latitude',
                                    limit: 90,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: provider.longitude,
                                cursorColor: AppColors.fg,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.only(
                                    top: 4,
                                    bottom: 4,
                                    left: 8,
                                    right: 8,
                                  ),
                                  errorStyle: TextStyle(
                                    color: AppColors.lightRed,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Fantasque',
                                  ),
                                  filled: true,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  hintText: 'e.g. 3.14',
                                  labelText: 'Longitude',
                                  labelStyle: TextStyle(
                                    color: AppColors.fg,
                                    fontFamily: 'Fantasque',
                                    fontSize: 16,
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                      RegExp(r'^[+\-]?[0]{1}[^.]')),
                                ],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  signed: true,
                                  decimal: true,
                                ),
                                style: const TextStyle(
                                  color: AppColors.fg,
                                  fontFamily: 'Fantasque',
                                ),
                                validator: (value) {
                                  return validateNumber(
                                    value,
                                    message: 'Invalid longitude',
                                    limit: 180,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ChooseOnMapButton(
                      onPressed: () async {
                        final pickedPlace =
                            await Navigator.of(context).push<Place>(
                          MaterialPageRoute<Place>(
                            builder: (context) {
                              return OsmMapViewScreen();
                            },
                          ),
                        );

                        if (pickedPlace != null) {
                          final position = LatLong(
                            latitude: pickedPlace.position.latitude,
                            longitude: pickedPlace.position.longitude,
                          );

                          if (position.isValid()) {
                            provider.setLatitude(position.latitude.toString());
                            provider
                                .setLongitude(position.longitude.toString());
                          }
                        }
                      },
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Text(
                              'Radius',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.fg,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: provider.radius,
                              cursorColor: AppColors.fg,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.only(
                                  top: 4,
                                  bottom: 4,
                                  left: 8,
                                  right: 8,
                                ),
                                errorStyle: TextStyle(
                                  color: AppColors.darkRed,
                                  fontFamily: 'Fantasque',
                                  fontWeight: FontWeight.bold,
                                ),
                                filled: true,
                                hintText: 'e.g. 1000',
                                suffixText: 'Meters',
                                suffixStyle: TextStyle(
                                  fontFamily: 'Fantasque',
                                  color: AppColors.darkAqua,
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'(^[0-9]{1,7})')),
                                FilteringTextInputFormatter.deny(
                                    RegExp(r'(^[0-9]{8,})')),
                                FilteringTextInputFormatter.deny(
                                    RegExp(r'(^[0]{1}[0-9]+)')),
                              ],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                signed: true,
                                decimal: true,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty &&
                                    int.tryParse(value) != null) {
                                  provider.setRadius(value);
                                }
                              },
                              style: const TextStyle(
                                fontFamily: 'Fantasque',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 0,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Text(
                              'Alarm',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.fg,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 64,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Switch(
                                activeTrackColor: AppColors.lightGreen,
                                activeColor: AppColors.darkGreen,
                                value: provider.withAlarm,
                                onChanged: (bool state) {
                                  provider.setWithAlarm(state);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: provider.notes,
                      cursorColor: AppColors.fg,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.only(
                          left: 8,
                          right: 8,
                          top: 8,
                          bottom: 8,
                        ),
                        filled: true,
                        hintText: 'Notes...',
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppColors.fg,
                        fontFamily: 'Fantasque',
                      ),
                      keyboardType: TextInputType.multiline,
                      minLines: 8,
                      maxLines: 8,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              ),
              AddReminderButton(
                onPressed: () async {
                  // Validate inputs
                  if (provider.title.text.isEmpty) {
                    _titleFormKey.currentState!.validate();
                    return;
                  }

                  if (provider.latitude.text.isEmpty ||
                      provider.longitude.text.isEmpty) {
                    _locationFormKey.currentState!.validate();
                    return;
                  }

                  if (provider.radius.text.isEmpty) {
                    provider.setRadius('1000');
                  }

                  debugPrint('here');

                  LatLong destination = LatLong(
                    latitude: double.parse(provider.latitude.text),
                    longitude: double.parse(provider.longitude.text),
                  );

                  Map<String, dynamic> decodedResponse =
                      await osmReverse(destination)
                          .onError((error, stackTrace) {
                    debugPrint(error.toString());
                    debugPrint(stackTrace.toString());
                    return <String, dynamic>{};
                  });

                  Reminder newReminder = Reminder(
                    id: const Uuid().v4(),
                    title: provider.title.text,
                    position: destination,
                    displayName: decodedResponse['display_name'],
                    radius: int.parse(provider.radius.text),
                    withAlarm: provider.withAlarm,
                    notes: provider.notes.text,
                  );

                  provider.createReminder(newReminder);

                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (context) {
                        return const HomeScreen();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
