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
                        ? AppColors.lightRed.withOpacity(0.1)
                        : AppColors.lightBlue.withOpacity(0.1)
                    : AppColors.lightGreen.withOpacity(0.1),
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
                PickLocationButton(
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

                      provider.destLatitudeController.value =
                          provider.destLatitudeController.value.copyWith(
                        text: pickedLocationData.latitude.toString(),
                      );

                      provider.destLongitudeController.value =
                          provider.destLongitudeController.value.copyWith(
                        text: pickedLocationData.longitude.toString(),
                      );

                      provider.addressController.value =
                          provider.addressController.value.copyWith(
                        text: pickedLocationData.displayName,
                      );
                    }
                  },
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 16,
                      bottom: 8,
                    ),
                    child: Column(children: [
                      Container(
                        padding: const EdgeInsets.only(
                          top: 8,
                          left: 4,
                          right: 4,
                          bottom: 8,
                        ),
                        child: TextFormField(
                          textAlign: TextAlign.right,
                          controller: provider.addressController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.fg,
                              ),
                            ),
                            contentPadding: EdgeInsets.all(12),
                            labelText: 'Address',
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
                                      color: AppColors.fg,
                                    ),
                                  ),
                                  labelText: 'Latitude',
                                  prefixIcon: Icon(
                                    Icons.location_pin,
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                      RegExp(r'^[+\-]?[0]{1}[^.]')),
                                ],
                                onChanged: (value) {
                                  // The solution to cursor out of position problem
                                  // https://github.com/flutter/flutter/blob/2d2a1ffec95cc70a3218872a2cd3f8de4933c42f/packages/flutter/lib/src/widgets/editable_text.dart#L143
                                  provider.destLatitudeController.value =
                                      provider.destLatitudeController.value
                                          .copyWith(
                                    text: value,
                                  );

                                  provider.setDistance(calcDistance(context));
                                  shouldPlaySound(context);
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
                                      color: AppColors.fg,
                                    ),
                                  ),
                                  labelText: 'Longitude',
                                  prefixIcon: Icon(
                                    Icons.location_pin,
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                      RegExp(r'^[+\-]?[0]{1}[^.]')),
                                ],
                                onChanged: (value) {
                                  provider.destLongitudeController.value =
                                      provider.destLongitudeController.value
                                          .copyWith(
                                    text: value,
                                  );
                                  provider.setDistance(calcDistance(context));
                                  shouldPlaySound(context);
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
                      Container(
                        padding: const EdgeInsets.only(
                          top: 8,
                          left: 4,
                          right: 4,
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
                            provider.radiusController.value =
                                provider.radiusController.value.copyWith(
                              text: value,
                            );

                            provider.setDistance(calcDistance(context));
                            shouldPlaySound(context);
                          },
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: true,
                          ),
                          readOnly: provider.isListening == true,
                          validator: (value) {
                            if (value == null || value == '') {
                              return 'Radius is required';
                            } else if (double.tryParse(value) == null) {
                              return 'Invalid radius value';
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ]),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 4,
                    right: 4,
                    bottom: 8,
                  ),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Act as stop button
                      if (provider.isListening == true) {
                        provider.setListening(false);
                        cancelLocationUpdate(context);
                        shouldPlaySound(context);
                        return;
                      }

                      if (provider.isInputValid() == false) {
                        _formKey.currentState!.validate();
                        return;
                      }

                      provider.setListening(true);
                      getCurrentLocation().then((value) async {
                        provider.setCurrLatitude(value.latitude);
                        provider.setCurrLongitude(value.longitude);
                        provider.setDistance(calcDistance(context));

                        shouldPlaySound(context);
                        listenLocationUpdate(context);

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
                          provider.addressController.value =
                              provider.addressController.value.copyWith(
                            text: decodedResponse['display_name'] ?? '',
                          );
                        }
                      }).onError((error, stackTrace) {
                        debugPrint(error.toString());
                        debugPrint(stackTrace.toString());
                        provider.setListening(false);
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        provider.isListening == true
                            ? provider.isLocationValid() == true
                                ? AppColors.darkRed
                                : AppColors.darkBlue
                            : AppColors.darkGreen,
                      ),
                      elevation: MaterialStateProperty.all(0),
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 12)),
                    ),
                    child: Text(
                      provider.isListening == true
                          ? provider.isLocationValid() == true
                              ? 'Stop'
                              : 'Calculating'
                          : 'Start',
                      style: const TextStyle(
                        fontSize: 20,
                      ),
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
                          color: AppColors.darkYellow,
                          backgroundColor: AppColors.lightRed,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.darkRed),
                        ),
                      )
                    : const SizedBox(),
                provider.isListening == true &&
                        provider.isLocationValid() == true
                    ? Container(
                        padding: const EdgeInsets.only(
                          top: 16,
                          left: 8,
                          right: 8,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                top: 8,
                                left: 8,
                                right: 8,
                                bottom: 16,
                              ),
                              child: const Text(
                                'Current Location',
                                style: TextStyle(
                                  color: AppColors.fg,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Row(children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    left: 8,
                                    right: 8,
                                    bottom: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.fg,
                                      strokeAlign:
                                          BorderSide.strokeAlignOutside,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    provider.isLocationValid() == true
                                        ? provider.currLatitude.toString()
                                        : '',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    left: 8,
                                    right: 8,
                                    bottom: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.fg,
                                      strokeAlign:
                                          BorderSide.strokeAlignOutside,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    provider.isLocationValid() == true
                                        ? provider.currLongitude.toString()
                                        : '',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      )
                    : const SizedBox(),
                provider.isListening == true &&
                        provider.isDistanceValid() == true
                    ? Container(
                        padding: const EdgeInsets.only(
                          top: 8,
                          left: 8,
                          right: 8,
                          bottom: 8,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                top: 8,
                                left: 8,
                                right: 8,
                                bottom: 16,
                              ),
                              child: const Text(
                                'Distance',
                                style: TextStyle(
                                  color: AppColors.fg,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(
                                top: 8,
                                left: 8,
                                right: 8,
                                bottom: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.fg,
                                  strokeAlign: BorderSide.strokeAlignOutside,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${provider.distance.round().toString()} Meters',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
