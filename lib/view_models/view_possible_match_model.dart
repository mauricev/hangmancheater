import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view_model.dart';
import '../models/cheater_model.dart';
import '../models/excluded_letters.dart';
import '../models/matches.dart';
import '../consts.dart';

class HangManWheelOfFortunePossibleMatchesViewModel extends ChangeNotifier {
  final SharedPreferences prefs;
  final HangManWheelOfFortuneViewModel viewModel;
  CheaterModel? cheaterModel;
  ExcludedLetters? excludedLetters;
  PossibleMatches? possibleMatches;

  HangManWheelOfFortunePossibleMatchesViewModel(this.prefs, this.viewModel) {
    viewModel.registerCheaterPossibleMatchViewModel(this);
  }

  Future<void> createMatcher(String incomingMode, CheaterModel cheaterModel, ExcludedLetters excludedLetters) async {
    switch (incomingMode) {
      case cHangManMode:
        possibleMatches = HangManMatches(cheaterModel, excludedLetters);
        possibleMatches!.buildDictionary();
        break;
      case cWheelOfFortuneMode:
        possibleMatches = WheelOfFortuneMatches(cheaterModel,excludedLetters);
        possibleMatches!.buildDictionary(additionalEntries: viewModel.onlineWheelOfFortuneMasterPhraseList); // takes 7 seconds
        break;
    }
  }

  void buildPossibleMatches() {
    if (possibleMatches != null) {
      possibleMatches!.buildMatches();
    }
  }

  int getPossibleMatchesTotal() {
    int possibleMatchesTotal = 0;
    if (possibleMatches != null) {
      possibleMatchesTotal = possibleMatches!.getPossibleMatchesTotal();
    }
    return possibleMatchesTotal;
  }

  String getPossibleMatch(int index) {
    return possibleMatches!.getPossibleMatch(index);
  }
}