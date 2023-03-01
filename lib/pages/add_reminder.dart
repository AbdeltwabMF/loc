import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:loc/data/app_states.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/data/repository/maps.dart';
import 'package:loc/widgets/add_reminder/buttons.dart';
import 'package:loc/pages/choose_location.dart';
import 'package:loc/utils/location.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddReminderPage extends StatelessWidget {
  AddReminderPage({super.key});

  final _locationFormKey = GlobalKey<FormState>();
  final _titleFormKey = GlobalKey<FormState>();

  final TextEditingController title = TextEditingController();
  final TextEditingController latitude = TextEditingController();
  final TextEditingController longitude = TextEditingController();
  final TextEditingController radius = TextEditingController();
  final TextEditingController notes = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appStates = Provider.of<AppStates>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('New Reminder'),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  children: [
                    Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      key: _titleFormKey,
                      child: TextFormField(
                        controller: title,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.only(
                            left: 12,
                            right: 12,
                          ),
                          filled: true,
                          errorStyle: TextStyle(
                            fontFamily: 'Fantasque',
                          ),
                          hintText: 'Remind me when...',
                        ),
                        style: const TextStyle(
                          fontFamily: 'Fantasque',
                          fontWeight: FontWeight.normal,
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
                        ),
                      ),
                    ),
                    Form(
                      key: _locationFormKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: latitude,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                filled: true,
                                errorStyle: TextStyle(
                                  fontFamily: 'Fantasque',
                                ),
                                hintText: 'lat coordinate',
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 20,
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
                                fontFamily: 'Fantasque',
                              ),
                              validator: (value) {
                                return latLngValidate(
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
                              controller: longitude,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                filled: true,
                                errorStyle: TextStyle(
                                  fontFamily: 'Fantasque',
                                ),
                                hintText: 'long coordinate',
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 20,
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
                                fontFamily: 'Fantasque',
                              ),
                              validator: (value) {
                                return latLngValidate(
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
                    const SizedBox(
                      height: 8,
                    ),
                    ChooseOnMapButton(
                      onPressed: () async {
                        final pickedLocation =
                            await Navigator.of(context).push<Place>(
                          MaterialPageRoute<Place>(
                            builder: (context) {
                              return const ChooseLocationPage();
                            },
                          ),
                        );

                        if (pickedLocation != null) {
                          latitude.text =
                              pickedLocation.position.latitude.toString();
                          longitude.text =
                              pickedLocation.position.longitude.toString();
                        }
                      },
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    TextFormField(
                      controller: radius,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        filled: true,
                        hintText: 'radius',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 20,
                        ),
                        suffixText: 'Meters',
                        suffixStyle: TextStyle(
                          fontFamily: 'Fantasque',
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
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Fantasque',
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: notes,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          filled: true,
                          hintText: 'Your notes here...',
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.normal,
                          )),
                      style: const TextStyle(
                        fontFamily: 'Fantasque',
                        fontSize: 20,
                      ),
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 32,
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
                  if (title.text.isEmpty) {
                    _titleFormKey.currentState!.validate();
                    return;
                  }

                  if (latitude.text.isEmpty || longitude.text.isEmpty) {
                    _locationFormKey.currentState!.validate();
                    return;
                  }

                  LatLng position = LatLng(
                    double.parse(latitude.text),
                    double.parse(longitude.text),
                  );

                  final destination = await Maps()
                      .getLocationInfo(position)
                      .onError((error, stackTrace) {
                    return Future.error(error!, stackTrace);
                  });

                  if (radius.text.isEmpty) {
                    radius.text = destination.radius.toString();
                  }

                  Reminder newReminder = Reminder(
                    id: const Uuid().v4(),
                    title: title.text,
                    place: destination,
                    initialDistance: 0.0,
                    notes: notes.text,
                  );

                  // Update the initial distance
                  newReminder.traveledDistance(position);
                  appStates.reminderAdd(newReminder);

                  if (context.mounted) {
                    Navigator.of(context).pop<void>();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
