import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const String version = 'v0.5.9';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'About',
        ),
      ),
      body: Column(
        children: [
          const Image(
            image: AssetImage('assets/images/featureGraphic.png'),
            alignment: Alignment.topCenter,
            fit: BoxFit.fill,
          ),
          Expanded(
            child: Container(
              alignment: Alignment.topCenter,
              child: ListView(
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(
                      top: 16,
                      left: 8,
                      right: 8,
                    ),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                      // color: AppColors.bg1,
                    ),
                    child: const ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.star_border_rounded,
                        size: 32,
                      ),
                      subtitle: Text(
                        version,
                        style: TextStyle(
                          fontFamily: 'Fantasque',
                        ),
                      ),
                      title: Text(
                        'Loc version',
                        style: TextStyle(
                          fontSize: 18,
                        ),
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
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    child: const ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.copyright_rounded,
                        size: 32,
                      ),
                      subtitle: Text(
                        'GPL v3',
                        style: TextStyle(
                          fontFamily: 'Fantasque',
                        ),
                      ),
                      title: Text(
                        'License',
                        style: TextStyle(
                          fontSize: 18,
                        ),
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
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                      // color: AppColors.bg1,
                    ),
                    child: TextButton(
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.zero)),
                      onPressed: () {
                        const String amf =
                            'https://abdeltwabmf.github.io/about';
                        _launchUrl(amf);
                      },
                      child: const ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.person_rounded,
                          size: 32,
                        ),
                        subtitle: Text(
                          'Abd El-Twab M. Fakhry',
                          style: TextStyle(
                            fontFamily: 'Fantasque',
                          ),
                        ),
                        title: Text(
                          'Author',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
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
                        dense: true,
                        leading: Icon(
                          Icons.code_rounded,
                          size: 32,
                        ),
                        subtitle: Text(
                          'https://github.com/AbdeltwabMF/loc',
                          style: TextStyle(
                            fontFamily: 'Fantasque',
                          ),
                        ),
                        title: Text(
                          'Source code',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
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
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                      // color: AppColors.bg1,
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
                        dense: true,
                        leading: Icon(
                          Icons.info_rounded,
                          size: 32,
                        ),
                        subtitle: Text(
                          'Issues found in this software',
                          style: TextStyle(
                            fontFamily: 'Fantasque',
                          ),
                        ),
                        title: Text(
                          'Issues',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      top: 8,
                      left: 8,
                      right: 8,
                      bottom: 16,
                    ),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    child: const ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.privacy_tip_rounded,
                        size: 32,
                      ),
                      subtitle: Text(
                        'Loc doesn\'t collect any of your data',
                        style: TextStyle(
                          fontFamily: 'Fantasque',
                        ),
                      ),
                      title: Text(
                        'Privacy policy',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _launchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
    debugPrint('Can not launch $url');
  }
}
