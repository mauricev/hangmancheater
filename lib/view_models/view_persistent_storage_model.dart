import 'package:flutter/material.dart';
import 'view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cheater_for_hangman_and_wheel_of_fortune/consts.dart';

class HangManWheelOfFortunePersistentStorage extends ChangeNotifier {
  final SharedPreferences prefs;
  final HangManWheelOfFortuneViewModel viewModel;

  HangManWheelOfFortunePersistentStorage(this.prefs, this.viewModel) {
    String? incomingMode = prefs.getString(cGameMode);
    if (incomingMode != null) {
      viewModel.setGameMode(incomingMode,GameInitializeMode.atBoot);
    }
  }
}