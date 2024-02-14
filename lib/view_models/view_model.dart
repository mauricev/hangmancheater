import 'package:flutter/material.dart';

import '../consts.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

import 'view_exclusions_model.dart';
import 'view_cheater_model.dart';
import 'view_possible_match_model.dart';
import 'view_persistent_storage_model.dart';

class HangManWheelOfFortuneViewModel extends ChangeNotifier {
  final SharedPreferences prefs;
  String theMode = cNoGameSelectedMode;
  HangManWheelOfFortuneExclusionViewModel? exclusionViewModel;
  HangManWheelOfFortuneViewCheaterModel? cheaterViewModel;
  HangManWheelOfFortunePossibleMatchesViewModel? possibleMatchViewModel;
  HangManWheelOfFortunePersistentStorage? persistentStorageViewModel;

  List<String> onlineWheelOfFortuneMasterPhraseList = [];
  bool compendiumNotReady = false;

  // problem how can i set this mode before everything is initialized?

  HangManWheelOfFortuneViewModel(this.prefs) {
    /*theMode = cNoGameSelectedMode;
    String? initialMode = prefs.getString(cGameMode);
    initialMode = cNoGameSelectedMode;
    if (initialMode != null) {
      theMode = initialMode;
      //setGameMode(theMode); // we notify listeners, but is this a race condition
      // we need to set up the rest of this; that is the number of letters for hangman
      // and the letters we know so far
      // the unused letters
    }*/
    iterateCompendium();
  }

  void registerExclusionViewModel(HangManWheelOfFortuneExclusionViewModel exclusionViewModelParam) {
    exclusionViewModel = exclusionViewModelParam;
  }

  void registerCheaterViewModel(HangManWheelOfFortuneViewCheaterModel cheaterViewModelParam) {
    cheaterViewModel = cheaterViewModelParam;
  }

  void registerCheaterPossibleMatchViewModel(HangManWheelOfFortunePossibleMatchesViewModel possibleMatchViewModelParam) {
    possibleMatchViewModel = possibleMatchViewModelParam;
  }

  void registerPersistentStorageViewModel(HangManWheelOfFortunePersistentStorage persistentStorageViewModelParam) {
    persistentStorageViewModel = persistentStorageViewModelParam;
  }

  String fetchGameMode() {
    return theMode;
  }

  // game mode is set only after button click
  // and at launch
  void setGameMode(String incomingMode, GameInitializeMode initializeModeParam) {
    theMode = incomingMode;

    prefs.setString(cGameMode, theMode); // we can be called after being read, so this resets itself

    cheaterViewModel!.createCheater(incomingMode, initializeModeParam);
    if (initializeModeParam == GameInitializeMode.atBoot) {
      cheaterViewModel!.initializeGame();
      exclusionViewModel!.initializeGame();
    }

    print("setGameMode about to creatematcher");
    possibleMatchViewModel!.createMatcher(incomingMode,cheaterViewModel!.getCheaterModel()!, exclusionViewModel!.getExcludedLettersModel()!);

    print("setGameMode done with creatematcher");

    if (initializeModeParam == GameInitializeMode.alreadyInGame) {
      print("setGameMode about to notify listeners");
      notifyListeners();
    }
  }

  Future<String> fetchCompendiumPage(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load web page');
    }
  }

  List<String>? parseTableData(String htmlContent) {
    final dom.Document document = parser.parse(htmlContent);

    final dom.Element? error = document.querySelector('div.container.error');
    if (error != null) return null;

    final dom.Element? table = document.querySelector('div#zone_2 table');
    if (table == null) return null;

    final List<dom.Element> rows = table.querySelectorAll('tr');

    List<String> tableData = [];

    for (dom.Element row in rows) {
      final List<dom.Element> cells = row.querySelectorAll('td');

      if ((cells.length >= 2) &&
          (cells[0].text != null) &&
          (cells[0].text != "")) {
        tableData.add(cells[0].text.trim());
      }
    }
    return tableData;
  }

  bool isCompendiumReady() {
    return compendiumNotReady;
  }

  Future<void> iterateCompendium() async {
    try {
      for (int theIndex = 0;
      theIndex < cOnlineWheelOfFortuneSeasonsToReadFrom.length;
      theIndex++) {
        final String buyAVowelPage = await fetchCompendiumPage(
            "https://buyavowel.boards.net/page/compendium${cOnlineWheelOfFortuneSeasonsToReadFrom[theIndex]}");

        List<String>? onlineWheelOfFortunePhraseList =
        parseTableData(buyAVowelPage);

        if (onlineWheelOfFortunePhraseList != null) {
          onlineWheelOfFortuneMasterPhraseList
              .addAll(onlineWheelOfFortunePhraseList);
        }
      }
    } catch (e) {
      print("error, ${e.toString()}");
    }
    compendiumNotReady = true;
    notifyListeners();
  }
}
