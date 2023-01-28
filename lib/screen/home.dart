import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loc/style/colors.dart';
import 'package:loc/utils/location.dart';
import 'package:loc/utils/states.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStates>(context);

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
                            RegExp(r'[0-9]+[.]?[0-9]*')),
                      ],
                      onChanged: (value) {
                        provider.setLatitude(value);
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
                            RegExp(r'[0-9]+[.]?[0-9]*')),
                      ],
                      onChanged: (value) => {provider.setLongitude(value)},
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
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9]+[.]?[0-9]*')),
                      ],
                      onChanged: (value) => {provider.setRadius(value)},
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
                  top: 64,
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
                    getCurrentLocation().then((value) {
                      provider.setCurrLatitude(value.latitude);
                      provider.setCurrLongitude(value.longitude);
                    }).onError((error, stackTrace) {
                      debugPrint(error.toString());
                      debugPrint(stackTrace.toString());
                    });
                    listenToLocationUpdate(context);
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
                    provider.isListening ? 'Stop' : 'Start',
                    style: const TextStyle(
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  top: 64,
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
                                : 'Latitude',
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
                                : 'Longitude',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
