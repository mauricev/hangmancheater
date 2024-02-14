import '../view_models/view_cheater_model.dart';

String? displayThisLetter(HangManWheelOfFortuneViewCheaterModel cheaterViewModel, List<String?> draggedLetterList, int index) {
  // display the letter the user is dragging or the letter already present
  String? displayThisLetter = cheaterViewModel.getDisplayLetterAtPosition(index);
  bool isBeingDraggedOn = draggedLetterList.isNotEmpty;
  if (isBeingDraggedOn) {
    displayThisLetter = draggedLetterList.first;
  }
  return displayThisLetter;
}