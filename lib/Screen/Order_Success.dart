import 'dart:async';

import 'package:berfy/Helper/Color.dart';
import 'package:berfy/Helper/Session.dart';
import 'package:berfy/Screen/MyOrder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Helper/String.dart';
import '../ui/styles/DesignConfig.dart';
import '../ui/widgets/AppBarWidget.dart';

class OrderSuccess extends StatefulWidget {
  final String? url;
  const OrderSuccess({this.url, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateSuccess();
  }
}

class StateSuccess extends State<OrderSuccess> {
  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: colors.whiteTemp,
      appBar: getAppBar(getTranslated(context, 'ORDER_PLACED')!, context),
      body: Center(
        child: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              margin: const EdgeInsets.symmetric(vertical: 40),
              child: SvgPicture.asset(
                "${imagePath}bags.svg",
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                getTranslated(context, 'ORD_PLC')!,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).colorScheme.fontColor),
              ),
            ),
            Text(
              getTranslated(context, 'ORD_PLC_SUCC')!,
              style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 28.0),
              child: CupertinoButton(
                child: Container(
                    width: deviceWidth! * 0.7,
                    height: 45,
                    alignment: FractionalOffset.center,
                    decoration: const BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Text("Go to Orders",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.white,
                            fontWeight: FontWeight.normal))),
                onPressed: () async {
                  // if (widget.url != null && widget.url != "") {
                  //   final Uri url = Uri.parse("${widget.url}");
                  //   if (!await launchUrl(url)) {
                  //     throw Exception('Could not launch $widget.url');
                  //   }
                  // } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/home', (Route<dynamic> route) => false);
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const MyOrder(),
                      ));

                  // }
                },
              ),
            )
          ],
        )),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      _launchURL();
    });
  }

  Future<void> _launchURL() async {
    if (await canLaunch(widget.url!)) {
      await launch(widget.url!);
    } else {
      throw 'Could not launch ${widget.url!}';
    }
  }
}
