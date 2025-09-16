import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:berfy/Helper/Color.dart';
import 'package:berfy/Helper/PushNotificationService.dart';
import 'package:berfy/Helper/Session.dart';
import 'package:berfy/Helper/SqliteData.dart';
import 'package:berfy/Helper/String.dart';
import 'package:berfy/Model/Section_Model.dart';
import 'package:berfy/Provider/HomeProvider.dart';
import 'package:berfy/Provider/UserProvider.dart';
import 'package:berfy/Screen/Favorite.dart';
import 'package:berfy/Screen/Login.dart';
import 'package:berfy/Screen/MyProfile.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:bottom_bar/bottom_bar.dart';

import '../Provider/SettingProvider.dart';
import '../ui/styles/DesignConfig.dart';
import 'All_Category.dart';

import 'HomePage.dart';
import 'NotificationLIst.dart';
import 'Product_DetailNew.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

GlobalKey<HomePageState>? dashboardPageState;

class HomePageState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  var db = DatabaseHelper();
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  late AnimationController navigationContainerAnimationController =
      AnimationController(
    vsync: this, // the SingleTickerProviderStateMixin
    duration: const Duration(milliseconds: 400),
  );

  bool _isNetworkAvail = true;
  final PageController _pageController = PageController();
  int _selBottom = 0;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final pushNotificationService = PushNotificationService(context: context);
      pushNotificationService.initialise();
    });
    initDynamicLinks();
    //dashboardPageState = GlobalKey<HomePageState>();
    db.getTotalCartCount(context);
    /* final pushNotificationService = PushNotificationService(
        context: context, pageController: _pageController);
    pushNotificationService.initialise(); */

    Future.delayed(Duration.zero, () async {
      SettingProvider settingsProvider =
          Provider.of<SettingProvider>(context, listen: false);
      context
          .read<UserProvider>()
          .setUserId(await settingsProvider.getPrefrence(ID) ?? '');

      context
          .read<HomeProvider>()
          .setAnimationController(navigationContainerAnimationController);
    });
  }

  changeTabPosition(int index) {
    Future.delayed(Duration.zero, () {
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  void initDynamicLinks() async {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      final Uri deepLink = dynamicLinkData.link;

      if (deepLink.queryParameters.isNotEmpty) {
        int index = int.parse(deepLink.queryParameters['index']!);

        int secPos = int.parse(deepLink.queryParameters['secPos']!);

        String? id = deepLink.queryParameters['id'];

        String? list = deepLink.queryParameters['list'];

        getProduct(id!, index, secPos, list == "true" ? true : false);
      }
    }).onError((e) {
      print(e.message);
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      if (deepLink.queryParameters.isNotEmpty) {
        int index = int.parse(deepLink.queryParameters['index']!);

        int secPos = int.parse(deepLink.queryParameters['secPos']!);

        String? id = deepLink.queryParameters['id'];

        getProduct(id!, index, secPos, true);
      }
    }
  }

  Future<void> getProduct(String id, int index, int secPos, bool list) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          ID: id,
        };

        apiBaseHelper.postAPICall(getProductApi, parameter).then((getdata) {
          bool error = getdata["error"];
          String msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            List<Product> items = [];

            items =
                (data as List).map((data) => Product.fromJson(data)).toList();
            currentHero = homeHero;
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => ProductDetail(
                      index: list ? int.parse(id) : index,
                      id: list
                          ? items[0].id!
                          : sectionList[secPos].productList![index].id!,
                      secPos: secPos,
                      list: list,
                    )));
          } else {
            if (msg != "Products Not Found !") setSnackbar(msg, context);
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      {
        if (mounted) {
          setState(() {
            setSnackbar(getTranslated(context, 'NO_INTERNET_DISC')!, context);
          });
        }
      }
    }
  }

  AppBar _getAppBar() {
    String? title;
    if (_selBottom == 1) {
      title = "Favourites";
    } else if (_selBottom == 2) {
      title = "Profile";
      // } else if (_selBottom == 3) {
      //   title = "Category";
      // } else if (_selBottom == 4) {
      //   title = "My Bag";
    }
    String imageasset = "";
    // if (_selBottom == 3) {
    //   imageasset = "assets/images/category01.svg";
    // } else
    if (_selBottom == 1) {
      imageasset = "assets/images/desel_fav_selected.svg";
    } else if (_selBottom == 2) {
      imageasset = "assets/images/profile01.svg";
      // } else if (_selBottom == 4) {
      //   imageasset = "assets/images/cart01.svg";
    }

    return AppBar(
      elevation: 0,
      toolbarHeight: 62,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: _selBottom == 0
          ? Row(
              children: [
                Image.asset(
                  'assets/images/splashlogo_.png',
                  height: 40,
                  width: 40,
                  // colorFilter:
                  //     const ColorFilter.mode(colors.primary, BlendMode.srcIn),
                ),
                SizedBox(
                  width: 5,
                ),
                AnimatedTextKit(repeatForever: true, animatedTexts: [
                  TyperAnimatedText("Welcome to Berfy",
                      textStyle: const TextStyle(
                          fontFamily: "BodoniModa",
                          fontSize: 18,
                          color: colors.primary,
                          fontWeight: FontWeight.bold),
                      speed: const Duration(milliseconds: 120)),
                  TyperAnimatedText("Start Earning",
                      textStyle: const TextStyle(
                          fontFamily: "BodoniModa",
                          fontSize: 18,
                          color: colors.primary,
                          fontWeight: FontWeight.bold),
                      speed: const Duration(milliseconds: 120)),
                  TyperAnimatedText("Easy Withdrawl",
                      textStyle: const TextStyle(
                          fontFamily: "BodoniModa",
                          fontSize: 18,
                          color: colors.primary,
                          fontWeight: FontWeight.bold),
                      speed: const Duration(milliseconds: 120)),
                  TyperAnimatedText("Guaranted Returns",
                      textStyle: const TextStyle(
                          fontFamily: "BodoniModa",
                          fontSize: 18,
                          color: colors.primary,
                          fontWeight: FontWeight.bold),
                      speed: const Duration(milliseconds: 120)),
                ]),

                // Center(
                //   child: Text(
                //     " Berfy",
                //     style: const TextStyle(
                //       fontFamily: "Rochester",
                //         fontSize: 24,
                //         color: colors.primary, fontWeight: FontWeight.bold),
                //   ),
                // )
              ],
            )
          : Row(
              children: [
                SizedBox(
                  width: 8,
                ),
                SvgPicture.asset(imageasset,
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                        colors.primary, BlendMode.srcIn)),
                SizedBox(
                  width: 8,
                ),
                Text(
                  title!,
                  style: const TextStyle(
                      fontFamily: "BodoniModa",
                      fontSize: 18,
                      color: colors.primary,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
      actions: <Widget>[
        IconButton(
          icon: SvgPicture.asset(
            "${imagePath}desel_notification.svg",
            colorFilter:
                const ColorFilter.mode(colors.primary, BlendMode.srcIn),
          ),
          onPressed: () {
            context.read<UserProvider>().userId != ""
                ? Navigator.push<bool>(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const NotificationList(),
                    )).then((value) {
                    if (value != null && value) {
                      _pageController.jumpToPage(1);
                    }
                  })
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Login(
                              classType: Dashboard(
                                  //key: dashboardPageState,
                                  ),
                              isPop: true,
                            )),
                  );
          },
        ),
        // IconButton(
        //   padding: const EdgeInsets.all(0),
        //   icon: SvgPicture.asset(
        //     "${imagePath}desel_fav.svg",
        //     colorFilter:
        //         const ColorFilter.mode(colors.primary, BlendMode.srcIn),
        //   ),
        //   onPressed: () {
        //     Navigator.push(
        //         context,
        //         CupertinoPageRoute(
        //           builder: (context) => const Favorite(fromBottom: false,),
        //         ));
        //   },
        // ),
      ],
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
    );
  }

  Widget _getBottomBar() {
    return Container(
      // height: ,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: BottomBar(
        height: 60,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        selectedIndex: _selBottom,
        onTap: (int index) {
          _pageController.jumpToPage(index);
          setState(() => _selBottom = index);
        },

        //itemPadding: EdgeInsets.zero,
        items: <BottomBarItem>[
          BottomBarItem(
            icon: _selBottom == 0
                ? SvgPicture.asset(
                    "${imagePath}sel_home.svg",
                    colorFilter:
                        const ColorFilter.mode(colors.primary, BlendMode.srcIn),
                    width: 18,
                    height: 20,
                  )
                : SvgPicture.asset(
                    "${imagePath}desel_home.svg",
                    colorFilter:
                        const ColorFilter.mode(colors.primary, BlendMode.srcIn),
                    width: 18,
                    height: 20,
                  ),
            title: Text(
                getTranslated(
                  context,
                  'HOME_LBL',
                )!,
                overflow: TextOverflow.ellipsis,
                softWrap: true),
            activeColor: colors.primary,
          ),
          BottomBarItem(
            icon: _selBottom == 1
                ? SvgPicture.asset(
                    "${imagePath}desel_fav_selected.svg",
                    colorFilter:
                        const ColorFilter.mode(colors.primary, BlendMode.srcIn),
                    width: 18,
                    height: 20,
                  )
                : SvgPicture.asset(
                    "${imagePath}desel_fav.svg",
                    colorFilter:
                        const ColorFilter.mode(colors.primary, BlendMode.srcIn),
                    width: 18,
                    height: 20,
                  ),
            title: Text("Favourites",
                overflow: TextOverflow.ellipsis, softWrap: true),
            activeColor: colors.primary,
          ),
          BottomBarItem(
            icon: _selBottom == 2
                ? SvgPicture.asset(
                    "${imagePath}profile01.svg",
                    colorFilter:
                        const ColorFilter.mode(colors.primary, BlendMode.srcIn),
                    width: 18,
                    height: 20,
                  )
                : SvgPicture.asset(
                    "${imagePath}profile.svg",
                    width: 18,
                    height: 20,
                    colorFilter:
                        const ColorFilter.mode(colors.primary, BlendMode.srcIn),
                  ),
            title: Text(getTranslated(context, 'PROFILE')!,
                overflow: TextOverflow.ellipsis, softWrap: true),
            activeColor: colors.primary,
          ),
          // BottomBarItem(
          //     icon: _selBottom == 1
          //         ? SvgPicture.asset(
          //             "${imagePath}category01.svg",
          //             colorFilter: const ColorFilter.mode(
          //                 colors.primary, BlendMode.srcIn),
          //             width: 18,
          //             height: 18,
          //           )
          //         : SvgPicture.asset(
          //             "${imagePath}category.svg",
          //             colorFilter: const ColorFilter.mode(
          //                 colors.primary, BlendMode.srcIn),
          //             width: 18,
          //             height: 18,
          //           ),
          //     title: Text(getTranslated(context, 'category')!,
          //         overflow: TextOverflow.ellipsis, softWrap: true),
          //     activeColor: colors.primary),

          // BottomBarItem(
          //   icon: Selector<UserProvider, String>(
          //     builder: (context, data, child) {
          //       return Stack(
          //         children: [
          //           _selBottom == 4
          //               ? SvgPicture.asset(
          //                   "${imagePath}cart01.svg",
          //                   colorFilter: const ColorFilter.mode(
          //                       colors.primary, BlendMode.srcIn),
          //                   width: 18,
          //                   height: 20,
          //                 )
          //               : SvgPicture.asset(
          //                   "${imagePath}cart.svg",
          //                   colorFilter: const ColorFilter.mode(
          //                       colors.primary, BlendMode.srcIn),
          //                   width: 18,
          //                   height: 20,
          //                 ),
          //           (data.isNotEmpty && data != "0")
          //               ? Positioned.directional(
          //                   end: 0,
          //                   textDirection: Directionality.of(context),
          //                   top: 0,
          //                   child: Container(
          //                       decoration: const BoxDecoration(
          //                           shape: BoxShape.circle,
          //                           color: colors.primary),
          //                       child: Center(
          //                         child: Padding(
          //                           padding: const EdgeInsets.all(3),
          //                           child: Text(
          //                             data,
          //                             style: TextStyle(
          //                                 fontSize: 7,
          //                                 fontWeight: FontWeight.bold,
          //                                 color: Theme.of(context)
          //                                     .colorScheme
          //                                     .white),
          //                           ),
          //                         ),
          //                       )),
          //                 )
          //               : const SizedBox.shrink()
          //         ],
          //       );
          //     },
          //     selector: (_, homeProvider) => homeProvider.curCartCount,
          //   ),
          //   title: Text(getTranslated(context, 'CART')!,
          //       overflow: TextOverflow.ellipsis, softWrap: true),
          //   activeColor: colors.primary,
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selBottom != 0) {
          _pageController.animateToPage(0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut);
          return false;
        }
        return true;
      },
      child: SafeArea(
          top: false,
          bottom: true,
          child: Consumer<UserProvider>(builder: (context, data, child) {
            return Scaffold(
              extendBody: true,
              backgroundColor: Theme.of(context).colorScheme.lightWhite,
              appBar: _getAppBar(),
              body: PageView(
                controller: _pageController,
                children: const [
                  HomePage(),
                  //FlashSale(),
                  // Sale(),
                  Favorite(
                    fromBottom: true,
                  ),

                  MyProfile(),

                  // AllCategory(),

                  // Cart(
                  //   fromBottom: true,
                  // ),
                ],
                onPageChanged: (index) {
                  setState(() {
                    if (!context
                        .read<HomeProvider>()
                        .animationController
                        .isAnimating) {
                      context
                          .read<HomeProvider>()
                          .animationController
                          .reverse();
                      context.read<HomeProvider>().showBars(true);
                    }
                    _selBottom = index;
                    // if (index == 4) {
                    //   cartTotalClear();
                    // }
                  });
                },
              ),
              bottomNavigationBar: _getBottomBar(),
            );
          })),
    );
  }
}
