import 'package:flutter/material.dart';

import 'views/main_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'view_models/view_model.dart';
import 'view_models/view_cheater_model.dart';
import 'view_models/view_exclusions_model.dart';
import 'view_models/view_possible_match_model.dart';
import 'view_models/view_persistent_storage_model.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(810, 1080), // 10.2 inch iPad portrait size
    minimumSize: Size(810, 1080),
    maximumSize: Size(810, 1080),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(CheaterHangmanWheelOfFortuneApp(prefs: prefs));
}

class CheaterHangmanWheelOfFortuneApp extends StatelessWidget {
  final SharedPreferences prefs;

  const CheaterHangmanWheelOfFortuneApp({super.key, required this.prefs});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HangManWheelOfFortuneViewModel>(
            create: (context) => HangManWheelOfFortuneViewModel(prefs)),
        ChangeNotifierProvider<HangManWheelOfFortuneViewCheaterModel>(
            create: (context) => HangManWheelOfFortuneViewCheaterModel(prefs,Provider.of<HangManWheelOfFortuneViewModel>(context, listen: false))),
        ChangeNotifierProvider<HangManWheelOfFortuneExclusionViewModel>(
            create: (context) => HangManWheelOfFortuneExclusionViewModel(prefs,Provider.of<HangManWheelOfFortuneViewModel>(context, listen: false))),
        ChangeNotifierProvider<HangManWheelOfFortunePossibleMatchesViewModel>(
            create: (context) => HangManWheelOfFortunePossibleMatchesViewModel(prefs,Provider.of<HangManWheelOfFortuneViewModel>(context, listen: false))),
        ChangeNotifierProvider<HangManWheelOfFortunePersistentStorage>(
            create: (context) => HangManWheelOfFortunePersistentStorage(prefs,Provider.of<HangManWheelOfFortuneViewModel>(context, listen: false))),
      ],
      child: MaterialApp(
        title: 'Hangman and Wheel of Fortune Cheater',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MainView(),
      ),
    );
  }
}