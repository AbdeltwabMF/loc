import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loc/styles/colors.dart';
import 'package:loc/utils/location.dart';
import 'package:loc/utils/states.dart';
import 'package:loc/screens/osm_map_view.dart';
import 'package:provider/provider.dart';
import 'package:loc/widgets/buttons.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStates>(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              end: Alignment.bottomCenter,
              begin: Alignment.topCenter,
              colors: [
                AppColors.bg,
                provider.isListening == true
                    ? provider.isLocationValid() == true
                        ? AppColors.ashGray.withOpacity(0.1)
                        : AppColors.ashGray.withOpacity(0.1)
                    : AppColors.ashGray.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(8),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 16,
                      bottom: 8,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                            top: 8,
                            left: 4,
                            right: 4,
                            bottom: 8,
                          ),
                          child: TextFormField(
                            textAlign: TextAlign.right,
                            controller: provider.destDisplayNameController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.ashGray,
                                  width: 2,
                                  strokeAlign: BorderSide.strokeAlignOutside,
                                ),
                              ),
                              contentPadding: EdgeInsets.all(12),
                              labelText: 'Address',
                              labelStyle: TextStyle(fontFamily: 'Fantasque'),
                              prefixIcon: Icon(
                                Icons.location_city,
                              ),
                            ),
                            readOnly: true,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'NotoArabic',
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  left: 4,
                                  right: 2,
                                  bottom: 8,
                                ),
                                child: TextFormField(
                                  controller: provider.destLatitudeController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColors.ashGray,
                                        width: 2,
                                        strokeAlign:
                                            BorderSide.strokeAlignOutside,
                                      ),
                                    ),
                                    labelText: 'Latitude',
                                    prefixIcon: Icon(
                                      Icons.near_me,
                                    ),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'^[+\-]?[0]{1}[^.]')),
                                  ],
                                  onChanged: (value) {
                                    if (value != '' &&
                                        double.tryParse(value) != null) {
                                      provider.setDestLatitudeController(
                                          double.parse(value));
                                    }
                                  },
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    signed: true,
                                    decimal: true,
                                  ),
                                  readOnly: provider.isListening == true,
                                  validator: (value) {
                                    return validateNumber(
                                      value,
                                      message: 'Invalid latitude value',
                                      limit: 100,
                                    );
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  left: 2,
                                  right: 4,
                                  bottom: 8,
                                ),
                                child: TextFormField(
                                  controller: provider.destLongitudeController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColors.ashGray,
                                        width: 2,
                                        strokeAlign:
                                            BorderSide.strokeAlignOutside,
                                      ),
                                    ),
                                    labelText: 'Longitude',
                                    prefixIcon: Icon(
                                      Icons.near_me,
                                    ),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'^[+\-]?[0]{1}[^.]')),
                                  ],
                                  onChanged: (value) {
                                    if (value != '' &&
                                        double.tryParse(value) != null) {
                                      provider.setDestLongitudeController(
                                          double.parse(value));
                                    }
                                  },
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    signed: true,
                                    decimal: true,
                                  ),
                                  readOnly: provider.isListening == true,
                                  validator: (value) {
                                    return validateNumber(
                                      value,
                                      message: 'Invalid longitude value',
                                      limit: 190,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  left: 2,
                                  right: 2,
                                  bottom: 8,
                                ),
                                child: TextFormField(
                                  controller: provider.radiusController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColors.fg,
                                      ),
                                    ),
                                    labelText: 'Radius',
                                    prefixIcon: Icon(
                                      Icons.radar,
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
                                  onChanged: (value) {
                                    if (value != '') {
                                      provider.setRadiusController(
                                          int.parse(value));
                                    }
                                  },
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    signed: true,
                                    decimal: true,
                                  ),
                                  readOnly: provider.isListening == true,
                                  validator: (value) {
                                    if (value == null || value == '') {
                                      return 'Radius is required';
                                    } else if (int.tryParse(value) == null) {
                                      return 'Invalid radius value';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  left: 2,
                                  right: 2,
                                  bottom: 8,
                                ),
                                child: TextFormField(
                                  controller: provider.distanceController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColors.fg,
                                        strokeAlign:
                                            BorderSide.strokeAlignOutside,
                                      ),
                                    ),
                                    labelText: 'Distance',
                                    suffixText: 'Meters',
                                    prefixIcon: Icon(
                                      Icons.line_axis,
                                    ),
                                  ),
                                  readOnly: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                            top: 8,
                            left: 2,
                            right: 2,
                            bottom: 8,
                          ),
                          child: TextFormField(
                            controller: TextEditingController(
                              text: provider.isLocationValid()
                                  ? '${provider.currLatitude?.toString()}, ${provider.currLongitude?.toString()}'
                                  : null,
                            ),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.fg,
                                ),
                              ),
                              labelText: 'Current Location',
                              prefixIcon: Icon(
                                Icons.my_location,
                              ),
                            ),
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                provider.isListening == true &&
                        provider.isLocationValid() == false &&
                        provider.isDistanceValid() == false
                    ? Container(
                        padding: const EdgeInsets.only(
                          top: 24,
                          left: 64,
                          right: 64,
                        ),
                        child: const LinearProgressIndicator(
                          value: null,
                          color: AppColors.ashGray,
                          backgroundColor: AppColors.rose,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.yellowRed),
                        ),
                      )
                    : const SizedBox(),
                Row(
                  children: [
                    Expanded(
                      child: OpenMapButton(
                        isListening: provider.isListening,
                        onPressed: () async {
                          final pickedLocationData =
                              await Navigator.of(context).push<LocationData>(
                            MaterialPageRoute<LocationData>(
                              builder: (context) {
                                return OsmMapViewScreen();
                              },
                            ),
                          );

                          if (pickedLocationData != null) {
                            debugPrint(pickedLocationData.latitude.toString());
                            debugPrint(pickedLocationData.longitude.toString());
                            provider.setDestLatitudeController(
                                pickedLocationData.latitude);
                            provider.setDestLongitudeController(
                                pickedLocationData.longitude);
                            provider.setDestDisplayNameController(
                                pickedLocationData.displayName ?? '');
                          }
                        },
                      ),
                    ),
                    Expanded(
                        child: StartButton(
                      isListening: provider.isListening,
                      isLocationValid: provider.isLocationValid(),
                      onPressed: () async {
                        // Act as stop button
                        if (provider.isListening == true) {
                          provider.setListening(false);
                          cancelLocationUpdate(context);
                          provider.setDistanceController(null);
                          shouldPlaySound(context);
                          return;
                        }

                        if (provider.isInputValid() == false) {
                          _formKey.currentState!.validate();
                          return;
                        }

                        provider.setDistanceController(calcDistance(context));
                        shouldPlaySound(context);
                        listenLocationUpdate(context);

                        provider.setListening(true);
                        getCurrentLocation().then((value) async {
                          provider.setCurrLatitude(value.latitude);
                          provider.setCurrLongitude(value.longitude);

                          LocationData locationData = LocationData(
                            latitude: double.parse(
                                provider.destLatitudeController.text),
                            longitude: double.parse(
                                provider.destLongitudeController.text),
                          );

                          final decodedResponse = await osmReverse(locationData)
                              .onError((error, stackTrace) {
                            debugPrint(error.toString());
                            debugPrint(stackTrace.toString());
                            return <String, dynamic>{};
                          });

                          if (decodedResponse.isNotEmpty) {
                            provider.setDestDisplayNameController(
                                decodedResponse['display_name'] ?? '');
                          }
                        }).onError((error, stackTrace) {
                          debugPrint(error.toString());
                          debugPrint(stackTrace.toString());
                          provider.setListening(false);
                        });
                      },
                    )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
