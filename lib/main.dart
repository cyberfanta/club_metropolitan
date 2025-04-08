import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'core/constants/static_data.dart';
import 'core/lang/ui_texts.dart';
import 'core/theme/ui_colors.dart';
import 'data/services/data_service.dart';
import 'domain/cubit/all_activities/all_activities_cubit.dart';
import 'domain/cubit/user_activities/user_activities_cubit.dart';
import 'presentation/screens/user_activities_view.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final DataService dataService = DataService();

  runApp(
    MultiBlocProvider(
      providers: [
        ChangeNotifierProvider<UiTexts>(
          create: (context) {
            Locale systemLocale = PlatformDispatcher.instance.locale;
            return UiTexts(systemLocale);
          },
        ),
        BlocProvider<UserActivitiesCubit>(
          create: (context) => UserActivitiesCubit(dataService),
        ),
        BlocProvider<AllActivitiesCubit>(
          create: (context) => AllActivitiesCubit(dataService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();

    String initialRoute = UserActivitiesView.routeName;

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Club Metropolitan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: cWhite,
        appBarTheme: const AppBarTheme(
          backgroundColor: cWhite,
          elevation: 0,
          iconTheme: IconThemeData(color: cBlack),
          titleTextStyle: TextStyle(
            fontFamily: 'CreatoDisplay',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: cBlack,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'CreatoDisplay'),
          bodyMedium: TextStyle(fontFamily: 'CreatoDisplay'),
          titleLarge: TextStyle(fontFamily: 'CreatoDisplay'),
          titleMedium: TextStyle(fontFamily: 'CreatoDisplay'),
          titleSmall: TextStyle(fontFamily: 'CreatoDisplay'),
        ),
        colorScheme: ColorScheme.light(
          primary: cBlack,
          onPrimary: cWhite,
          surface: cWhite,
          error: cRedError,
        ),
      ),
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
