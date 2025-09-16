import 'dart:async';
import 'dart:convert';
import 'package:berfy/Provider/SettingProvider.dart';
import 'package:berfy/Provider/UserProvider.dart';
import 'package:berfy/Screen/Intro_Slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import 'package:flutter_svg/flutter_svg.dart';

//splash screen of app
class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<Splash> {
  bool from = false;

  @override
  void initState() {
    super.initState();
    //setToken();
    startTime();
  }

  void setToken() async {
    FirebaseMessaging.instance.getToken().then(
      (token) async {
        SettingProvider settingsProvider =
            Provider.of<SettingProvider>(context, listen: false);

        String getToken = await settingsProvider.getPrefrence(FCMTOKEN) ?? '';
        print("fcm token****$token");
        if (token != getToken && token != null) {
          print("register token***$token");
          registerToken(token);
        }
      },
    );
  }

  void registerToken(String? token) async {
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(context, listen: false);
    var parameter = {
      FCM_ID: token,
    };
    if (context.read<UserProvider>().userId != "") {
      parameter[USER_ID] = context.read<UserProvider>().userId;
    }

    Response response =
        await post(updateFcmApi, body: parameter, headers: headers)
            .timeout(const Duration(seconds: timeOut));

    var getdata = json.decode(response.body);

    print("param noti fcm***$parameter");

    print("value notification****$getdata");

    if (getdata['error'] == false) {
      print("fcm token****$token");
      settingsProvider.setPrefrence(FCMTOKEN, token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return Scaffold(
      backgroundColor: colors.blackTemp,
      body: Stack(
        children: <Widget>[
          // Image.asset(
          //   'assets/images/doodle.jpeg',
          //   width: double.infinity,
          //   height: double.infinity,
          //   fit: BoxFit.cover,
          // ),
            Center(
              child: Container(
                // decoration: BoxDecoration( 
                //   boxShadow: [
                //     BoxShadow(
                //       color: colors.primary,
                //       spreadRadius: 2,
                //       blurRadius: 5,
                //       offset: const Offset(
                //           0, 0), // changes position of shadow
                //     ),
                //   ],
                //   border: Border.all(width: 3,color: colors.primary)),
                height: 300,
                width: 300,
                child: Image.asset(
                  'assets/images/splashlogo.png',
                ),
              ),
            ),
          
        ],
      ),
    );
  }

  startTime() async {
    var duration = const Duration(seconds: 2);
    return Timer(duration, navigationPage);
  }

  Future<void> navigationPage() async {
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(context, listen: false);

    bool isFirstTime = await settingsProvider.getPrefrenceBool(ISFIRSTTIME);

    if (isFirstTime) {
      setState(() {
        from = true;
      });

      Navigator.pushReplacementNamed(context, "/home");
    } else {
      setState(() {
        from = false;
      });
      Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => const IntroSlider(),
          ));
    }
  }

  @override
  void dispose() {
    if (from) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    }
    super.dispose();
  }
}
