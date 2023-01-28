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
                      controller: provider.latitudeText,
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
                      controller: provider.longitudeText,
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
                  bottom: 8,
                ),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    debugPrint('Run Pressed');
                    debugPrint('Latitude: ${provider.latitudeText.text}');
                    debugPrint('Longitude: ${provider.longitudeText.text}');
                    debugPrint('Radius: ${provider.radiusText.text}');
                    getCurrentLocation().then((value) {
                      print(value.latitude);
                      print(value.longitude);
                    }).onError((error, stackTrace) {
                      print(error.toString());
                    });
                  },
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(0),
                    shape: MaterialStateProperty.all(const CircleBorder()),
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(80)),
                  ),
                  child: const Text(
                    'Run',
                    style: TextStyle(
                      fontSize: 32,
                    ),
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
