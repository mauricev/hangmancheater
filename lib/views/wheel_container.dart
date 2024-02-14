import 'package:flutter/material.dart';
import 'package:cheater_for_hangman_and_wheel_of_fortune/consts.dart';
import 'package:cheater_for_hangman_and_wheel_of_fortune/views/display_dragged_letter.dart';

import '../view_models/view_cheater_model.dart';

class WheelOfFortuneLetterSlot extends StatelessWidget {
  final HangManWheelOfFortuneViewCheaterModel cheaterViewModel;
  final int index;

  const WheelOfFortuneLetterSlot({
    super.key,
    required this.cheaterViewModel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {

    return DragTarget<String>(
        // the pretty formatter is pulling this line up
        onWillAccept: (dataNotUsed) {
      // this return is returning a bool to onWillAccept
      return (cheaterViewModel.getDisplayLetterAtPosition(index) !=
          cWheelOfFortuneDefaultCharacter);
    },
        onAccept: (String letter) {
          cheaterViewModel.setDisplayLetterAtPosition(index, letter);
    }, builder: (BuildContext context, List<String?> draggedLetterList,
            List notUsed) {
      String? letterSlotString =
          displayThisLetter(cheaterViewModel, draggedLetterList, index);

      return Container(
        width: cWheelWidth,
        height: cWheelHeight,
        // if the space has no character, a 0, then it should be drawn transparent
        // otherwise it’s white and it should be draggable
        color: (letterSlotString == cWheelOfFortuneDefaultCharacter)
            ? Colors.transparent
            : Colors.white,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () {
              String letter = cheaterViewModel.getDisplayLetterAtPosition(index);
              cheaterViewModel.toggleDisplayLetterAtPosition(index);
            },
            child: Center(
              child: ((letterSlotString == cWheelOfFortuneDefaultCharacter) ||
                      (letterSlotString == cWheelOfFortuneLivenCharacter))
                  ? Container()
                  : Text(letterSlotString!),
            ),
          ),
        ),
      );
    });
  }
}
