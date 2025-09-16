import 'dart:io';
import 'package:berfy/Helper/Color.dart';
import 'package:berfy/Helper/Constant.dart';
import 'package:berfy/Provider/CartProvider.dart';
import 'package:berfy/Provider/CategoryProvider.dart';
import 'package:berfy/Provider/FavoriteProvider.dart';
import 'package:berfy/Provider/FlashSaleProvider.dart';
import 'package:berfy/Provider/HomeProvider.dart';
import 'package:berfy/Provider/OfferImagesProvider.dart';
import 'package:berfy/Provider/ProductDetailProvider.dart';
import 'package:berfy/Provider/ProductProvider.dart';

import 'package:berfy/Provider/UserProvider.dart';
import 'package:berfy/Provider/pushNotificationProvider.dart';

import 'package:berfy/Screen/Splash.dart';
import 'package:berfy/ui/styles/themedata.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Provider/MyFatoraahPaymentProvider.dart';
import 'app/Demo_Localization.dart';
import 'Helper/Session.dart';

import 'Provider/Theme.dart';
import 'Provider/SettingProvider.dart';
import 'Provider/order_provider.dart';
import 'Screen/Dashboard.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isNotEmpty) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: 'AIzaSyBdKvdoH2uwwR9CvYSzjO3uTkyKKJJrIxQ',
            appId: '1:1085000435308:web:54a6caaf3367ea24a8ba49',
            messagingSenderId: '1085000435308',
            projectId: 'maharajasweets-ca013'));
  } else {
    await Firebase.initializeApp();
  }

  //await Firebase.initializeApp();
  initializedDownload();
  HttpOverrides.global = MyHttpOverrides();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // status bar color
  ));
  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>(
          create: (BuildContext context) {
            // String? theme = prefs.getString(APP_THEME);

            // if (theme == DARK) {
            //   ISDARK = "true";
            // } else if (theme == LIGHT) {
            //   ISDARK = "false";
            // }

            // if (theme == null || theme == "" || theme == DEFAULT_SYSTEM) {
            //   prefs.setString(APP_THEME, DEFAULT_SYSTEM);
            //   var brightness = SchedulerBinding
            //       .instance.platformDispatcher.platformBrightness;
            //   ISDARK = (brightness == Brightness.dark).toString();

            //   return ThemeNotifier(ThemeMode.system);
            // }

            // return ThemeNotifier(
            //     theme == LIGHT ? ThemeMode.light : ThemeMode.dark);
            return ThemeNotifier(ThemeMode.dark);
          },
        ),
        Provider<SettingProvider>(
          create: (context) => SettingProvider(prefs),
        ),
        ChangeNotifierProvider<UserProvider>(
            create: (context) => UserProvider()),
        ChangeNotifierProvider<HomeProvider>(
            create: (context) => HomeProvider()),
        ChangeNotifierProvider<CategoryProvider>(
            create: (context) => CategoryProvider()),
        ChangeNotifierProvider<ProductDetailProvider>(
            create: (context) => ProductDetailProvider()),
        ChangeNotifierProvider<FavoriteProvider>(
            create: (context) => FavoriteProvider()),
        ChangeNotifierProvider<OrderProvider>(
            create: (context) => OrderProvider()),
        ChangeNotifierProvider<CartProvider>(
            create: (context) => CartProvider()),
        ChangeNotifierProvider<ProductProvider>(
            create: (context) => ProductProvider()),
        ChangeNotifierProvider<FlashSaleProvider>(
            create: (context) => FlashSaleProvider()),
        ChangeNotifierProvider<OfferImagesProvider>(
            create: (context) => OfferImagesProvider()),
        ChangeNotifierProvider<PaymentIdProvider>(
            create: (context) => PaymentIdProvider()),
        ChangeNotifierProvider<PushNotificationProvider>(
            create: (context) => PushNotificationProvider()),
      ],
      child: MyApp(sharedPreferences: prefs),
    ),
  );
}

Future<void> initializedDownload() async {
  await FlutterDownloader.initialize(debug: false);
}

// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  late SharedPreferences sharedPreferences;

  MyApp({Key? key, required this.sharedPreferences}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  setLocale(Locale locale) {
    if (mounted) {
      setState(() {
        _locale = locale;
      });
    }
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      if (mounted) {
        setState(() {
          _locale = locale;
        });
      }
    });
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    dashboardPageState = GlobalKey<HomePageState>();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    if (_locale == null) {
      return const Center(
        child: CircularProgressIndicator(
            color: colors.primary,
            valueColor: AlwaysStoppedAnimation<Color?>(colors.primary)),
      );
    } else {
      return MaterialApp(
        locale: _locale,
        //scaffoldMessengerKey: scaffoldMessageKey,
        supportedLocales: const [
          Locale("en", "US"),
          Locale("zh", "CN"),
          Locale("es", "ES"),
          Locale("hi", "IN"),
          Locale("ar", "DZ"),
          Locale("ru", "RU"),
          Locale("ja", "JP"),
          Locale("de", "DE")
        ],
        localizationsDelegates: const [
          DemoLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale!.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        navigatorKey: navigatorKey,
        title: appName,
        theme: lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const Splash(),
          '/home': (context) => Dashboard(
                key: dashboardPageState,
              ),
          // '/login': (context) => const Login(),
        },

        darkTheme: lightTheme,

        themeMode: themeNotifier.getThemeMode(),
      );
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
