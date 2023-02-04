import 'package:flutter/material.dart';
import 'package:loc/styles/colors.dart';
import 'package:url_launcher/url_launcher.dart';

const String version = 'v0.3.2';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.lavender,
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
        alignment: Alignment.topCenter,
        child: ListView(
          physics: const ScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            const Image(
              image: AssetImage('assets/images/featureGraphic.png'),
              width: 100,
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 16,
                left: 8,
                right: 8,
              ),
              decoration: const BoxDecoration(
                color: AppColors.ashGray,
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
              child: const ListTile(
                leading: Icon(
                  Icons.star_border_rounded,
                  color: AppColors.fg,
                  size: 48,
                ),
                title: Text('Loc version'),
                subtitle: Text(version),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 8,
                left: 8,
                right: 8,
              ),
              decoration: const BoxDecoration(
                color: AppColors.ashGray,
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
              child: const ListTile(
                leading: Icon(
                  Icons.copyright_rounded,
                  color: AppColors.fg,
                  size: 48,
                ),
                title: Text('License'),
                subtitle: Text('GPL v3'),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 8,
                left: 8,
                right: 8,
              ),
              decoration: const BoxDecoration(
                color: AppColors.ashGray,
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
              child: TextButton(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.zero)),
                onPressed: () {
                  const String amf = 'https://abdeltwabmf.github.io/about';
                  _launchUrl(amf);
                },
                child: const ListTile(
                  leading: Icon(
                    Icons.person_rounded,
                    color: AppColors.fg,
                    size: 48,
                  ),
                  title: Text('Author'),
                  subtitle: Text('Abd El-Twab M. Fakhry'),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 8,
                left: 8,
                right: 8,
              ),
              decoration: const BoxDecoration(
                color: AppColors.ashGray,
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
              child: TextButton(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.zero)),
                onPressed: () {
                  const String sourceCode =
                      'https://github.com/AbdeltwabMF/loc';
                  _launchUrl(sourceCode);
                },
                child: const ListTile(
                  leading: Icon(
                    Icons.code_rounded,
                    color: AppColors.fg,
                    size: 48,
                  ),
                  title: Text('Source code'),
                  subtitle: Text('https://github.com/AbdeltwabMF/loc'),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 8,
                left: 8,
                right: 8,
              ),
              decoration: const BoxDecoration(
                color: AppColors.ashGray,
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
              child: TextButton(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.zero)),
                onPressed: () {
                  const String issues =
                      'https://github.com/AbdeltwabMF/Loc/issues';
                  _launchUrl(issues);
                },
                child: const ListTile(
                  leading: Icon(
                    Icons.info_rounded,
                    color: AppColors.fg,
                    size: 48,
                  ),
                  title: Text('Issues'),
                  subtitle: Text('Issues found in this software'),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 8,
                left: 8,
                right: 8,
              ),
              decoration: const BoxDecoration(
                color: AppColors.ashGray,
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
              child: const ListTile(
                isThreeLine: true,
                leading: Icon(
                  Icons.privacy_tip_rounded,
                  color: AppColors.fg,
                  size: 48,
                ),
                title: Text('Privacy policy'),
                subtitle:
                    Text('Loc doesn\'t collect or store any of your data'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _launchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
    debugPrint('Can not launch $url');
  }
}
