const double cLetterSizeInPixels = 27;
const double cMaxLetterWidthInPixels = 100;
const double cInterLetterSpaceInPixels = 5;
const double cCommonMarginInPixels = 16.0;

const String cGameMode = 'gamemode';
const String cHangManMode = 'hangman';
const String cWheelOfFortuneMode = 'wheeloffortune';
const String cNoGameSelectedMode = "cheaternotselected";

const String cDisplayTextPrefs = "displayText";
const String cExcludedDisplayTextPrefs = "excludedText";

const String cHangManDefaultCharacter = "_";
const String cWheelOfFortuneDefaultCharacter = "0";
const String cWheelOfFortuneLivenCharacter = "_";
const int cInitialNumberOfCharacters = 1;
const int cWheelOfFortuneNumberOfLetters = 55;  // there are 52 physical slots and 3 invisible spaces at the at the beginning of each row after the 1st one.

const int cMinHangmanLetters = 1;
const int cMaxHangmanLetters = 45;
const int cHangmanLettersIncrement = 1;

const String cSpaceCharacter = " ";
const int cSizeOfPlainAlphabet = 26;

// the values below are hardcoded to line up with the wheel of fortune graphic
const double cWheelWidth = 28;
const double cWheelHeight = 39;

const double cWheelInterval = 34.2;
const double cHeightInterval = 47;

const double cWheelFirstRowLeft = 60;
const double cWheelFirstRowTop = 29;

const double cWheelSecondRowLeft = 26;

// a word may end at the end of a row in wheel of fortune mode
// and the next word immediately begin on the next line
// this would result in no intervening spaces, so we add them here
// we are really adding only one space per line
const int cFirstRowIndexEnd = 12; // this is where a space character will go
const int cSecondRowIndexShift = cFirstRowIndexEnd + 1;
const int cSecondRowStartingSpace = cFirstRowIndexEnd;

const int cSecondRowIndexEnd = 26; // this is where a space character will go
const int cThirdRowIndexShift = cSecondRowIndexEnd + 2;
const int cThirdRowStartingSpace = cSecondRowIndexEnd + 1;

const int cThirdRowIndexEnd = 40; // this is where a space character will go
const int cFourthRowIndexShift = cThirdRowIndexEnd + 3;
const int cFourthRowStartingSpace = cThirdRowIndexEnd + 2;

const int cTopAndBottomLetterSlotsForWheel = 12;
const int cInnerLetterSlotsForWheel = 14;
const int cAfterTwoRows = 2;
const int cAfterThreeRows = 3;

const List<int> cOnlineWheelOfFortuneSeasonsToReadFrom = [1,2,3,4,5,6,7,8,9,10,11,13,14,15,16,17,18,19,20,21,23,24,25,41];

enum GameInitializeMode { atBoot, alreadyInGame }