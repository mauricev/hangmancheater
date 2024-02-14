import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view_model.dart';
import '../models/cheater_model.dart';

import '../consts.dart';

class HangManWheelOfFortuneViewCheaterModel extends ChangeNotifier {
  final SharedPreferences prefs;
  final HangManWheelOfFortuneViewModel viewModel;
  CheaterModel? cheater;

  HangManWheelOfFortuneViewCheaterModel(this.prefs, this.viewModel){
    viewModel.registerCheaterViewModel(this);
  }

  void createCheater(String incomingMode, GameInitializeMode initializeModeParam) {
    switch (incomingMode) {
      case cHangManMode:
        cheater = HangManCheater(prefs: prefs, initializeModeParam: initializeModeParam);
        break;
      case cWheelOfFortuneMode:
        cheater = WheelOfFortuneCheater(prefs: prefs, initializeModeParam: initializeModeParam);
    }
  }

  void initializeGame() {
    cheater!.loadCheatInfo();
  }

  CheaterModel? getCheaterModel(){
    return cheater;
  }

  int getNumberOfLetterSlots() {
    return cheater!.getNumberOfLetterSlots();
  }

  void setNumberOfLetters(int newNumberOfLetters) {
    cheater!.setNumberOfLetterSlots(newNumberOfLetters: newNumberOfLetters, gameInitializeMode: GameInitializeMode.alreadyInGame);
    // we reset the cheat everytime this is changed
    notifyListeners();
  }

  String getDisplayLetterAtPosition(int index) {
    return cheater!.displayText[index];
  }

  void setDisplayLetterAtPosition(int index, String letterToSet) {
    cheater!.assignCharacter(index, letterToSet);
    notifyListeners();
  }

  void toggleDisplayLetterAtPosition(int index) {
    cheater!.toggleDisplayLetterAtPosition(index);
    notifyListeners();
  }

  bool doesCheaterContainThisLetter(String letter) {
    return cheater!.doesCheaterContainThisLetter(letter);
  }

}