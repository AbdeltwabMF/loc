import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loc/screens/about.dart';
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
                AppColors.lavender.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: const EdgeInsets.only(
                  top: 8,
                  right: 4,
                  left: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Loc -  ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        color: AppColors.fg.withOpacity(0.8),
                      ),
                    ),
                    Icon(
                      provider.isListening == true
                          ? shouldPlaySound(context) == true
                              ? Icons.circle_notifications_rounded
                              : Icons.run_circle_rounded
                          : Icons.circle_rounded,
                      color: provider.isListening == true
                          ? isInRange(context) == true
                              ? AppColors.coral
                              : Colors.green
                          : AppColors.fg.withOpacity(0.5),
                      size: 32,
                    ),
                  ],
                ),
              ),
              Expanded(
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
                                  left: 4,
                                  right: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.babyBlue,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: AppColors.babyBlue.withOpacity(0.2),
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
                                        controller:
                                            provider.destDisplayNameController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: AppColors.ashGray,
                                              width: 2,
                                              strokeAlign:
                                                  BorderSide.strokeAlignOutside,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.only(
                                            top: 4,
                                            bottom: 4,
                                            left: 4,
                                            right: 4,
                                          ),
                                          labelText: 'Destination Location',
                                          labelStyle: TextStyle(
                                              fontFamily: 'Fantasque'),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              controller: provider
                                                  .destLatitudeController,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppColors.ashGray,
                                                    width: 2,
                                                    strokeAlign: BorderSide
                                                        .strokeAlignOutside,
                                                  ),
                                                ),
                                                contentPadding: EdgeInsets.only(
                                                  top: 4,
                                                  bottom: 4,
                                                  left: 4,
                                                  right: 4,
                                                ),
                                                labelText: 'Latitude',
                                                prefixIcon: Icon(
                                                  Icons.near_me,
                                                ),
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .deny(RegExp(
                                                        r'^[+\-]?[0]{1}[^.]')),
                                              ],
                                              onChanged: (value) {
                                                if (value != '' &&
                                                    double.tryParse(value) !=
                                                        null) {
                                                  provider
                                                      .setDestLatitude(value);
                                                }
                                              },
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                signed: true,
                                                decimal: true,
                                              ),
                                              readOnly:
                                                  provider.isListening == true,
                                              validator: (value) {
                                                return validateNumber(
                                                  value,
                                                  message:
                                                      'Invalid latitude value',
                                                  limit: 90,
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
                                              controller: provider
                                                  .destLongitudeController,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppColors.ashGray,
                                                    width: 2,
                                                    strokeAlign: BorderSide
                                                        .strokeAlignOutside,
                                                  ),
                                                ),
                                                contentPadding: EdgeInsets.only(
                                                  top: 4,
                                                  bottom: 4,
                                                  left: 4,
                                                  right: 4,
                                                ),
                                                labelText: 'Longitude',
                                                prefixIcon: Icon(
                                                  Icons.near_me,
                                                ),
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .deny(RegExp(
                                                        r'^[+\-]?[0]{1}[^.]')),
                                              ],
                                              onChanged: (value) {
                                                if (value != '' &&
                                                    double.tryParse(value) !=
                                                        null) {
                                                  provider
                                                      .setDestLongitude(value);
                                                }
                                              },
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                signed: true,
                                                decimal: true,
                                              ),
                                              readOnly:
                                                  provider.isListening == true,
                                              validator: (value) {
                                                return validateNumber(
                                                  value,
                                                  message:
                                                      'Invalid longitude value',
                                                  limit: 180,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  right: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.lavender,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: AppColors.lavender.withOpacity(0.2),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(
                                        top: 8,
                                        left: 2,
                                        right: 2,
                                        bottom: 8,
                                      ),
                                      child: TextFormField(
                                        controller: TextEditingController(
                                            text: provider
                                                .currDisplayNameController
                                                .text),
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: AppColors.fg,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.only(
                                            top: 4,
                                            bottom: 4,
                                            left: 4,
                                            right: 4,
                                          ),
                                          labelText: 'Current Location',
                                          labelStyle: TextStyle(
                                            fontFamily: 'Fantasque',
                                          ),
                                          prefixIcon: Icon(
                                            Icons.my_location,
                                          ),
                                        ),
                                        readOnly: true,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'NotoArabic',
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              controller: TextEditingController(
                                                  text: provider
                                                          .isCurrentLocationValid()
                                                      ? provider.currLatitude
                                                          ?.toString()
                                                      : null),
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppColors.ashGray,
                                                    width: 2,
                                                    strokeAlign: BorderSide
                                                        .strokeAlignOutside,
                                                  ),
                                                ),
                                                contentPadding: EdgeInsets.only(
                                                  top: 4,
                                                  bottom: 4,
                                                  left: 4,
                                                  right: 4,
                                                ),
                                                labelText: 'Latitude',
                                                prefixIcon: Icon(
                                                  Icons.near_me,
                                                ),
                                              ),
                                              readOnly: true,
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
                                              controller: TextEditingController(
                                                  text: provider
                                                          .isCurrentLocationValid()
                                                      ? provider.currLongitude
                                                          ?.toString()
                                                      : null),
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppColors.ashGray,
                                                    width: 2,
                                                    strokeAlign: BorderSide
                                                        .strokeAlignOutside,
                                                  ),
                                                ),
                                                contentPadding: EdgeInsets.only(
                                                  top: 4,
                                                  bottom: 4,
                                                  left: 4,
                                                  right: 4,
                                                ),
                                                labelText: 'Longitude',
                                                prefixIcon: Icon(
                                                  Icons.near_me,
                                                ),
                                              ),
                                              readOnly: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  right: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.linen,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: AppColors.linen.withOpacity(0.2),
                                ),
                                child: Column(
                                  children: [
                                    Container(
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
                                          contentPadding: EdgeInsets.only(
                                            top: 4,
                                            bottom: 4,
                                            left: 4,
                                            right: 4,
                                          ),
                                          labelText: 'Radius',
                                          suffixText: 'Meters ',
                                          suffixStyle: TextStyle(
                                            fontFamily: 'Fantasque',
                                          ),
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
                                          if (value != '' ||
                                              int.tryParse(value) != null) {
                                            provider.setRadius(value);
                                          }
                                        },
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          signed: true,
                                          decimal: true,
                                        ),
                                        readOnly: provider.isListening == true,
                                        validator: (value) {
                                          return validateNumber(
                                            value,
                                            message: 'Invalid radius value',
                                            limit: 1000000000,
                                          );
                                        },
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              controller:
                                                  provider.distanceController,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppColors.fg,
                                                    width: 2,
                                                    strokeAlign: BorderSide
                                                        .strokeAlignOutside,
                                                  ),
                                                ),
                                                contentPadding: EdgeInsets.only(
                                                  top: 4,
                                                  bottom: 4,
                                                  left: 4,
                                                  right: 4,
                                                ),
                                                labelText: 'Distance',
                                                suffixText: 'Meters ',
                                                suffixStyle: TextStyle(
                                                  fontFamily: 'Fantasque',
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.straighten,
                                                ),
                                              ),
                                              readOnly: true,
                                              style: TextStyle(
                                                color: provider.isListening ==
                                                            true &&
                                                        isInRange(context) ==
                                                            true
                                                    ? AppColors.coral
                                                    : AppColors.fg,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                              left: 2,
                                              right: 2,
                                              bottom: 8,
                                            ),
                                            child: TextFormField(
                                              controller:
                                                  provider.bearingController,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppColors.fg,
                                                    strokeAlign: BorderSide
                                                        .strokeAlignOutside,
                                                  ),
                                                ),
                                                contentPadding: EdgeInsets.only(
                                                  top: 4,
                                                  bottom: 4,
                                                  left: 4,
                                                  right: 4,
                                                ),
                                                labelText: 'Bearing',
                                                suffixText: 'Degrees ',
                                                suffixStyle: TextStyle(
                                                  fontFamily: 'Fantasque',
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.straight,
                                                ),
                                              ),
                                              readOnly: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Divider(
                                  color: AppColors.fg.withOpacity(0.5),
                                  height: 4,
                                  endIndent: 8,
                                  indent: 8,
                                ),
                              ),
                              TextButton(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    Icon(
                                      Icons.info_rounded,
                                      color: AppColors.fg,
                                    ),
                                    Text(
                                      ' About',
                                      style: TextStyle(
                                        color: AppColors.fg,
                                        fontSize: 18,
                                      ),
                                    )
                                  ],
                                ),
                                onPressed: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return const AboutScreen();
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OpenMapButton(
                              isListening: provider.isListening,
                              onPressed: () async {
                                final pickedLocationData =
                                    await Navigator.of(context)
                                        .push<LocationData>(
                                  MaterialPageRoute<LocationData>(
                                    builder: (context) {
                                      return OsmMapViewScreen();
                                    },
                                  ),
                                );

                                if (pickedLocationData != null) {
                                  debugPrint(
                                      pickedLocationData.latitude.toString());
                                  debugPrint(
                                      pickedLocationData.longitude.toString());
                                  provider.setDestLatitude(
                                      pickedLocationData.latitude.toString());
                                  provider.setDestLongitude(
                                      pickedLocationData.longitude.toString());
                                  provider.setDestDisplayName(
                                      pickedLocationData.displayName ?? '');
                                }
                              },
                            ),
                          ),
                          Expanded(
                            child: StartButton(
                              isListening: provider.isListening,
                              isLocationValid:
                                  provider.isCurrentLocationValid(),
                              onPressed: () async {
                                // Act as stop button
                                if (provider.isListening == true) {
                                  provider.setListening(false);
                                  cancelPositionUpdates(context);
                                  provider.setDistance(null);
                                  provider.setBearing(null);
                                  shouldPlaySound(context);
                                  return;
                                }

                                if (provider.isDestinationLocationValid() ==
                                    false) {
                                  _formKey.currentState!.validate();
                                  return;
                                }

                                provider.setListening(true);
                                getCurrentLocation().then((value) async {
                                  provider.setCurrLatitude(value.latitude);
                                  provider.setCurrLongitude(value.longitude);

                                  provider.setDistance(
                                      distanceAndBearing(context)?.first);
                                  provider.setBearing(
                                      distanceAndBearing(context)?.last);

                                  shouldPlaySound(context);

                                  LocationData locationData = LocationData(
                                    latitude: double.parse(
                                        provider.destLatitudeController.text),
                                    longitude: double.parse(
                                        provider.destLongitudeController.text),
                                  );

                                  Map<String, dynamic> decodedResponse =
                                      await osmReverse(locationData)
                                          .onError((error, stackTrace) {
                                    debugPrint(error.toString());
                                    debugPrint(stackTrace.toString());
                                    return <String, dynamic>{};
                                  });

                                  if (decodedResponse.isNotEmpty) {
                                    provider.setDestDisplayName(
                                        decodedResponse['display_name'] ?? '');
                                  }

                                  debugPrint(
                                      provider.destDisplayNameController.text);

                                  locationData = LocationData(
                                      latitude: value.latitude,
                                      longitude: value.longitude);
                                  decodedResponse =
                                      await osmReverse(locationData)
                                          .onError((error, stackTrace) {
                                    debugPrint(error.toString());
                                    debugPrint(stackTrace.toString());
                                    return <String, dynamic>{};
                                  });

                                  if (decodedResponse.isNotEmpty) {
                                    provider.setCurrDisplayName(
                                        decodedResponse['display_name'] ?? '');
                                  }
                                }).onError(
                                  (error, stackTrace) {
                                    debugPrint(error.toString());
                                    debugPrint(stackTrace.toString());
                                    provider.setListening(false);
                                  },
                                );

                                handlePositionUpdates(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
