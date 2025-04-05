import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/constants/static_data.dart';
import 'core/lang/ui_texts.dart';
import 'presentation/screens/user_activities_view.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(
      MultiBlocProvider(
        providers: [
          ChangeNotifierProvider<UiTexts>(
            create: (context) {
              Locale systemLocale = PlatformDispatcher.instance.locale;
              return UiTexts(systemLocale);
            },
          ),
          // BlocProvider<CustomDropdownDataCubit>(
          //   create: (context) => CustomDropdownDataCubit(),
          // ),
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // viewManager.init(LoginView.routeName);
    // FlutterNativeSplash.remove();

    String initialRoute = UserActivitiesView.routeName;

    return MaterialApp(
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
      routes: {
        UserActivitiesView.routeName: (context) => const UserActivitiesView(),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('es', 'ES')],
    );
  }
}
