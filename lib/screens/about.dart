import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:loc/styles/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.pink,
        elevation: 0,
        foregroundColor: AppColors.fg,
        title: const Text(
          'About',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16,
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Image(
              image: AssetImage('assets/images/app_icon.png'),
              width: 150,
              height: 150,
            ),
            const Padding(
              padding: EdgeInsets.only(
                top: 24,
              ),
              child: Text(
                'Loc',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.fg,
                  fontSize: 48,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                top: 16,
                bottom: 8,
              ),
              child: Text(
                'v0.2.2',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                top: 8,
                bottom: 16,
              ),
              child: Text(
                'GPL v3 License',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  color: AppColors.fg,
                  fontFamily: 'Fantasque',
                  fontSize: 18,
                ),
                children: [
                  const TextSpan(
                    text:
                        'Free and open-source location-based reminder for Android.\n\n',
                  ),
                  const TextSpan(
                    text: 'Designed by \n\n',
                  ),
                  TextSpan(
                    text: 'Abd El-Twab M. Fakhry\n\n',
                    style: const TextStyle(
                      color: AppColors.lavender,
                      fontSize: 28,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        const amf = 'https://abdeltwabmf.github.io/';
                        await _launchUrl(amf);
                      },
                  ),
                  const TextSpan(
                    text: 'Source Code can be found here on\n\n',
                  ),
                  TextSpan(
                    text: 'GitHub',
                    style: const TextStyle(
                      color: AppColors.coral,
                      fontSize: 20,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        const loc = 'https://github.com/AbdeltwabMF/Loc';
                        await _launchUrl(loc);
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _launchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    debugPrint('Can not launch $url');
  }
}
