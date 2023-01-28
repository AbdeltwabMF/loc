import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loc/style/colors.dart';
import 'package:loc/utils/location.dart';
import 'package:loc/utils/states.dart';
import 'package:provider/provider.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStates>(context);
    final providerNoListening = Provider.of<AppStates>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Container(
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.only(
                      top: 32,
                      left: 8,
                      right: 8,
                      bottom: 8,
                    ),
                    child: TextFormField(
                      controller: provider.destLatitudeText,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.fg,
                          ),
                        ),
                        hintText: '14.223243242342342',
                        labelText: 'Latitude',
                        prefixIcon: Icon(
                          Icons.location_pin,
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^([+-]?[0-9]+.?[0-9]*)')),
                        FilteringTextInputFormatter.deny(
                            RegExp(r'(^[0]{1}[0-9]+)')),
                      ],
                      onChanged: (value) {
                        // Solution to cursor out of position
                        // https://github.com/flutter/flutter/blob/2d2a1ffec95cc70a3218872a2cd3f8de4933c42f/packages/flutter/lib/src/widgets/editable_text.dart#L143
                        provider.destLatitudeText.value =
                            provider.destLatitudeText.value.copyWith(
                          text: value,
                        );
                      },
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      bottom: 8,
                    ),
                    child: TextFormField(
                      controller: provider.destLongitudeText,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.fg,
                          ),
                        ),
                        hintText: '43.5455453453453453',
                        labelText: 'Longitude',
                        prefixIcon: Icon(
                          Icons.location_pin,
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^([+-]?[0-9]+.?[0-9]*)')),
                        FilteringTextInputFormatter.deny(
                            RegExp(r'(^[0]{1}[0-9]+)')),
                      ],
                      onChanged: (value) {
                        provider.destLongitudeText.value =
                            provider.destLongitudeText.value.copyWith(
                          text: value,
                        );
                      },
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 8,
                      right: 8,
                      bottom: 8,
                    ),
                    child: TextFormField(
                      controller: provider.radiusText,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.fg,
                          ),
                        ),
                        hintText: '100',
                        labelText: 'Radius',
                        prefixIcon: Icon(
                          Icons.radar,
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'(^[0-9]+)')),
                        FilteringTextInputFormatter.deny(
                            RegExp(r'(^[0]{1}[0-9]+)')),
                      ],
                      onChanged: (value) {
                        provider.radiusText.value =
                            provider.radiusText.value.copyWith(
                          text: value,
                        );
                      },
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                    ),
                  ),
                ]),
              ),
              Container(
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 8,
                  right: 8,
                ),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (provider.isListening) {
                      cancelLocationUpdate(context);
                      return;
                    }
                    if (provider.destLatitudeText.text == '' ||
                        provider.destLongitudeText.text == '' ||
                        provider.radiusText.text == '') {
                      debugPrint(
                          'Latitude, Longitude, and Radius are required!');
                      return;
                    }

                    FlutterRingtonePlayer.playNotification(
                      looping: true,
                      volume: 0.1,
                      asAlarm: true,
                    );

                    getCurrentLocation().then((value) {
                      provider.setCurrLatitude(value.latitude);
                      provider.setCurrLongitude(value.longitude);

                      listenToLocationUpdate(context);
                    }).onError((error, stackTrace) {
                      debugPrint(error.toString());
                      debugPrint(stackTrace.toString());
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      provider.isListening
                          ? Colors.red.withOpacity(0.5)
                          : Colors.blue.withOpacity(0.5),
                    ),
                    elevation: MaterialStateProperty.all(0),
                    shape: MaterialStateProperty.all(const CircleBorder()),
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(80)),
                  ),
                  child: Text(
                    provider.isListening
                        ? provider.isLocValid()
                            ? 'Stop'
                            : 'Calculating'
                        : 'Start',
                    style: const TextStyle(
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
              provider.isListening && providerNoListening.isLocValid() == false
                  ? Container(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 16,
                      ),
                      child: LinearProgressIndicator(
                        value: null,
                      ),
                    )
                  : const SizedBox(),
              provider.isListening && provider.isLocValid()
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
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  provider.currLatitude != null
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
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  provider.currLongitude != null
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
              provider.isListening && provider.isLocValid()
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
                              provider.isListening
                                  ? '${calcDistance(context).toString()} KM'
                                  : '',
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
    );
  }
}
