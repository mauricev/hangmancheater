import 'package:cheater_for_hangman_and_wheel_of_fortune/consts.dart';
import 'persistence_model.dart';

class ExcludedLetters extends PersistenceModel {
  Set<String> excludedLetterSet = {};

  ExcludedLetters({required super.prefs});

  @override
  void loadCheatInfo() {
    String? prefsString = prefs.getString(cExcludedDisplayTextPrefs);
    if (prefsString != null) {
      excludedLetterSet = prefsString.split("").toSet();
    }
  }

  @override
  void saveCheatInfo() {
    String prefsString = excludedLetterSet.join("");
    prefs.setString(cExcludedDisplayTextPrefs, prefsString);
  }

  void addToExcludedLetters(String letterToAdd) {
    excludedLetterSet.add(letterToAdd);
    saveCheatInfo();
  }

  void removeFromExcludedLetters(String letterToRemove) {
    excludedLetterSet.remove(letterToRemove);
    saveCheatInfo();
  }

  bool isLetterExcluded(String letterInQuestion) {
      return excludedLetterSet.contains(letterInQuestion);
  }

  int getExcludedLetterTotal() {
    return excludedLetterSet.length;
  }

  String getExcludedLetterAtIndex(int index) {
    List<String> unusedLetterList = excludedLetterSet.toList();
    return unusedLetterList[index];
  }

}