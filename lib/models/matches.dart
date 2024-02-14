import 'package:cheater_for_hangman_and_wheel_of_fortune/consts.dart';
import 'package:cheater_for_hangman_and_wheel_of_fortune/models/cheater_model.dart';
import 'package:cheater_for_hangman_and_wheel_of_fortune/models/excluded_letters.dart';
import 'package:cheater_for_hangman_and_wheel_of_fortune/utility/alphabet.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class PossibleMatches {
  CheaterModel cheaterModel;
  ExcludedLetters excludedLetters;
  List<String> possibleMatchesList =
      []; // for hangman, it's just one word; for wheel, it’s a phrase, so I think we can share this

  String dictionaryFileName = "";
  List<String> dictionary =
      <String>[]; // for hangman, each list item is word; for wheel, it’s a phrase

  String punctuation = "|-|?|.|&|#|'";

  int buildDictionaryProgress = 0;

  PossibleMatches({required this.cheaterModel, required this.excludedLetters});

  void setDictionaryFileName() {
    // abstract
  }

  // buildDictionary is an already inside a subclass. can we build the hangman dictionary in realtime in buildmatches
  // it awaits and reports dictionary building in the gui until it is built
  // but wheeloffortune is more difficult since only part of the dictionary has been built
  // it could saying dictionary partially built; loading remainder from the web... (even animate the ...)
  // the other alternative since neither dictionary has been built; it simply to keep track of the dictionary state
  // and keep the gui updated.
  // dictionaryLoadedState can be an enum: notLoaded, partiallyLoaded, fullyLoaded this replaces compendiumready
  // can compendium code come here; if builddictionary is here, then possibly

  Future<void> buildDictionary({List<String>? additionalEntries}) async {

    print("buildDictionary start");

    setDictionaryFileName();
    final String theDictionaryAsString =
        await rootBundle.loadString(dictionaryFileName);
    print("buildDictionary loaded");
    LineSplitter lineSplitter = const LineSplitter();
    dictionary = lineSplitter.convert(theDictionaryAsString);
    print("buildDictionary done, length, ${dictionary.length}");
  }

  int getPossibleMatchesTotal() {
    return possibleMatchesList.length;
  }

  String getPossibleMatch(int index) {
    return possibleMatchesList[index];
  }

  // for this to work with wordle, we need a way to exclude a letter in the wrong position
  // say we have SNACKS and K is in the word but not in position 4.
  // we want to exclude it from position 4, but include in every other position
  // we need to call buildGrepRangeForPossibleMatches for each position
  // and we need to pass to it the cheater model's letter
  // if it is upper case it is a normal letter, if it is lowercase it is to be excluded
  // from this position

  String buildGrepRangeForPossibleMatches() {
    final List<String> alphabetList = AlphabetClass.alphabet.toList();

    List<String> listOfIncludedLetters = <String>[];

    String grepRanges = "[";

    for (int theAlphabetIndex = 0;
        theAlphabetIndex < alphabetList.length;
        theAlphabetIndex++) {
      if (excludedLetters.isLetterExcluded(alphabetList[
              theAlphabetIndex]) ==
          true) {
        // do nothing, the letter is being excluded; it is either not used or it is used
      } else {
        listOfIncludedLetters.add(alphabetList[theAlphabetIndex]);
      }
    }
    // we start out by including every letter; this makes sense so far
    // but say I add a letter A in the first position; now I want grep range to include that A

    // walk the list of included letters, building up a range for grep.
    // Always start out adding a letter, then look ahead to see if it’s part of a range. If it is, add the range;
    // otherwise, jump to the next letter
    for (int theAlphabetIndex = 0;
        theAlphabetIndex < alphabetList.length;
        theAlphabetIndex++) {
      if (listOfIncludedLetters.contains(alphabetList[theAlphabetIndex])) {
        grepRanges = grepRanges + alphabetList[theAlphabetIndex];

        int rangeCounter = 0;
        int thePreflightedRangeIndex = 0;
        // start with next letter and see if it matches the next letter in the alphabet;
        // if it does, we may have a range; one more (at least 3 consecutive characters), and it is a range.
        for (thePreflightedRangeIndex = theAlphabetIndex + 1;
            thePreflightedRangeIndex < alphabetList.length;
            thePreflightedRangeIndex++) {
          if (listOfIncludedLetters
              .contains(alphabetList[thePreflightedRangeIndex])) {
            rangeCounter = rangeCounter + 1;
          } else {
            break;
          }
        }

        // rangecounter starts out at 0, so if it’s 2 or higher, we are dealing with a range.
        if (rangeCounter > 1) {
          grepRanges = "$grepRanges-";
          grepRanges = grepRanges + alphabetList[thePreflightedRangeIndex - 1];
          theAlphabetIndex = theAlphabetIndex + rangeCounter;
        }
      }
    }
    //print("punctuation, ${punctuation}");
    //grepRanges = "$grepRanges$punctuation]";
    grepRanges = "$grepRanges]";
    return grepRanges;
  }

  // this appears to build a grep range that starts with ^ and ends with $
  // theLetter can have a space, which I did not expect
  // under what circumstance did we have spaces anywhere
  String buildThePossibleMatchesSearchString() {
    // we scan and collect all the letters in the displaytext
    // we pass them onto the function below and it adds a second set of excluded letters to productio of each range.

    String grepRange = buildGrepRangeForPossibleMatches();

    // the word will have underscores where the ranges will go
    String searchString = "^";

    for (int theLetterIndex = 0;
        theLetterIndex < cheaterModel.getNumberOfActualLetters();
        theLetterIndex++) {
      String theLetter = cheaterModel.getActualLetterAtPosition(theLetterIndex);

      // space because why?
      // it’s a placeholder for every slot that has no current letter
      // we need to have underscores here
      // that will have the same effect as the space character below
      // but how will we handle actual spaces for between words in wheel of fortune mode
      if (theLetter == cHangManDefaultCharacter) {
        // i think this should be an underscore
        searchString = searchString +
            grepRange; // if it is the default character, it gets the grep range
      } else {
        searchString = searchString +
            theLetter; // if it is not default, it gets the letter. we can add to this space for actual spaces in wheel
      }
    }
    searchString = "$searchString\$"; // must escape dollar sign
    return searchString;
  }

  void buildMatches() {
    possibleMatchesList.clear();

    cheaterModel.convertDisplayTextToActualText();

    String searchForThis = buildThePossibleMatchesSearchString();

    RegExp theFullGrepRange = RegExp(searchForThis);

    for (String word in dictionary) {
      if (theFullGrepRange.hasMatch(word)) {
        possibleMatchesList.add(word); // duplicates break this
      }
    }
  }
}

class HangManMatches extends PossibleMatches {
  HangManMatches(CheaterModel cheaterModel, ExcludedLetters excludedLetters)
      : super(cheaterModel: cheaterModel, excludedLetters: excludedLetters);

  @override
  void setDictionaryFileName() {
    dictionaryFileName = "assets/words-uppercase.txt";
  }
}

class WheelOfFortuneMatches extends PossibleMatches {
  //LoadCompendium loadCompendium = LoadCompendium();

  WheelOfFortuneMatches(
      CheaterModel cheaterModel, ExcludedLetters excludedLetters)
      : super(cheaterModel: cheaterModel, excludedLetters: excludedLetters);

  @override
  void setDictionaryFileName() {
    dictionaryFileName = "assets/wheel-of-fortune-phrases.txt";
  }

  @override
  Future<void> buildDictionary({List<String>? additionalEntries}) async {
    await super.buildDictionary();
    final Stopwatch stopwatch = Stopwatch()..start();
    // let's say we make loadCompendium a viewmodel
    // we construct it startup but don't load the data then
    // actually we do load the data then and have the new wheel button be a consumer of it
    // so when the load is complete, it changes its text and livens
    if(additionalEntries != null) {
      dictionary.addAll(additionalEntries);
      dictionary.sort();
      // remove duplicates
      dictionary = dictionary.toSet().toList(); // this should have remove duplicates
    }
    stopwatch.stop();
    print('buildDictionary executed in ${stopwatch.elapsed}');

  }
}
