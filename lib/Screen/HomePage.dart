import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/properties/phone.dart';
import 'package:berfy/Helper/ApiBaseHelper.dart';
import 'package:berfy/Helper/Color.dart';
import 'package:berfy/Helper/Constant.dart';
import 'package:berfy/Helper/Session.dart';
import 'package:berfy/Helper/SqliteData.dart';
import 'package:berfy/Helper/String.dart';
import 'package:berfy/Model/Faqs_Model.dart';
import 'package:berfy/Model/Model.dart';
import 'package:berfy/Model/OfferImages.dart';
import 'package:berfy/Model/Section_Model.dart';
import 'package:berfy/Provider/CartProvider.dart';
import 'package:berfy/Provider/CategoryProvider.dart';
import 'package:berfy/Provider/FavoriteProvider.dart';
import 'package:berfy/Provider/HomeProvider.dart';
import 'package:berfy/Provider/SettingProvider.dart';
import 'package:berfy/Provider/UserProvider.dart';
import 'package:berfy/Screen/Search.dart';
import 'package:berfy/Screen/SubCategory.dart';
import 'package:berfy/ui/widgets/AppBtn.dart';
import 'package:berfy/ui/widgets/SimBtn.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';
import 'package:berfy/Provider/SettingProvider.dart';

import '../Provider/ProductProvider.dart';
import '../ui/styles/DesignConfig.dart';
import '../ui/styles/Validators.dart';
import 'ProductList.dart';
import 'Product_DetailNew.dart';
import 'SectionList.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

List<SectionModel> sectionList = [];
List<Product> catList = [];
List<Product> popularList = [];
ApiBaseHelper apiBaseHelper = ApiBaseHelper();
List<String> tagList = [];
List<Product> sellerList = [];
List<Model> homeSliderList = [];
List<Widget> pages = [];
int count = 1;

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage>, TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  final _controller = PageController();
  late Animation buttonSqueezeanimation;
  late AnimationController buttonController;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

//  List<Model> offerImages = [];
  final ScrollController _scrollBottomBarController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  double beginAnim = 0.0;

  double endAnim = 1.0;
  var db = DatabaseHelper();
  List<String> proIds = [];
  List<Product> mostLikeProList = [];
  List<String> proIds1 = [];
  List<Product> mostFavProList = [];
  PopUpOfferImage popUpOffer = PopUpOfferImage();

  String? pincode;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    callApi();
    getFaqs();

    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) => _animateSlider());
  }

  @override
  void dispose() {
    _scrollBottomBarController.removeListener(() {});
    _controller.dispose();
    buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(context, listen: false);

    hideAppbarAndBottomBarOnScroll(_scrollBottomBarController, context);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.lightWhite,
        body: _isNetworkAvail
            ? RefreshIndicator(
                color: colors.primary,
                key: _refreshIndicatorKey,
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  controller: _scrollBottomBarController,
                  child: Column(
                    children: [
                      // _deliverPincode(),
                      // _getSearchBar(),
                      homeSliderList.length > 0
                          ? Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0))),
                              padding: EdgeInsets.only(
                                top: 15,
                                left: 10,
                                right: 10,
                              ),
                              child: _slider())
                          : Container(),
                      //_catList(),
                      _section(),
                      // Container(
                      //   alignment: Alignment.centerLeft,
                      //   margin: EdgeInsets.symmetric(horizontal:8,),
                      //   padding: EdgeInsets.only(left:5,bottom: 3.0,top:15),
                      //   decoration: BoxDecoration(
                      //     border: Border(
                      //        bottom: BorderSide( //
                      //         color: colors.primary,
                      //         width: 1,
                      //       ),
                      //     )
                      //   ),
                      //   child: Text(
                      //     "Follow us on",
                      //     style:TextStyle(
                      //       color: colors.primary,
                      //       fontWeight: FontWeight.bold,
                      //       fontSize: 18
                      //     )
                      //   ),
                      // ),

                      // Container(
                      //   alignment: Alignment.centerLeft,
                      //   padding: EdgeInsets.only(left: 10,top:5,right:10),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Expanded(
                      //         child: Container(
                      //           decoration: BoxDecoration(
                      //             border: Border(
                      //               bottom: BorderSide( //
                      //                 color: colors.primary,
                      //                 width: 1,
                      //               ),
                      //             ),
                      //           ),
                      //           child: Text(
                      //             "Follow us on",
                      //             style:TextStyle(
                      //               color: colors.primary,
                      //               fontWeight: FontWeight.bold,
                      //               fontSize: 18
                      //             )
                      //           ),
                      //         ),
                      //       ),
                      //       Container(
                      //         child: Row(
                      //           mainAxisSize: MainAxisSize.max,
                      //           mainAxisAlignment: MainAxisAlignment.end,
                      //           children: [
                      //             // Container(
                      //             //   decoration: BoxDecoration(
                      //             //     border:Border.all(width: 2, color:colors.primary),
                      //             //     borderRadius: BorderRadius.circular(14.0),
                      //             //   ),
                      //             //   margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                      //             //   child: Image.asset(
                      //             //     'assets/images/follow_facebook.png',
                      //             //     width: 32,
                      //             //     height: 32
                      //             //   ),
                      //             // ),
                      //             Container(
                      //               decoration: BoxDecoration(
                      //                 border:Border.all(width: 1, color:colors.primary),
                      //                 borderRadius: BorderRadius.circular(8.0),
                      //               ),
                      //               margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                      //               child: Image.asset(
                      //                 'assets/images/follow_instagram.png',
                      //                 width: 32,
                      //                 height: 32
                      //               ),
                      //             ),
                      //             Container(
                      //               decoration: BoxDecoration(
                      //                 border:Border.all(width: 1, color:colors.primary),
                      //                 borderRadius: BorderRadius.circular(8.0),
                      //               ),
                      //               margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                      //               child: Image.asset(
                      //                 'assets/images/follow_whatsapp.png',
                      //                 width: 32,
                      //                 height: 32
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),

                      //    ],
                      //   ),
                      // ),

                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        padding: EdgeInsets.only(left: 5, bottom: 3.0, top: 15),
                        decoration: BoxDecoration(
                            border: Border(
                          bottom: BorderSide(
                            //
                            color: colors.primary,
                            width: 1,
                          ),
                        )),
                        child: Text("Why Buy From us",
                            style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                      ),
                      _showForm(context),
                      // _mostLike(),
                    ],
                  ),
                ))
            : noInternet(context));
  }

  Future<void> _refresh() {
    context.read<HomeProvider>().setCatLoading(true);
    context.read<HomeProvider>().setSecLoading(true);
    context.read<HomeProvider>().setOfferLoading(true);
    context.read<HomeProvider>().setMostLikeLoading(true);
    context.read<HomeProvider>().setSliderLoading(true);
    context.read<CategoryProvider>().setCurSelected(0);
    proIds.clear();

    return callApi();
  }

  Widget _slider() {
    double height = deviceWidth! / 2.2;

    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? sliderLoading()
            : Stack(
                children: [
                  SizedBox(
                    height: height,
                    width: double.infinity,
                    child: PageView.builder(
                      itemCount: homeSliderList.length,
                      scrollDirection: Axis.horizontal,
                      controller: _controller,
                      physics: const AlwaysScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          context.read<HomeProvider>().setCurSlider(index);
                        });
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return pages[index];
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    height: 40,
                    left: 0,
                    width: deviceWidth,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: map<Widget>(
                        homeSliderList,
                        (index, url) {
                          return AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              width: context.read<HomeProvider>().curSlider ==
                                      index
                                  ? 25
                                  : 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: context.read<HomeProvider>().curSlider ==
                                        index
                                    ? Theme.of(context).colorScheme.fontColor
                                    : Theme.of(context)
                                        .colorScheme
                                        .lightBlack
                                        .withOpacity(0.7),
                              ));
                        },
                      ),
                    ),
                  ),
                ],
              );
      },
      selector: (_, homeProvider) => homeProvider.sliderLoading,
    );
  }

  void _animateSlider() {
    Future.delayed(const Duration(seconds: 10)).then((_) {
      if (mounted) {
        int nextPage = _controller.hasClients
            ? _controller.page!.round() + 1
            : _controller.initialPage;

        if (nextPage == homeSliderList.length) {
          nextPage = 0;
        }
        if (_controller.hasClients) {
          _controller
              .animateToPage(nextPage,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.linear)
              .then((_) {
            _animateSlider();
          });
        }
      }
    });
  }

  _singleSection(int index) {
    Color back;
    int pos = index % 5;
    if (pos == 0) {
      back = Theme.of(context).colorScheme.back1;
    } else if (pos == 1) {
      back = Theme.of(context).colorScheme.back2;
    } else if (pos == 2) {
      back = Theme.of(context).colorScheme.back3;
    } else if (pos == 3) {
      back = Theme.of(context).colorScheme.back4;
    } else {
      back = Theme.of(context).colorScheme.back5;
    }

    return sectionList[index].productList!.isNotEmpty
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 40),
                        // decoration: BoxDecoration(
                        //     color: back,
                        //     borderRadius: const BorderRadius.only(
                        //         topLeft: Radius.circular(20),
                        //         topRight: Radius.circular(20)))
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // _getHeading(
                        //     sectionList[index].title ?? "", index, 1, []),
                        _getSection(index),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }

  _getHeading(String title, int index, int from, List<Product> productList) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.primary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFamily: "BodoniModa",
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(from == 2 ? title : sectionList[index].shortDesc ?? "",
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: colors.primary,
                  fontFamily: "Dynalight",
                  fontSize: 14)),
          // TextButton(
          //     child: Text(
          //       "View Collection",
          //       style: TextStyle(
          //           color: Theme.of(context).colorScheme.fontColor,
          //           fontWeight: FontWeight.bold),
          //     ),
          //     onPressed: () {
          //       SectionModel model = sectionList[index];
          //       Navigator.push(
          //           context,
          //           CupertinoPageRoute(
          //             builder: (context) => SectionList(
          //               index: index,
          //               section_model: model,
          //               from: from,
          //               productList: productList,
          //             ),
          //           ));
          //     }),
        ],
      ),
    );
  }

/*  _getOfferImage(index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: InkWell(
        child: CachedNetworkImage(
            imageUrl: offerImages[index].image!,
            fadeInDuration: const Duration(milliseconds: 150),
            width: double.maxFinite,
            errorWidget: (context, error, stackTrace) => erroWidget(50),

            // errorWidget: (context, url, e) => return return placeHolder(50),
            placeholder: (BuildContext context, url) {
              return Image.asset(
                "assets/images/sliderph.png",
              );
            }),
        onTap: () {
          if (offerImages[index].type == "products") {
            Product? item = offerImages[index].list;
            currentHero = homeHero;
            Navigator.push(
              context,
              PageRouteBuilder(
                  //transitionDuration: Duration(seconds: 1),
                  pageBuilder: (_, __, ___) => ProductDetail(
                        secPos: 0, index: 0, list: true, id: item!.id!,
                        //  title: sectionList[secPos].title,
                      )),
            );
          } else if (offerImages[index].type == "categories") {
            Product item = offerImages[index].list;
            if (item.subList == null || item.subList!.isEmpty) {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => ProductList(
                      name: item.name,
                      id: item.id,
                      tag: false,
                      fromSeller: false,
                    ),
                  ));
            } else {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => SubCategory(
                      title: item.name!,
                      subList: item.subList,
                    ),
                  ));
            }
          }
        },
      ),
    );
  }*/

  _getSection(int i) {
    var orient = MediaQuery.of(context).orientation;

    return sectionList[i].style == DEFAULT
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: sectionList[i].style == STYLE1
                  ? deviceWidth! * 1.0
                  : MediaQuery.of(context).size.width * 0.85,
              child: GridView.count(
                padding: const EdgeInsetsDirectional.only(top: 5),
                crossAxisCount: 1, // Change this to 1 for horizontal scrolling
                scrollDirection:
                    Axis.horizontal, // Set scroll direction to horizontal
                shrinkWrap: true,
                // childAspectRatio: 0.8,
                physics:
                    const AlwaysScrollableScrollPhysics(), // Allow scrolling
                children: List.generate(
                  sectionList[i].productList!.length < 10
                      ? sectionList[i].productList!.length
                      : 10,
                  (index) {
                    return productItem(
                      i,
                      index,
                      true,
                      sectionList[i].productList![index],
                      1,
                      sectionList[i].productList!.length,
                    );
                  },
                ),
              ),
            ),
          )
        : sectionList[i].style == STYLE1
            ? Padding(
                padding: const EdgeInsets.all(4.0),
                child: GridView.builder(
                  padding: const EdgeInsetsDirectional.only(top: 5),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // vertical gap between items
                  ),
                  scrollDirection:
                      Axis.vertical, // Set scroll direction to vertical
                  shrinkWrap: true,
                  physics:
                      NeverScrollableScrollPhysics(), // Never allow scrolling
                  itemCount: sectionList[i].productList!.length,
                  itemBuilder: (BuildContext context, int index) {
                    final itemWidth = MediaQuery.of(context).size.width / 2;
                    final itemHeight =
                        itemWidth * 2; // Height is twice the width
                    return SizedBox(
                      width: itemWidth,
                      height: itemHeight,
                      child: productItem(
                        i,
                        index,
                        true,
                        sectionList[i].productList![index],
                        1,
                        sectionList[i].productList!.length,
                      ),
                    );
                  },
                ),
                // GridView.count(
                //   padding: const EdgeInsetsDirectional.only(top: 5),
                //   crossAxisCount:
                //       1, // Change this to 1 for horizontal scrolling
                //   scrollDirection:
                //       Axis.vertical, // Set scroll direction to horizontal
                //   shrinkWrap: true,
                //   // childAspectRatio: 0.8,
                //   physics:
                //       const AlwaysScrollableScrollPhysics(), // Allow scrolling
                //   children: List.generate(
                //     sectionList[i].productList!.length < 10
                //         ? sectionList[i].productList!.length
                //         : 10,
                //     (index) {
                //       return productItem(
                //         i,
                //         index,
                //         true,
                //         sectionList[i].productList![index],
                //         1,
                //         sectionList[i].productList!.length,
                //       );
                //     },
                //   ),
                // ),
              )
            : sectionList[i].style == STYLE2
                ? sectionList[i].productList!.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Flexible(
                                flex: 3,
                                fit: FlexFit.loose,
                                child: SizedBox(
                                    height: orient == Orientation.portrait
                                        ? deviceHeight! * 0.4
                                        : deviceHeight,
                                    child: sectionList[i].productList!.length ==
                                                1 ||
                                            sectionList[i].productList!.length >
                                                1
                                        ? productItem(
                                            i,
                                            0,
                                            true,
                                            sectionList[i].productList![0],
                                            1,
                                            sectionList[i].productList!.length)
                                        : const SizedBox.shrink())),
                            Flexible(
                              flex: 2,
                              fit: FlexFit.loose,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                      height: orient == Orientation.portrait
                                          ? deviceHeight! * 0.2
                                          : deviceHeight! * 0.5,
                                      child: sectionList[i]
                                                      .productList!
                                                      .length ==
                                                  2 ||
                                              sectionList[i]
                                                      .productList!
                                                      .length >
                                                  2
                                          ? productItem(
                                              i,
                                              1,
                                              false,
                                              sectionList[i].productList![1],
                                              1,
                                              sectionList[i]
                                                  .productList!
                                                  .length)
                                          : const SizedBox.shrink()),
                                  SizedBox(
                                      height: orient == Orientation.portrait
                                          ? deviceHeight! * 0.2
                                          : deviceHeight! * 0.5,
                                      child: sectionList[i]
                                                      .productList!
                                                      .length ==
                                                  3 ||
                                              sectionList[i]
                                                      .productList!
                                                      .length >
                                                  3
                                          ? productItem(
                                              i,
                                              2,
                                              false,
                                              sectionList[i].productList![2],
                                              1,
                                              sectionList[i]
                                                  .productList!
                                                  .length)
                                          : const SizedBox.shrink()),
                                ],
                              ),
                            ),
                          ],
                        ))
                    : const SizedBox.shrink()
                : sectionList[i].style == STYLE2
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 2,
                              fit: FlexFit.loose,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                      height: orient == Orientation.portrait
                                          ? deviceHeight! * 0.2
                                          : deviceHeight! * 0.5,
                                      child: sectionList[i]
                                                      .productList!
                                                      .length ==
                                                  1 ||
                                              sectionList[i]
                                                      .productList!
                                                      .length >
                                                  1
                                          ? productItem(
                                              i,
                                              0,
                                              true,
                                              sectionList[i].productList![0],
                                              1,
                                              sectionList[i]
                                                  .productList!
                                                  .length)
                                          : const SizedBox.shrink()),
                                  SizedBox(
                                      height: orient == Orientation.portrait
                                          ? deviceHeight! * 0.2
                                          : deviceHeight! * 0.5,
                                      child: sectionList[i]
                                                      .productList!
                                                      .length ==
                                                  2 ||
                                              sectionList[i]
                                                      .productList!
                                                      .length >
                                                  2
                                          ? productItem(
                                              i,
                                              1,
                                              true,
                                              sectionList[i].productList![1],
                                              1,
                                              sectionList[i]
                                                  .productList!
                                                  .length)
                                          : const SizedBox.shrink()),
                                ],
                              ),
                            ),
                            Flexible(
                                flex: 3,
                                fit: FlexFit.loose,
                                child: SizedBox(
                                    height: orient == Orientation.portrait
                                        ? deviceHeight! * 0.4
                                        : deviceHeight,
                                    child: sectionList[i].productList!.length ==
                                                3 ||
                                            sectionList[i].productList!.length >
                                                3
                                        ? productItem(
                                            i,
                                            2,
                                            false,
                                            sectionList[i].productList![2],
                                            1,
                                            sectionList[i].productList!.length)
                                        : const SizedBox.shrink())),
                          ],
                        ))
                    : sectionList[i].style == STYLE3
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                      flex: 1,
                                      fit: FlexFit.loose,
                                      child: Container(
                                          // decoration: BoxDecoration(
                                          //   boxShadow: [
                                          //     BoxShadow(
                                          //       color: colors.primary,
                                          //       blurRadius: 5.0,
                                          //       ),

                                          //   ],
                                          // ),
                                          height: orient == Orientation.portrait
                                              ? deviceWidth!
                                              : deviceHeight! * 0.6,
                                          child: sectionList[i]
                                                          .productList!
                                                          .length ==
                                                      1 ||
                                                  sectionList[i]
                                                          .productList!
                                                          .length >
                                                      1
                                              ? productItem(
                                                  i,
                                                  0,
                                                  false,
                                                  sectionList[i]
                                                      .productList![0],
                                                  1,
                                                  sectionList[i]
                                                      .productList!
                                                      .length)
                                              : const SizedBox.shrink())),
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    // decoration: BoxDecoration(
                                    //   boxShadow: [
                                    //     BoxShadow(
                                    //       color: colors.primary,
                                    //       blurRadius: 5.0,
                                    //       ),

                                    //   ],
                                    // ),
                                    height: orient == Orientation.portrait
                                        ? deviceHeight! * 0.2
                                        : deviceHeight! * 0.5,
                                    child: Row(
                                      children: [
                                        Flexible(
                                            flex: 1,
                                            fit: FlexFit.loose,
                                            child: sectionList[i]
                                                            .productList!
                                                            .length >=
                                                        2 ||
                                                    sectionList[i]
                                                            .productList!
                                                            .length >
                                                        2
                                                ? productItem(
                                                    i,
                                                    1,
                                                    true,
                                                    sectionList[i]
                                                        .productList![1],
                                                    1,
                                                    sectionList[i]
                                                        .productList!
                                                        .length)
                                                : const SizedBox.shrink()),
                                        Flexible(
                                            flex: 1,
                                            fit: FlexFit.loose,
                                            child: sectionList[i]
                                                            .productList!
                                                            .length ==
                                                        3 ||
                                                    sectionList[i]
                                                            .productList!
                                                            .length >
                                                        3
                                                ? productItem(
                                                    i,
                                                    2,
                                                    true,
                                                    sectionList[i]
                                                        .productList![2],
                                                    1,
                                                    sectionList[i]
                                                        .productList!
                                                        .length)
                                                : const SizedBox.shrink()),
                                        Flexible(
                                            flex: 1,
                                            fit: FlexFit.loose,
                                            child: sectionList[i]
                                                        .productList!
                                                        .length >=
                                                    4
                                                ? productItem(
                                                    i,
                                                    3,
                                                    false,
                                                    sectionList[i]
                                                        .productList![3],
                                                    1,
                                                    sectionList[i]
                                                        .productList!
                                                        .length)
                                                : const SizedBox.shrink()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        : sectionList[i].style == STYLE4
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.width,
                                  child: GridView.count(
                                    padding: const EdgeInsetsDirectional.only(
                                        top: 5),
                                    crossAxisCount:
                                        1, // Change this to 1 for horizontal scrolling
                                    scrollDirection: Axis
                                        .horizontal, // Set scroll direction to horizontal
                                    shrinkWrap: true,
                                    // childAspectRatio: 0.8,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(), // Allow scrolling
                                    children: List.generate(
                                      sectionList[i].productList!.length < 10
                                          ? sectionList[i].productList!.length
                                          : 10,
                                      (index) {
                                        return productItem(
                                          i,
                                          index,
                                          true,
                                          sectionList[i].productList![index],
                                          1,
                                          sectionList[i].productList!.length,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              )
                            : sectionList[i].style == ""
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                            flex: 1,
                                            fit: FlexFit.loose,
                                            child: SizedBox(
                                                height: orient ==
                                                        Orientation.portrait
                                                    ? deviceHeight! * 0.25
                                                    : deviceHeight! * 0.5,
                                                child: sectionList[i]
                                                                .productList!
                                                                .length ==
                                                            1 ||
                                                        sectionList[i]
                                                                .productList!
                                                                .length >
                                                            1
                                                    ? productItem(
                                                        i,
                                                        0,
                                                        false,
                                                        sectionList[i]
                                                            .productList![0],
                                                        1,
                                                        sectionList[i]
                                                            .productList!
                                                            .length)
                                                    : const SizedBox.shrink())),
                                        SizedBox(
                                          height: orient == Orientation.portrait
                                              ? deviceHeight! * 0.2
                                              : deviceHeight! * 0.5,
                                          child: Row(
                                            children: [
                                              Flexible(
                                                  flex: 1,
                                                  fit: FlexFit.loose,
                                                  child: sectionList[i]
                                                                  .productList!
                                                                  .length ==
                                                              2 ||
                                                          sectionList[i]
                                                                  .productList!
                                                                  .length >
                                                              2
                                                      ? productItem(
                                                          i,
                                                          1,
                                                          true,
                                                          sectionList[i]
                                                              .productList![1],
                                                          1,
                                                          sectionList[i]
                                                              .productList!
                                                              .length)
                                                      : const SizedBox
                                                          .shrink()),
                                              Flexible(
                                                  flex: 1,
                                                  fit: FlexFit.loose,
                                                  child: sectionList[i]
                                                                  .productList!
                                                                  .length ==
                                                              3 ||
                                                          sectionList[i]
                                                                  .productList!
                                                                  .length >
                                                              3
                                                      ? productItem(
                                                          i,
                                                          2,
                                                          false,
                                                          sectionList[i]
                                                              .productList![2],
                                                          1,
                                                          sectionList[i]
                                                              .productList!
                                                              .length)
                                                      : const SizedBox
                                                          .shrink()),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ))
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GridView.count(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                top: 5),
                                        crossAxisCount: 2,
                                        shrinkWrap: true,
                                        childAspectRatio: 1.2,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        mainAxisSpacing: 0,
                                        crossAxisSpacing: 0,
                                        children: List.generate(
                                          sectionList[i].productList!.length < 6
                                              ? sectionList[i]
                                                  .productList!
                                                  .length
                                              : 6,
                                          (index) {
                                            return productItem(
                                                i,
                                                index,
                                                index % 2 == 0 ? true : false,
                                                sectionList[i]
                                                    .productList![index],
                                                1,
                                                sectionList[i]
                                                    .productList!
                                                    .length);
                                          },
                                        )));
  }

  Widget productItem(
      int secPos, int index, bool pad, Product product, int from, int len) {
    if (len > index) {
      String? offPer;
      double price = double.parse(product.prVarientList![0].disPrice!);
      if (price == 0) {
        price = double.parse(product.prVarientList![0].price!);
      } else {
        double off = double.parse(product.prVarientList![0].price!) - price;
        offPer = ((off * 100) / double.parse(product.prVarientList![0].price!))
            .toStringAsFixed(2);
      }

      double width = sectionList[secPos].style == STYLE4
          ? MediaQuery.of(context).size.width
          : sectionList[secPos].style == STYLE1
              ? deviceWidth! * 0.93
              : double.maxFinite;

      double height =
          sectionList[secPos].style == STYLE1 ? 1000 : double.maxFinite;

      return Container(
        margin: EdgeInsets.all(sectionList[secPos].style == STYLE1 ? 4 : 5),
        width: width,
        height: height,
        padding: const EdgeInsetsDirectional.only(end: 2),
        child: Container(
          decoration: BoxDecoration(
              color: colors.whiteTemp,
              boxShadow: [
                BoxShadow(
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.09),
                  spreadRadius: 2,
                  blurRadius: 13,
                  offset: const Offset(0, 0), // changes position of shadow
                ),
              ],
              borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        color: colors.whiteTemp,
                        padding: EdgeInsets.all(15),
                        child: Hero(
                            transitionOnUserGestures: true,
                            tag: "$homeHero$index${product.id}$secPos",
                            child: networkImageCommon(
                                product.image!, width, false,
                                height: height,
                                width:
                                    width) /*CachedNetworkImage(
                              fadeInDuration: const Duration(milliseconds: 150),
                              imageUrl: product.image!,
                              height: double.maxFinite,
                              width: double.maxFinite,
                              fit: extendImg ? BoxFit.fill : BoxFit.fitHeight,
                              errorWidget: (context, error, stackTrace) =>
                                  erroWidget(double.maxFinite),
                              //fit: BoxFit.fill,
                              placeholder: (context, url) {
                                return placeHolder(width);
                              }),*/
                            ),
                      ),
                      Container(
                        // padding: EdgeInsets.only(
                        //   left: 10,
                        // ),
                        child: networkImageCommon_without_bg(
                            appUrl + product.brand!, 50, false,
                            height:
                                sectionList[secPos].style == STYLE1 ? 40 : 50,
                            width:
                                sectionList[secPos].style == STYLE1 ? 40 : 50),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          margin: EdgeInsets.only(
                            right: 5,
                          ),
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade800.withOpacity(0),
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              // Text(
                              //   double.parse(product.prVarientList![0].disPrice!) !=
                              //           0
                              //       ? getPriceFormat(
                              //           context,
                              //           double.parse(
                              //               product.prVarientList![0].price!))! + " "
                              //       : getPriceFormat(
                              //           context,
                              //           double.parse(
                              //               product.prVarientList![0].saleFinalPrice!))! + " ",
                              //   style: Theme.of(context)
                              //       .textTheme
                              //       .titleSmall!
                              //       .copyWith(
                              //           decoration: TextDecoration.lineThrough,
                              //           letterSpacing: 0,
                              //           color: colors
                              //               .whiteTemp
                              //               .withOpacity(0.8)),
                              // ),
                              Text("Earn",
                                  textAlign: TextAlign.right,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                        fontSize: 8,
                                        letterSpacing: 0,
                                        color: Colors.black,
                                      )),
                              Text(
                                  "${getPriceFormat_0(context, double.parse(product.prVarientList![0].earn_info_w!))!}",
                                  textAlign: TextAlign.right,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                          fontSize: sectionList[secPos].style ==
                                                  STYLE1
                                              ? 14
                                              : 14,
                                          letterSpacing: 0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w900)),

                              // Flexible(
                              //   child: Text(
                              //       " | "
                              //       "-${product.isSalesOn == "1" ? double.parse(product.saleDis!).toStringAsFixed(2) : offPer}%",
                              //       maxLines: 1,
                              //       overflow: TextOverflow.ellipsis,
                              //       style: Theme.of(context)
                              //           .textTheme
                              //           .labelSmall!
                              //           .copyWith(
                              //               color: colors.primary,
                              //               letterSpacing: 0)),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 10,
                    top: 2,
                  ),
                  child: Text(
                    product.name!,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontSize: 12,
                        color: colors.primary,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    textAlign: TextAlign.left,
                  ),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(product.prVarientList![0].cards_info_h!,
                          textAlign: TextAlign.left,
                          style:
                              Theme.of(context).textTheme.titleSmall!.copyWith(
                                    fontSize: 10,
                                  )),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10))),
                    child: Text(product.prVarientList![0].color_info_l!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: colors.whiteTemp)),
                  ),
                ]),
              ],
            ),
            onTap: () {
              Product model = product;
              currentHero = homeHero;
              Navigator.push(
                context,
                PageRouteBuilder(
                    // transitionDuration: Duration(milliseconds: 150),
                    pageBuilder: (_, __, ___) => ProductDetail(
                          secPos: secPos,
                          index: index,
                          list: false,
                          id: model.id!,

                          //  title: sectionList[secPos].title,
                        )),
              );
            },
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  _section() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? SizedBox(
                width: double.infinity,
                child: Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.simmerBase,
                    highlightColor: Theme.of(context).colorScheme.simmerHigh,
                    child: sectionLoading()))
            : ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: sectionList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return _singleSection(index);
                },
              );
      },
      selector: (_, homeProvider) => homeProvider.secLoading,
    );
  }

  _mostLike() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Stack(children: [
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 40),
                    // decoration: BoxDecoration(
                    //     color: Theme.of(context).colorScheme.back3,
                    //     borderRadius: const BorderRadius.only(
                    //         topLeft: Radius.circular(20),
                    //         topRight: Radius.circular(20)))
                  ),
                ),
                Selector<ProductProvider, List<Product>>(
                  builder: (context, data1, child) {
                    return data1.isNotEmpty
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                _getHeading(
                                    getTranslated(
                                        context, 'YOU_MIGHT_ALSO_LIKE')!,
                                    0,
                                    2,
                                    data1),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 0),
                                  child: GridView.count(
                                      crossAxisCount: 2,
                                      shrinkWrap: true,
                                      //childAspectRatio: 0.8,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      children: List.generate(
                                        data1.length < 4 ? data1.length : 4,
                                        (index) {
                                          return productItem(
                                              0,
                                              index,
                                              index % 2 == 0 ? true : false,
                                              data1[index],
                                              2,
                                              data1.length);
                                        },
                                      )),
                                ),
                              ])
                        : const SizedBox();
                  },
                  selector: (_, provider) => provider.productList,
                )
              ]))
        ]);
      },
      selector: (_, homeProvider) => homeProvider.mostLikeLoading,
    );
  }

  _catList() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? SizedBox(
                width: double.infinity,
                child: Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.simmerBase,
                    highlightColor: Theme.of(context).colorScheme.simmerHigh,
                    child: catLoading()))
            : Container(
                height: 115,
                padding: const EdgeInsets.only(top: 10, left: 10),
                child: ListView.builder(
                  itemCount: catList.length < 10 ? catList.length : 10,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const SizedBox.shrink();
                    } else {
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(end: 17),
                        child: InkWell(
                          onTap: () async {
                            if (catList[index].subList == null ||
                                catList[index].subList!.isEmpty) {
                              await Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => ProductList(
                                      name: catList[index].name,
                                      id: catList[index].id,
                                      tag: false,
                                      fromSeller: false,
                                    ),
                                  ));
                            } else {
                              await Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => SubCategory(
                                      title: catList[index].name!,
                                      subList: catList[index].subList,
                                    ),
                                  ));
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      bottom: 5.0, top: 8.0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: colors.primary_app,
                                            width: 2.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .fontColor
                                                .withOpacity(0.048),
                                            spreadRadius: 2,
                                            blurRadius: 13,
                                            offset: const Offset(0,
                                                0), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                          radius: 32.0,
                                          backgroundColor: Colors
                                              .transparent /* Theme.of(context).colorScheme.white*/,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(32),
                                            child: networkImageCommon(
                                                catList[index].image!,
                                                50,
                                                width: double.maxFinite,
                                                height: double.maxFinite,
                                                false),
                                          )
                                          /*CachedNetworkImage(
                                            fadeInDuration: const Duration(
                                                milliseconds: 150),
                                            imageUrl: catList[index].image!,
                                            fit: BoxFit.fill,
                                            errorWidget:
                                                (context, error, stackTrace) =>
                                                    erroWidget(50),
                                            placeholder: (context, url) {
                                              return placeHolder(50);
                                            }),*/
                                          ))),
                              SizedBox(
                                width: 50,
                                child: Text(
                                  capitalize(
                                      catList[index].name!.toLowerCase()),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .fontColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
      },
      selector: (_, homeProvider) => homeProvider.catLoading,
    );
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  Future<void> callApi() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      UserProvider user = Provider.of<UserProvider>(context, listen: false);
      SettingProvider setting =
          Provider.of<SettingProvider>(context, listen: false);
      pincode = await setting.getPrefrence(PINCODE);

      print("init pincode****$pincode");

      user.setUserId(setting.userId);
      user.setMobile(setting.mobile);
      user.setName(setting.userName);
      user.setEmail(setting.email);
      user.setProfilePic(setting.profileUrl);
      user.setType(setting.loginType);
    });

    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      getSetting();
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }

    return;
  }

  Future _getFav() async {
    try {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        if (context.read<UserProvider>().userId != "") {
          Map parameter = {
            USER_ID: context.read<UserProvider>().userId,
          };

          apiBaseHelper.postAPICall(getFavApi, parameter).then((getdata) {
            bool error = getdata["error"];
            String? msg = getdata["message"];
            if (!error) {
              var data = getdata["data"];

              List<Product> tempList =
                  (data as List).map((data) => Product.fromJson(data)).toList();

              context.read<FavoriteProvider>().setFavlist(tempList);
            } else {
              if (msg != 'No Favourite(s) Product Are Added') {
                setSnackbar(msg!, context);
              }
            }

            context.read<FavoriteProvider>().setLoading(false);
          }, onError: (error) {
            setSnackbar(error.toString(), context);
            context.read<FavoriteProvider>().setLoading(false);
          });
        } else {
          context.read<FavoriteProvider>().setLoading(false);
        }
      } else {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
          });
        }
      }
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  /* void getOfferImages() {
    try {
      Map parameter = {};

      apiBaseHelper.postAPICall(getOfferImageApi, parameter).then((getdata) {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];
          offerImages.clear();
          offerImages =
              (data as List).map((data) => Model.fromSlider(data)).toList();
        } else {
          setSnackbar(msg!, context);
        }

        context.read<HomeProvider>().setOfferLoading(false);
      }, onError: (error) {
        setSnackbar(error.toString(), context);
        context.read<HomeProvider>().setOfferLoading(false);
      });
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }*/

  void getSection({String? pincode}) {
    try {
      Map parameter = {PRODUCT_LIMIT: "6", PRODUCT_OFFSET: "0"};

      if (context.read<UserProvider>().userId != "") {
        parameter[USER_ID] = context.read<UserProvider>().userId;
      }
      //String curPin = context.read<UserProvider>().curPincode;
      if (pincode != null) parameter[ZIPCODE] = pincode;

      apiBaseHelper.postAPICall(getSectionApi, parameter).then((getdata) {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        sectionList.clear();
        if (!error) {
          var data = getdata["data"];

          print('section pincode*******$pincode');
          if (pincode != null) {
            context.read<SettingProvider>().setPrefrence(PINCODE, pincode!);
          }

          sectionList = (data as List)
              .map((data) => SectionModel.fromJson(data))
              .toList();
        } else {
          if (pincode != null) {
            setState(() {
              pincode = null;
            });
          }
          setSnackbar(msg!, context);
        }

        context.read<HomeProvider>().setSecLoading(false);
      }, onError: (error) {
        setSnackbar(error.toString(), context);
        context.read<HomeProvider>().setSecLoading(false);
      });
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  void getSetting() {
    try {
      //CUR_USERID = context.read<SettingProvider>().userId;

      Map parameter = {};
      if (context.read<UserProvider>().userId != "") {
        parameter = {USER_ID: context.read<UserProvider>().userId};
      }

      apiBaseHelper.postAPICall(getSettingApi, parameter).then((getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];

        if (!error) {
          var data = getdata["data"]["system_settings"][0];
          SUPPORTED_LOCALES = data["supported_locals"];
          if (data.toString().contains(MAINTAINANCE_MODE)) {
            Is_APP_IN_MAINTANCE = data[MAINTAINANCE_MODE];
          }
          if (Is_APP_IN_MAINTANCE != "1") {
            getSlider();
            getCat();
            getSection();
            //  getOfferImages();

            proIds = (await db.getMostLike())!;
            getMostLikePro();
            proIds1 = (await db.getMostFav())!;
            getMostFavPro();
          }

          if (data.toString().contains(MAINTAINANCE_MESSAGE)) {
            IS_APP_MAINTENANCE_MESSAGE = data[MAINTAINANCE_MESSAGE];
          }

          cartBtnList = data["cart_btn_on_list"] == "1" ? true : false;
          refer = data["is_refer_earn_on"] == "1" ? true : false;
          CUR_CURRENCY = data["currency"];
          RETURN_DAYS = data['max_product_return_days'];
          MAX_ITEMS = data["max_items_cart"];
          MIN_AMT = data['min_amount'];
          CUR_DEL_CHR = data['delivery_charge'];
          String? isVerion = data['is_version_system_on'];
          extendImg = data["expand_product_images"] == "1" ? true : false;
          String? del = data["area_wise_delivery_charge"];
          MIN_ALLOW_CART_AMT = data[MIN_CART_AMT];
          IS_LOCAL_PICKUP = data[LOCAL_PICKUP];
          ADMIN_ADDRESS = data[ADDRESS];
          ADMIN_LAT = data[LATITUDE];
          ADMIN_LONG = data[LONGITUDE];
          ADMIN_MOB = data[SUPPORT_NUM];
          IS_SHIPROCKET_ON = getdata["data"]["shipping_method"][0]
              ["shiprocket_shipping_method"];
          IS_LOCAL_ON =
              getdata["data"]["shipping_method"][0]["local_shipping_method"];
          ALLOW_ATT_MEDIA = data[ALLOW_ATTACH];
          print(
              'MEDIA»»»»»»***********$ALLOW_ATT_MEDIA ********** ${data[ALLOW_ATTACH]} **************');

          try {
            //pop up offer
            popUpOffer =
                PopUpOfferImage.fromJson(getdata["data"]["popup_offer"][0]);
            SharedPreferences sharedData =
                await SharedPreferences.getInstance();
            String storedOfferPopUpID =
                sharedData.getString("offerPopUpID") ?? "";

            /*   if (popUpOffer.isActive == "1") {
              if (popUpOffer.showMultipleTime == "1") {
                showPopUpOfferDialog();
              } else if (storedOfferPopUpID != popUpOffer.id) {
                showPopUpOfferDialog();
              }
            }*/
            popUpOffer.isActive == "1" &&
                    (popUpOffer.showMultipleTime == "1" ||
                        storedOfferPopUpID != popUpOffer.id)
                ? showPopUpOfferDialog()
                : null;
          } catch (e) {
            print("error is ${e.toString()}");
          }

          if (data.toString().contains(UPLOAD_LIMIT)) {
            UP_MEDIA_LIMIT = data[UPLOAD_LIMIT];
          }

          if (Is_APP_IN_MAINTANCE == "1") {
            appMaintenanceDialog();
          }

          if (del == "0") {
            ISFLAT_DEL = true;
          } else {
            ISFLAT_DEL = false;
          }

          if (context.read<UserProvider>().userId != "") {
            REFER_CODE = getdata['data']['user_data'][0]['referral_code'];

            context
                .read<UserProvider>()
                .setPincode(getdata["data"]["user_data"][0][PINCODE]);

            if (REFER_CODE == null || REFER_CODE == '' || REFER_CODE!.isEmpty) {
              generateReferral();
            }

            context.read<UserProvider>().setCartCount(
                getdata["data"]["user_data"][0]["cart_total_items"].toString());
            context
                .read<UserProvider>()
                .setBalance(getdata["data"]["user_data"][0]["balance"]);
            if (Is_APP_IN_MAINTANCE != "1") {
              _getFav();
              _getCart("0");
            }
          } else {
            if (Is_APP_IN_MAINTANCE != "1") {
              _getOffFav();
              _getOffCart();
            }
          }

          Map<String, dynamic> tempData = getdata["data"];
          if (tempData.containsKey(TAG)) {
            tagList = List<String>.from(getdata["data"][TAG]);
          }

          if (isVerion == "1") {
            String? verionAnd = data['current_version'];
            String? verionIOS = data['current_version_ios'];

            PackageInfo packageInfo = await PackageInfo.fromPlatform();

            String version = packageInfo.version;

            final Version currentVersion = Version.parse(version);
            final Version latestVersionAnd = Version.parse(verionAnd!);

            final Version latestVersionIos = Version.parse(verionIOS!);

            if ((Platform.isAndroid && latestVersionAnd > currentVersion) ||
                (Platform.isIOS && latestVersionIos > currentVersion)) {
              updateDailog();
            }
          }
        } else {
          setSnackbar(msg!, context);
        }
      }, onError: (error) {
        setSnackbar(error.toString(), context);
      });
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  Future<void> getMostLikePro() async {
    if (proIds.isNotEmpty) {
      _isNetworkAvail = await isNetworkAvailable();

      if (_isNetworkAvail) {
        try {
          var parameter = {"product_ids": proIds.join(',')};

          apiBaseHelper.postAPICall(getProductApi, parameter).then(
              (getdata) async {
            bool error = getdata["error"];
            if (!error) {
              var data = getdata["data"];

              List<Product> tempList =
                  (data as List).map((data) => Product.fromJson(data)).toList();
              mostLikeProList.clear();
              mostLikeProList.addAll(tempList);

              context.read<ProductProvider>().setProductList(mostLikeProList);
            }
            if (mounted) {
              setState(() {
                context.read<HomeProvider>().setMostLikeLoading(false);
              });
            }
          }, onError: (error) {
            setSnackbar(error.toString(), context);
          });
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          context.read<HomeProvider>().setMostLikeLoading(false);
        }
      } else {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
            context.read<HomeProvider>().setMostLikeLoading(false);
          });
        }
      }
    } else {
      context.read<ProductProvider>().setProductList([]);
      setState(() {
        context.read<HomeProvider>().setMostLikeLoading(false);
      });
    }
  }

  Future<void> getMostFavPro() async {
    if (proIds1.isNotEmpty) {
      _isNetworkAvail = await isNetworkAvailable();

      if (_isNetworkAvail) {
        try {
          var parameter = {"product_ids": proIds1.join(',')};

          apiBaseHelper.postAPICall(getProductApi, parameter).then(
              (getdata) async {
            bool error = getdata["error"];
            if (!error) {
              var data = getdata["data"];

              List<Product> tempList =
                  (data as List).map((data) => Product.fromJson(data)).toList();
              mostFavProList.clear();
              mostFavProList.addAll(tempList);
            }
            if (mounted) {
              setState(() {
                context.read<HomeProvider>().setMostLikeLoading(false);
              });
            }
          }, onError: (error) {
            setSnackbar(error.toString(), context);
          });
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          context.read<HomeProvider>().setMostLikeLoading(false);
        }
      } else {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
            context.read<HomeProvider>().setMostLikeLoading(false);
          });
        }
      }
    } else {
      context.read<CartProvider>().setCartlist([]);
      setState(() {
        context.read<HomeProvider>().setMostLikeLoading(false);
      });
    }
  }

  Future<void> _getOffCart() async {
    if (context.read<UserProvider>().userId == "") {
      List<String>? proIds = (await db.getCart())!;

      if (proIds.isNotEmpty) {
        _isNetworkAvail = await isNetworkAvailable();

        if (_isNetworkAvail) {
          try {
            var parameter = {"product_variant_ids": proIds.join(',')};
            apiBaseHelper.postAPICall(getProductApi, parameter).then(
                (getdata) async {
              bool error = getdata["error"];
              String? msg = getdata["message"];
              if (!error) {
                var data = getdata["data"];

                List<Product> tempList = (data as List)
                    .map((data) => Product.fromJson(data))
                    .toList();
                List<SectionModel> cartSecList = [];
                for (int i = 0; i < tempList.length; i++) {
                  for (int j = 0; j < tempList[i].prVarientList!.length; j++) {
                    if (proIds.contains(tempList[i].prVarientList![j].id)) {
                      String qty = (await db.checkCartItemExists(
                          tempList[i].id!, tempList[i].prVarientList![j].id!))!;
                      List<Product>? prList = [];
                      prList.add(tempList[i]);
                      cartSecList.add(SectionModel(
                        id: tempList[i].id,
                        varientId: tempList[i].prVarientList![j].id,
                        qty: qty,
                        productList: prList,
                      ));
                    }
                  }
                }

                context.read<CartProvider>().setCartlist(cartSecList);
              }
              if (mounted) {
                setState(() {
                  context.read<CartProvider>().setProgress(false);
                });
              }
            }, onError: (error) {
              setSnackbar(error.toString(), context);
            });
          } on TimeoutException catch (_) {
            setSnackbar(getTranslated(context, 'somethingMSg')!, context);
            context.read<CartProvider>().setProgress(false);
          }
        } else {
          if (mounted) {
            setState(() {
              _isNetworkAvail = false;
              context.read<CartProvider>().setProgress(false);
            });
          }
        }
      } else {
        context.read<CartProvider>().setCartlist([]);
        setState(() {
          context.read<CartProvider>().setProgress(false);
        });
      }
    }
  }

  Future<void> _getOffFav() async {
    if (context.read<UserProvider>().userId == "") {
      List<String>? proIds = (await db.getFav())!;
      if (proIds.isNotEmpty) {
        _isNetworkAvail = await isNetworkAvailable();

        if (_isNetworkAvail) {
          try {
            var parameter = {"product_ids": proIds.join(',')};
            apiBaseHelper.postAPICall(getProductApi, parameter).then((getdata) {
              bool error = getdata["error"];
              String? msg = getdata["message"];
              if (!error) {
                var data = getdata["data"];

                List<Product> tempList = (data as List)
                    .map((data) => Product.fromJson(data))
                    .toList();

                context.read<FavoriteProvider>().setFavlist(tempList);
              }
              if (mounted) {
                setState(() {
                  context.read<FavoriteProvider>().setLoading(false);
                });
              }
            }, onError: (error) {
              setSnackbar(error.toString(), context);
            });
          } on TimeoutException catch (_) {
            setSnackbar(getTranslated(context, 'somethingMSg')!, context);
            context.read<FavoriteProvider>().setLoading(false);
          }
        } else {
          if (mounted) {
            setState(() {
              _isNetworkAvail = false;
              context.read<FavoriteProvider>().setLoading(false);
            });
          }
        }
      } else {
        context.read<FavoriteProvider>().setFavlist([]);
        setState(() {
          context.read<FavoriteProvider>().setLoading(false);
        });
      }
    }
  }

  Future<void> _getCart(String save) async {
    try {
      _isNetworkAvail = await isNetworkAvailable();

      if (_isNetworkAvail) {
        if (context.read<UserProvider>().userId != "") {
          try {
            var parameter = {
              USER_ID: context.read<UserProvider>().userId,
              SAVE_LATER: save,
              "only_delivery_charge": "0",
            };
            apiBaseHelper.postAPICall(getCartApi, parameter).then((getdata) {
              bool error = getdata["error"];
              String? msg = getdata["message"];
              if (!error) {
                var data = getdata["data"];

                List<SectionModel> cartList = (data as List)
                    .map((data) => SectionModel.fromCart(data))
                    .toList();
                context.read<CartProvider>().setCartlist(cartList);
              }
            }, onError: (error) {
              setSnackbar(error.toString(), context);
            });
          } on TimeoutException catch (_) {}
        }
      } else {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
          });
        }
      }
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<void> generateReferral() async {
    try {
      String refer = getRandomString(8);

      //////

      Map parameter = {
        REFERCODE: refer,
      };

      apiBaseHelper.postAPICall(validateReferalApi, parameter).then((getdata) {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          REFER_CODE = refer;

          context.read<SettingProvider>().setPrefrence(REFERCODE, REFER_CODE!);

          Map parameter = {
            USER_ID: context.read<UserProvider>().userId,
            REFERCODE: refer,
          };

          apiBaseHelper.postAPICall(getUpdateUserApi, parameter);
        } else {
          if (count < 5) generateReferral();
          count++;
        }

        context.read<HomeProvider>().setSecLoading(false);
      }, onError: (error) {
        setSnackbar(error.toString(), context);
        context.read<HomeProvider>().setSecLoading(false);
      });
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  updateDailog() async {
    await dialogAnimate(context,
        StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        title: Text(getTranslated(context, 'UPDATE_APP')!),
        content: Text(
          getTranslated(context, 'UPDATE_AVAIL')!,
          style: Theme.of(this.context)
              .textTheme
              .titleMedium!
              .copyWith(color: Theme.of(context).colorScheme.fontColor),
        ),
        actions: <Widget>[
          TextButton(
              child: Text(
                getTranslated(context, 'NO')!,
                style: Theme.of(this.context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.lightBlack,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              }),
          TextButton(
              child: Text(
                getTranslated(context, 'YES')!,
                style: Theme.of(this.context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                Navigator.of(context).pop(false);

                String url = '';
                if (Platform.isAndroid) {
                  url = androidLink + packageName;
                } else if (Platform.isIOS) {
                  url = iosLink;
                }

                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $url';
                }
              })
        ],
      );
    }));
  }

  Widget homeShimmer() {
    return SizedBox(
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: SingleChildScrollView(
            child: Column(
          children: [
            catLoading(),
            sliderLoading(),
            sectionLoading(),
          ],
        )),
      ),
    );
  }

  Widget sliderLoading() {
    double width = deviceWidth!;
    double height = width / 2;
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          height: height,
          color: Theme.of(context).colorScheme.white,
        ));
  }

  Widget _buildImagePageItem(Model slider) {
    double height = deviceWidth! / 0.5;

    return InkWell(
      child: networkImageCommon(slider.image!, height, true,
          height: height, width: double.maxFinite),
      onTap: () async {
        int curSlider = context.read<HomeProvider>().curSlider;
        print("value ${homeSliderList[curSlider].type}");
        if (homeSliderList[curSlider].type == "products") {
          Product? item = homeSliderList[curSlider].list;
          currentHero = homeHero;
          Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (_, __, ___) => ProductDetail(
                      secPos: 0,
                      index: 0,
                      list: true,
                      id: item!.id!,
                    )),
          );
        } else if (homeSliderList[curSlider].type == "categories") {
          Product item = homeSliderList[curSlider].list;
          if (item.subList!.isEmpty) {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => ProductList(
                    name: item.name,
                    id: item.id,
                    tag: false,
                    fromSeller: false,
                  ),
                ));
          } else {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => SubCategory(
                    title: item.name!,
                    subList: item.subList,
                  ),
                ));
          }
        } else if (homeSliderList[curSlider].type == "slider_url") {
          String url = homeSliderList[curSlider].urlLink.toString();
          try {
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url),
                  mode: LaunchMode.externalApplication);
            } else {
              throw 'Could not launch $url';
            }
          } catch (e) {
            throw 'Something went wrong';
          }
        }
      },
    );
  }

  Widget deliverLoading() {
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ));
  }

  Widget catLoading() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                    .map((_) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.white,
                            shape: BoxShape.circle,
                          ),
                          width: 50.0,
                          height: 50.0,
                        ))
                    .toList()),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ),
      ],
    );
  }

  Widget noInternet(BuildContext context) {
    return SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        noIntImage(),
        noIntText(context),
        noIntDec(context),
        AppBtn(
          title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
          btnAnim: buttonSqueezeanimation,
          btnCntrl: buttonController,
          onBtnSelected: () async {
            context.read<HomeProvider>().setCatLoading(true);
            context.read<HomeProvider>().setSecLoading(true);
            context.read<HomeProvider>().setOfferLoading(true);
            context.read<HomeProvider>().setMostLikeLoading(true);
            context.read<HomeProvider>().setSliderLoading(true);
            _playAnimation();

            Future.delayed(const Duration(seconds: 2)).then((_) async {
              _isNetworkAvail = await isNetworkAvailable();
              if (_isNetworkAvail) {
                if (mounted) {
                  setState(() {
                    _isNetworkAvail = true;
                  });
                }
                callApi();
              } else {
                await buttonController.reverse();
                if (mounted) setState(() {});
              }
            });
          },
        )
      ]),
    );
  }

  _deliverPincode() {
    //  String pincodeFromDashboard = context.read<UserProvider>().curPincode;
    // print('currr pincode:_______$pincodeFromDashboard');
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _pincodeCheck,
            child: Container(
              // padding: EdgeInsets.symmetric(vertical: 8),
              color: Theme.of(context).colorScheme.lightWhite,
              child: ListTile(
                dense: true,
                minLeadingWidth: 10,
                leading: const Icon(
                  Icons.location_pin,
                  color: colors.primary,
                ),
                title: /*Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    print('pincode-------${userProvider.curPincode}');*/
                    Text(
                  '${pincode != null ? getTranslated(context, 'SELOC')! : 'Check Pincodes'} ${pincode ?? ''}',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.fontColor),
                ),

                /* },
                 // selector: (_, provider) => provider.curPincode,
                ),*/
                trailing: const Icon(Icons.keyboard_arrow_right),
              ),
            ),
          ),
        ),
        // Container(
        //   decoration: BoxDecoration(
        //     // border:Border.all(width: 1, color:colors.primary),
        //     borderRadius: BorderRadius.circular(8.0),
        //   ),
        //   margin: const EdgeInsets.symmetric(horizontal: 0,vertical: 8),
        //   child: IconButton(
        //     icon: Image.asset(
        //       'assets/images/follow_instagram.png',
        //       width: 24,
        //       height: 24
        //     ),
        //     onPressed: () async {
        //       var url = 'https://www.instagram.com/berfy';
        //       if(await canLaunchUrl( Uri.parse(url))) {
        //         await launchUrl(Uri.parse(url));
        //       }
        //     },
        //   ),
        // ),
        Container(
          decoration: BoxDecoration(
            // border:Border.all(width: 1, color:colors.primary),
            borderRadius: BorderRadius.circular(8.0),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: IconButton(
            icon: Image.asset('assets/images/follow_whatsapp.png',
                width: 24, height: 24),
            onPressed: () async {
              // try{
              //   final newContact = Contact()
              //     ..name.first = 'Berfy'
              //     ..name.last = 'Jewellers'
              //     ..phones = [Phone('981-894-7675')];
              //   await newContact.insert();
              // } catch (e) {

              // }
              var url = 'https://wa.me/9582505350")';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              }
            },
          ),
        ),
        // Container(
        //   decoration: BoxDecoration(
        //     border:Border.all(width: 1, color:colors.primary),
        //     borderRadius: BorderRadius.circular(8.0),
        //   ),
        //   margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
        //   child: Image.asset(
        //     '',
        //     width: 24,
        //     height: 24
        //   ),
        // ),
      ],
    );
  }

  _getSearchBar() {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          decoration: BoxDecoration(
              // borderRadius: BorderRadius.all(
              //         Radius.circular(5.0),
              //       ),
              // border: Border.all(
              // color: colors.primary,
              //     width: 1,
              // )
              ),
          height: 38,
          child: TextField(
            enabled: false,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(50.0),
                  ),
                  borderSide: BorderSide(
                      width: 2,
                      style: BorderStyle.solid,
                      color: Color(0xff406595)),
                ),
                isDense: true,
                hintText: getTranslated(context, 'searchHint'),
                hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                    ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    'assets/images/search.svg',
                    colorFilter:
                        const ColorFilter.mode(colors.primary, BlendMode.srcIn),
                  ),
                ),
                fillColor: Theme.of(context).colorScheme.lightWhite,
                filled: true),
          ),
        ),
      ),
      onTap: () async {
        await Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const Search(),
            ));
        if (mounted) setState(() {});
      },
    );
  }

  void _pincodeCheck() {
    showModalBottomSheet<dynamic>(
        backgroundColor: colors.blackTemp,
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9),
              child: ListView(shrinkWrap: true, children: [
                Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20, bottom: 40, top: 30),
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Form(
                          key: _formkey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Icon(Icons.close),
                                ),
                              ),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                textCapitalization: TextCapitalization.words,
                                validator: (val) => validatePincode(val!,
                                    getTranslated(context, 'PIN_REQUIRED')),
                                onSaved: (String? value) {
                                  setState(() {
                                    pincode = value!;
                                  });
                                  /*context
                                          .read<UserProvider>()
                                          .setPincode(value!);*/
                                },
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor),
                                decoration: InputDecoration(
                                  isDense: false,
                                  prefixIcon: const Icon(Icons.location_on),
                                  hintText:
                                      getTranslated(context, 'PINCODEHINT_LBL'),
                                  // enabledBorder: const UnderlineInputBorder(
                                  //   borderSide:  BorderSide(color: colors.primary, width: 0.5),
                                  // ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsetsDirectional.only(
                                          start: 20),
                                      width: deviceWidth! * 0.35,
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                              width: 1.0,
                                              color: colors.primary),
                                        ),
                                        onPressed: () {
                                          /* context
                                              .read<UserProvider>()
                                              .setPincode('');*/

                                          context
                                              .read<HomeProvider>()
                                              .setSecLoading(true);
                                          getSection();
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          getTranslated(context, 'All')!,
                                          style: const TextStyle(
                                              color: colors.primary),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    SimBtn(
                                        width: 0.35,
                                        height: 35,
                                        title: getTranslated(context, 'APPLY'),
                                        onBtnSelected: () async {
                                          if (validateAndSave()) {
                                            // validatePin(curPin);

                                            context
                                                .read<HomeProvider>()
                                                .setSecLoading(true);
                                            getSection(pincode: pincode);

                                            Navigator.pop(context);
                                          }
                                        }),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ))
              ]),
            );
            //});
          });
        });
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;

    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  void getSlider() {
    try {
      Map map = {};

      apiBaseHelper.postAPICall(getSliderApi, map).then((getdata) {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          homeSliderList =
              (data as List).map((data) => Model.fromSlider(data)).toList();

          pages = homeSliderList.map((slider) {
            return _buildImagePageItem(slider);
          }).toList();
        } else {
          setSnackbar(msg!, context);
        }

        context.read<HomeProvider>().setSliderLoading(false);
      }, onError: (error) {
        setSnackbar(error.toString(), context);
        context.read<HomeProvider>().setSliderLoading(false);
      });
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  void getCat() {
    try {
      Map parameter = {
        CAT_FILTER: "false",
      };
      apiBaseHelper.postAPICall(getCatApi, parameter).then((getdata) {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          catList =
              (data as List).map((data) => Product.fromCat(data)).toList();

          if (getdata.containsKey("popular_categories")) {
            var data = getdata["popular_categories"];
            popularList =
                (data as List).map((data) => Product.fromCat(data)).toList();

            if (popularList.isNotEmpty) {
              Product pop =
                  Product.popular("Popular", "${imagePath}popular.svg");
              catList.insert(0, pop);
              context.read<CategoryProvider>().setSubList(popularList);
            }
          }
        } else {
          setSnackbar(msg!, context);
        }

        context.read<HomeProvider>().setCatLoading(false);
      }, onError: (error) {
        setSnackbar(error.toString(), context);
        context.read<HomeProvider>().setCatLoading(false);
      });
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  sectionLoading() {
    return Column(
        children: [0, 1, 2, 3, 4]
            .map((_) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                                margin: const EdgeInsets.only(bottom: 40),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.white,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20)))),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                width: double.infinity,
                                height: 18.0,
                                color: Theme.of(context).colorScheme.white,
                              ),
                              GridView.count(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  childAspectRatio: 1.0,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 5,
                                  children: List.generate(
                                    4,
                                    (index) {
                                      return Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color:
                                            Theme.of(context).colorScheme.white,
                                      );
                                    },
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    sliderLoading()
                    //offerImages.length > index ? _getOfferImage(index) : SizedBox.shrink(),
                  ],
                ))
            .toList());
  }

  void appMaintenanceDialog() async {
    await dialogAnimate(context,
        StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
      return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          title: Text(
            getTranslated(context, 'APP_MAINTENANCE')!,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal,
                fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Lottie.asset('assets/animation/maintenance.json'),
              ),
              const SizedBox(
                height: 25,
              ),
              Text(
                IS_APP_MAINTENANCE_MESSAGE != ''
                    ? IS_APP_MAINTENANCE_MESSAGE!
                    : getTranslated(context, 'MAINTENANCE_DEFAULT_MESSAGE')!,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.normal,
                    fontSize: 12),
              )
            ],
          ),
        ),
      );
    }));
  }

  void showPopUpOfferDialog() async {
    print("image is ${popUpOffer.image}");
    try {
      SharedPreferences sharedData = await SharedPreferences.getInstance();
      sharedData.setString("offerPopUpID", popUpOffer.id.toString());

      if (popUpOffer.showMultipleTime == "1") {}
      await dialogAnimate(context, StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
        print("image ${popUpOffer.image}");
        print("image ${popUpOffer.image}");
        return Dialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: InkWell(
            onTap: () {
              popUpOfferImageClick();
            },
            child: Container(
              margin: const EdgeInsets.only(left: 0.0, right: 0.0),
              child: Stack(
                children: <Widget>[
                  Container(
                      /*  padding: const EdgeInsets.only(
                      top: 18.0,
                    ),*/
                      margin: const EdgeInsets.only(
                          top: 13.0, right: 8.0, left: 8.0),
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: (Theme.of(context).colorScheme.white)
                                  .withOpacity(0.5),
                              blurRadius: 0.0,
                              offset: const Offset(0.0, 0.0),
                            ),
                          ]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: networkImageCommon(
                            popUpOffer.image!,
                            50,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.5,
                            false,
                            boxFit: BoxFit.fill),
                      )),
                  Positioned(
                    right: 0.0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: CircleAvatar(
                          radius: 14.0,
                          backgroundColor: (Theme.of(context).colorScheme.white)
                              .withOpacity(0.7),
                          child: Icon(Icons.close,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }));
    } catch (e) {
      print("error ${e.toString()}");
    }
  }

  popUpOfferImageClick() async {
    Navigator.pop(context);
    if (popUpOffer.type == "products") {
      String id = popUpOffer.data![0].id!;
      currentHero = homeHero;
      Navigator.push(
        context,
        PageRouteBuilder(
            //transitionDuration: Duration(seconds: 1),
            pageBuilder: (_, __, ___) => ProductDetail(
                  secPos: 0, index: 0, list: true, id: id,

                  //  title: sectionList[secPos].title,
                )),
      );
    } else if (popUpOffer.type == "categories") {
      Product item = popUpOffer.data!;
      if (item.subList == null || item.subList!.isEmpty) {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ProductList(
                name: item.name,
                id: item.id,
                tag: false,
                fromSeller: false,
                maxDis: popUpOffer.maxDiscount,
                minDis: popUpOffer.minDiscount,
              ),
            ));
      } else {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => SubCategory(
                title: item.name!,
                subList: item.subList,
                maxDis: popUpOffer.maxDiscount,
                minDis: popUpOffer.minDiscount,
              ),
            ));
      }
    } else if (popUpOffer.type == "all_products") {
      Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ProductList(
              tag: false,
              fromSeller: false,
              maxDis: popUpOffer.maxDiscount,
              minDis: popUpOffer.minDiscount,
            ),
          ));
    } else if (popUpOffer.type == "brand") {
      Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ProductList(
              tag: false,
              fromSeller: false,
              maxDis: popUpOffer.maxDiscount,
              minDis: popUpOffer.minDiscount,
              brandId: popUpOffer.typeId,
              name: popUpOffer.data![0].name!,
            ),
          ));
    } else if (popUpOffer.type == "offer_url") {
      String url = popUpOffer.urlLink.toString();
      try {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
      } catch (e) {
        throw 'Something went wrong';
      }
    }
  }

  _showForm(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 2.0, right: 5.0),
        child: _isLoading
            ? shimmer(context)
            : SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: controller,
                  itemCount: faqsList.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return (index == faqsList.length && isLoadingmore)
                        ? const Center(
                            child: CircularProgressIndicator(
                            color: colors.primary,
                          ))
                        : listItem(index);
                  },
                ),
              ));
  }

  listItem(int index) {
    return Container(
      child: Card(
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
                color: colors.whiteTemp,
                border: Border.all(width: 2, color: colors.primary_sec),
                borderRadius: BorderRadius.circular(4)),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                if (mounted) {
                  setState(() {
                    selectedIndex = index;
                    flag = !flag;
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(4),
                            // decoration: BoxDecoration(
                            //   borderRadius: BorderRadius.circular(100),
                            //   border: Border.all(width: 3,color: colors.primary)),
                            height: 30,
                            width: 30,
                            child: SvgPicture.asset(
                              selectedIndex != index || flag
                                  ? "${imagePath}popular_sel.svg"
                                  : "${imagePath}popular.svg",
                              colorFilter: const ColorFilter.mode(
                                  colors.primary, BlendMode.srcIn),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              faqsList[index].question!,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(color: colors.primary),
                            ),
                          ),
                          Icon(
                            selectedIndex != index
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            color: colors.primary,
                          )
                        ],
                      ),
                      selectedIndex != index
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          faqsList[index].answer!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .black
                                                      .withOpacity(0.7)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ))),
                                // const Icon(Icons.keyboard_arrow_down,color: colors.whiteTemp,)
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                  Expanded(
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            faqsList[index].answer!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall!
                                                .copyWith(
                                                    color: colors.primary),
                                          ))),
                                  // const Icon(Icons.keyboard_arrow_up)
                                ]),
                    ]),
              ),
            ),
          )),
    );
  }

  Future<void> getFaqs() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        Map param = {};

        apiBaseHelper.postAPICall(getFaqsApi, param).then((getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];
            faqsList =
                (data as List).map((data) => FaqsModel.fromJson(data)).toList();
          } else {
            setSnackbar(msg!, context);
          }

          if (mounted) {
            setState(() {
              _isLoading = false;
              // setSnackbar(faqsList.length.toString(),context);
            });
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isNetworkAvail = false;
        });
      }
    }
  }

  List<FaqsModel> faqsList = [];
  bool _isLoading = true;
  int selectedIndex = -1;
  bool flag = true;
  bool isLoadingmore = true;
  ScrollController controller = ScrollController();
}
