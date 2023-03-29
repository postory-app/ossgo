import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ui/journey_mood_edit_page.dart';
import 'package:ui/recipient_address_edit_page.dart';
import 'package:ui/recipient_name_edit_page.dart';
import 'package:ui/template_select_page.dart';
import 'package:ui/tw_cities.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'dart:html' as html;

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: const ColorScheme(
            primary: Color(0xff008169),
            secondary: Color(0xffffd24a),
            brightness: Brightness.light,
            background: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onBackground: Colors.black,
            surface: Colors.white,
            error: Colors.red,
            onError: Colors.white,
            onSurface: Color(0xffb3aa99),
          ),
        ),
        home: MyHomePage() //JourneyMoodEditPage(), //MyHomePage(),
        );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    debugPrint("TwCities.getCityList = ${TwCities.getCityList()}");
    debugPrint("TwCities.getDistrictsList = ${TwCities.getDistrictsList("臺北市")}");
    debugPrint("TwCities.getPostcode = ${TwCities.getPostcode("臺北市", "中正區")}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBtn(context, "寫下旅途的心情", () => _gotoJourneyMoodEditPage(context)),
            const SizedBox(height: 10),
            _buildBtn(context, "收件人姓名", () => _gotoRecipientNameEditPage(context)),
            const SizedBox(height: 10),
            _buildBtn(context, "收件人住址", () => _gotoRecipientAddressEditPage(context)),
            const SizedBox(height: 10),
            _buildBtn(context, "版型選擇", () => _gotoTemplateSelectPageEditPage(context)),
            const SizedBox(height: 100),
            UnconstrainedBox(
              child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                    overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.08)),
                    shape: MaterialStateProperty.all(const StadiumBorder()),
                  ),
                  onPressed: () {
                    String path = "${Uri.base.toString().replaceFirst("#/", '')}assets/files/postory_train_ui.zip";
                    debugPrint("path: $path");
                    _downloadFile(path);
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                      child: Row(
                        children: const [
                          Text(
                            "Download",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.download,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  _buildBtn(BuildContext context, String title, void Function()? onPressed) {
    return TextButton(
        onPressed: onPressed,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black),
        ));
  }

  _gotoJourneyMoodEditPage(BuildContext context) async {
    String? result = await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
          return const JourneyMoodEditPage();
        },
      ),
    );
    debugPrint("result=$result");
  }

  _gotoRecipientNameEditPage(BuildContext context) async {
    String? result = await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
          return const RecipientNameEditPage();
        },
      ),
    );
    debugPrint("result=$result");
  }

  _gotoRecipientAddressEditPage(BuildContext context) async {
    /*
     result = {
            "city": "xxx",
        "district": "xxx",
        "postCode": "xxx", 
         "address": "xxx" 
             }
    */
    Map? result = await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
          return const RecipientAddressEditPage();
        },
      ),
    );
    debugPrint("result=$result");
  }

  _gotoTemplateSelectPageEditPage(BuildContext context) async {
    Uint8List? result = await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
          //TODO: 設定image
          // 轉換方法
          // XFile xfile = ...;
          // File file = File(xfile.path);
          // Uint8List bytes = file.readAsBytesSync();
          return TemplateSelectPage(image: null);
        },
      ),
    );

    //正式版不用
    if (mounted && result != null) {
      // TODO:打開
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "Uint8List length: ${result.length}",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      )));

      final blob = html.Blob([result], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement()
        ..href = url
        ..download = 'postory.png'
        ..click();
    }

    // if (kIsWeb && result != null) html.File([result], "Postory.png", {"type": "image/png"});
    // if (!kIsWeb && result != null) Share.shareXFiles([XFile.fromData(result)], subject: "Postory", text: "Export Image");
    // debugPrint("Uint8List length=${result?.length}");
  }

  //FIXME：這邊要打開
  void _downloadFile(String url) {
    // TODO:打開
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.download = "postory_train_ui.zip";
    anchorElement.click();
  }
}
