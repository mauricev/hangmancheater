import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view_model.dart';
import 'package:cheater_for_hangman_and_wheel_of_fortune/models/excluded_letters.dart';

class HangManWheelOfFortuneExclusionViewModel extends ChangeNotifier {
  final SharedPreferences prefs;
  final HangManWheelOfFortuneViewModel viewModel;
  ExcludedLetters? excludedLetters;

  HangManWheelOfFortuneExclusionViewModel(this.prefs, this.viewModel) {
    excludedLetters = ExcludedLetters(prefs: prefs);
    viewModel.registerExclusionViewModel(this);
  }

  void initializeGame() {
    excludedLetters!.loadCheatInfo();
  }

  ExcludedLetters? getExcludedLettersModel() {
    return excludedLetters;
  }

  void addExcludedLetter(String letterToAdd) {
    excludedLetters!.addToExcludedLetters(letterToAdd);
    notifyListeners();
  }

  bool excludedLettersContains(String letter) {
    return excludedLetters!.isLetterExcluded(letter);
  }

  int getExcludedLetterTotal() {
    return excludedLetters!.getExcludedLetterTotal();
  }

  String getExcludedLetterAtIndex(int index) {
    return excludedLetters!.getExcludedLetterAtIndex(index);
  }

  void deleteExcludedLetter(int index) {
    excludedLetters!.removeFromExcludedLetters(getExcludedLetterAtIndex(index));
    notifyListeners();
  }


}