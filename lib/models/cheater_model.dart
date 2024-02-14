import 'package:cheater_for_hangman_and_wheel_of_fortune/consts.dart';
import 'persistence_model.dart';

class CheaterModel extends PersistenceModel {
  List<String> displayText = [];
  List<String> actualText = [];

  int numberOfLetterSlots = cInitialNumberOfCharacters;
  String defaultCharacter =
      ""; // "0" for wheel and "_" for hangman "0" is dead character; "_" is live character

  CheaterModel({required super.prefs, required initializeModeParam}) {
    newCheaterGame(initializeModeParam);
  }

  @override
  void loadCheatInfo() {
    String? prefsString = prefs.getString(cDisplayTextPrefs);
    if (prefsString != null) {
      // can't call resetDisplayText because it calls saveCheatInfo, which erases the data here
      displayText = prefsString.split("");
      setNumberOfLetterSlots(
          newNumberOfLetters: displayText.length,
          gameInitializeMode: GameInitializeMode.atBoot);
    }
  }

  @override
  void saveCheatInfo() {
    String prefsString = displayText.join("");
    prefs.setString(cDisplayTextPrefs, prefsString);
  }

  void resetDisplayText(GameInitializeMode initializeModeParam) {
    // when we are in boot mode, we no longer initialize
    if (initializeModeParam == GameInitializeMode.alreadyInGame) {
      displayText.clear();
      for (int theIndex = 0; theIndex < numberOfLetterSlots; theIndex++) {
        displayText.add(defaultCharacter);
      }
      saveCheatInfo();
    }
  }
  // there does have to be a new button to reset the wheel of fortune grid

  void newCheaterGame(GameInitializeMode initializeModeParam) {
    resetDisplayText(initializeModeParam);
  }

  // for wheel of fortune, every character is assigned "0" to start
  // when the user whitens a character where the characters will go
  // we reassign them to "_"

  void assignCharacter(int index, String newCharacter) {
    displayText[index] = newCharacter;
    saveCheatInfo();
  }

  int getNumberOfLetterSlots() {
    return numberOfLetterSlots;
  }

  int getNumberOfActualLetters() {
    // I expect actualText to have been prepared when this method is called
    return actualText.length;
  }

  String getDisplayLetterAtPosition(int index) {
    return displayText[index];
  }

  String getActualLetterAtPosition(int index) {
    return actualText[index];
  }

  void setNumberOfLetterSlots(
      {required int newNumberOfLetters,
      GameInitializeMode gameInitializeMode = GameInitializeMode.atBoot}) {
    // changing the number of letters mid-cheat resets the whole thing
    // problem in design wheeloffortune can't change this value
    numberOfLetterSlots = newNumberOfLetters;
    resetDisplayText(gameInitializeMode);
  }

  bool doesCheaterContainThisLetter(String letter) {
    return displayText.contains(letter);
  }

  void toggleDisplayLetterAtPosition(int index) {
    // abstract, hangman and wheel will have their own ways of handling this
  }

  void convertDisplayTextToActualText() {
    actualText.clear();
  }

  bool isActualLetterExcluded(String letterInQuestion) {
    return actualText.contains(letterInQuestion);
  }
}

class HangManCheater extends CheaterModel {
  HangManCheater({required super.prefs, required super.initializeModeParam});

  @override
  void newCheaterGame(GameInitializeMode initializeModeParam) {
    defaultCharacter = cHangManDefaultCharacter;
    numberOfLetterSlots = cInitialNumberOfCharacters;
    super.newCheaterGame(initializeModeParam);
  }

  // if there is a character in this slot, delete it and set the slot to the default character
  @override
  void toggleDisplayLetterAtPosition(int index) {
    if (getDisplayLetterAtPosition(index) != cHangManDefaultCharacter) {
      assignCharacter(index, cHangManDefaultCharacter);
    }
  }

  @override
  void convertDisplayTextToActualText() {
    super.convertDisplayTextToActualText();
    actualText = List.from(displayText); // for hangman, it's super easy.
  }
}

class WheelOfFortuneCheater extends CheaterModel {
  String livenCharacterCharacter = "";

  WheelOfFortuneCheater(
      {required super.prefs, required super.initializeModeParam});

  @override
  void newCheaterGame(GameInitializeMode initializeModeParam) {
    defaultCharacter = cWheelOfFortuneDefaultCharacter;
    livenCharacterCharacter = cWheelOfFortuneLivenCharacter;
    numberOfLetterSlots = cWheelOfFortuneNumberOfLetters;

    super.newCheaterGame(initializeModeParam);
  }

  @override
  void setNumberOfLetterSlots(
      {required int newNumberOfLetters,
      GameInitializeMode gameInitializeMode = GameInitializeMode.atBoot}) {
    // numberOfLetterSlots is hardcoded at cWheelOfFortuneNumberOfLetters
  }

  // present only in this subclass
  void livenCharacter(int index) {
    assignCharacter(index, cWheelOfFortuneLivenCharacter);
  }

  // can we easily deaden characters? so far I’d say yes
  void deadenCharacter(int index) {
    assignCharacter(index, cWheelOfFortuneDefaultCharacter);
  }

  @override
  void toggleDisplayLetterAtPosition(int index) {
    if (getDisplayLetterAtPosition(index) == cWheelOfFortuneDefaultCharacter) {
      // default is 0, dead
      livenCharacter(index);
    } else if (getDisplayLetterAtPosition(index) !=
        cWheelOfFortuneLivenCharacter) {
      livenCharacter(index);
    } else {
      deadenCharacter(index);
    }
  }

  @override
  void convertDisplayTextToActualText() {
    super.convertDisplayTextToActualText(); // clears the actualText List

    // here is where the magic happens
    // we start walking the displaytext, looking for either a character or a _
    // if we get either of these, we add it to displaytext
    // when we get to the 2nd line (a specific index), we add a space character (but first we check if the prior character was a space
    // and if it was, we don’t add the space

    bool anyMoreRealCharactersRemaining(int theStartingIndex) {
      for (int theIndex = (theStartingIndex + 1);
          theIndex < displayText.length;
          theIndex++) {
        if (displayText[theIndex] != cWheelOfFortuneDefaultCharacter) {
          return true;
        }
      }
      return false;
    }

    bool spaceScanning = false;
    for (int theIndex = 0; theIndex < displayText.length; theIndex++) {
      String theCharacter = displayText[theIndex];

      // this is a placeholder, not a space!
      if (theCharacter != cWheelOfFortuneDefaultCharacter) {
        actualText.add(
            theCharacter); // this should add liven characters and actual characters
        // if there is another word
        spaceScanning = true;
      } else {
        if (spaceScanning) {
          if ((theIndex < displayText.length) &&
              anyMoreRealCharactersRemaining(theIndex)) {
            actualText.add(cSpaceCharacter);
          }
          spaceScanning = false;
        }
      }
    }
  }
  // how can we accommodate wordle?
  // simple, it's fixed at 5 characters
  // we need a two-way letter; that is, say I have the word BANDS and D is present but not in position 4
  // we need a way to remove d from just this spot
  // first we set up a grid of 5 characters and 6 of these
  // se we can track of it all, but; there's a problem
  // we have just one displaytext
  // here is my idea
}
