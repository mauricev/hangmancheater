import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/view_model.dart';
import 'package:cheater_for_hangman_and_wheel_of_fortune/utility/alphabet.dart';
import '../consts.dart';
import 'package:cheater_for_hangman_and_wheel_of_fortune/views/display_dragged_letter.dart';

import 'wheel_container.dart';

import 'number_picker.dart';

import '../view_models/view_exclusions_model.dart';
import '../view_models/view_cheater_model.dart';
import '../view_models/view_possible_match_model.dart';
import '../view_models/view_persistent_storage_model.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  final matchesScrollController = ScrollController();

  @override
  void dispose() {
    matchesScrollController.dispose();
    super.dispose();
  }

  // button no longer reflects the state the program is in
  Widget cheaterMode(HangManWheelOfFortuneViewModel viewModel) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            viewModel.setGameMode(cHangManMode,GameInitializeMode.alreadyInGame);
          },
          child: const Text("New Hangman Cheat"),
        ),
        ElevatedButton(
          onPressed: viewModel.isCompendiumReady()
              ? () {
                  viewModel.setGameMode(cWheelOfFortuneMode,GameInitializeMode.alreadyInGame);
                }
              : null,
          child: viewModel.isCompendiumReady()
              ? const Text("New Wheel of Fortune Cheat")
              : const Text("Loading Wheel of Fortune Phrases…"),
        ),
      ],
    );
  }

  double calculateWidthForHangmanLetters(BuildContext context,
      HangManWheelOfFortuneViewCheaterModel cheaterViewModel) {

    int numberOfLetters = cheaterViewModel.getNumberOfLetterSlots();
    double screenWidth =
        MediaQuery.of(context).size.width - (cCommonMarginInPixels * 2);

    // remove the space between letters from the screenwidth
    screenWidth = screenWidth - (numberOfLetters - 1) * 1;

    double letterWidth = screenWidth / numberOfLetters;
    if (letterWidth > cMaxLetterWidthInPixels) {
      letterWidth = cMaxLetterWidthInPixels;
    }
    return letterWidth;
  }

  Widget hangManLetter(
      HangManWheelOfFortuneViewCheaterModel cheaterViewModel, int index) {
    return DragTarget<String>(
      onAccept: (String letter) {
        cheaterViewModel.setDisplayLetterAtPosition(index, letter);
      },
      builder: (BuildContext context, List<String?> draggedLetterList,
          List notUsed) {
        double letterWidth =
            calculateWidthForHangmanLetters(context, cheaterViewModel);

        String? displayToLetter =
            displayThisLetter(cheaterViewModel, draggedLetterList, index);

        int letterNumber = index + 1; // labels each slot with its position
        return Column(
          children: [
            Expanded(
              child: Container(
                width: letterWidth,
                margin: const EdgeInsets.only(right: 1),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  onTap: () {
                    cheaterViewModel.toggleDisplayLetterAtPosition(index);
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(displayToLetter!),
                  ),
                ),
              ),
            ),
            Text(letterNumber.toString()),
          ],
        );
      },
    );
  }

  Widget hangManWordItself(BuildContext context) {
    HangManWheelOfFortuneViewCheaterModel cheaterViewModel =
        Provider.of<HangManWheelOfFortuneViewCheaterModel>(context,
            listen: true);

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cheaterViewModel.getNumberOfLetterSlots(),
        itemBuilder: (context, index) {
          return hangManLetter(cheaterViewModel, index);
        },
      ),
    );
  }

  Widget hangManPrep(BuildContext context) {
    HangManWheelOfFortuneViewCheaterModel cheaterViewModel =
        Provider.of<HangManWheelOfFortuneViewCheaterModel>(context,
            listen: true);

    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Row(
        children: [
          SizedBox(
            height: 75,
            child: numberPicker(
                cMinHangmanLetters,
                cMaxHangmanLetters,
                cheaterViewModel.getNumberOfLetterSlots,
                cheaterViewModel.setNumberOfLetters),
          ),
        ],
      ),
    );
  }

  // draw transparent containers of each grid item
  List<Widget> loopOverWheelLetterSlots(
      {required HangManWheelOfFortuneViewCheaterModel cheaterViewModel,
      required double startLeft,
      required double startTop,
      required int numSlots,
      int indexShift = 0}) {
    List<Widget> wheelGridAcross = <Positioned>[];

    for (int theIndex = 0; theIndex < numSlots; theIndex++) {
      wheelGridAcross.add(Positioned(
        left: startLeft + (cWheelInterval * theIndex),
        top: startTop,
        child: WheelOfFortuneLetterSlot(
            cheaterViewModel: cheaterViewModel, index: theIndex + indexShift),
      ));
    }
    return wheelGridAcross;
  }

  Widget wheelOfFortuneGrid(BuildContext context) {
    HangManWheelOfFortuneViewCheaterModel cheaterViewModel =
        Provider.of<HangManWheelOfFortuneViewCheaterModel>(context,
            listen: true);

    return Stack(
      children: [
        Image.asset('assets/puzzle-thumb.jpeg'),
        ...loopOverWheelLetterSlots(
            cheaterViewModel: cheaterViewModel,
            startLeft: cWheelFirstRowLeft,
            startTop: cWheelFirstRowTop,
            numSlots: cTopAndBottomLetterSlotsForWheel),
        ...loopOverWheelLetterSlots(
            cheaterViewModel: cheaterViewModel,
            startLeft: cWheelSecondRowLeft,
            startTop: cWheelFirstRowTop + cHeightInterval,
            numSlots: cInnerLetterSlotsForWheel,
            indexShift: cSecondRowIndexShift),
        ...loopOverWheelLetterSlots(
            cheaterViewModel: cheaterViewModel,
            startLeft: cWheelSecondRowLeft,
            startTop: cWheelFirstRowTop + (cHeightInterval * cAfterTwoRows),
            numSlots: cInnerLetterSlotsForWheel,
            indexShift: cThirdRowIndexShift),
        ...loopOverWheelLetterSlots(
            cheaterViewModel: cheaterViewModel,
            startLeft: cWheelFirstRowLeft,
            startTop: cWheelFirstRowTop + (cHeightInterval * cAfterThreeRows),
            numSlots: cTopAndBottomLetterSlotsForWheel,
            indexShift: cFourthRowIndexShift),
      ],
    );
  }

  // very similar code to hangman letter,
  Widget absentLetter(BuildContext context, int index,
      HangManWheelOfFortuneExclusionViewModel exclusionViewModel) {
    return Container(
      width: 50,
      margin: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          exclusionViewModel.deleteExcludedLetter(index);
        },
        child: Align(
          alignment: Alignment.center,
          child: Text(exclusionViewModel.getExcludedLetterAtIndex(index)),
        ),
      ),
    );
  }

  Widget absentLetters(BuildContext context) {
    HangManWheelOfFortuneViewCheaterModel cheaterViewModel =
        Provider.of<HangManWheelOfFortuneViewCheaterModel>(context,
            listen: true);

    HangManWheelOfFortuneExclusionViewModel exclusionViewModel =
        Provider.of<HangManWheelOfFortuneExclusionViewModel>(context,
            listen: true);

    return Row(
      children: [
        DragTarget<String>(
          onAccept: (String letter) {
            if (!cheaterViewModel.doesCheaterContainThisLetter(letter)) {
              exclusionViewModel.addExcludedLetter(letter);
            }
          },
          builder: (BuildContext context, List<String?> draggedLetterList,
              List notUsedList) {
            String? hoveringLetter;
            bool isLetterInUse = false;
            if (draggedLetterList.isNotEmpty) {
              hoveringLetter = draggedLetterList.first;
              isLetterInUse = cheaterViewModel
                  .doesCheaterContainThisLetter(hoveringLetter!);
            }

            return Container(
              alignment: Alignment.center,
              height: 50.0,
              width: 200.0,
              color: Colors.grey[200],
              child: hoveringLetter != null
                  ? isLetterInUse
                      ? Text("Letter $hoveringLetter in use")
                      : Text("Dropping $hoveringLetter")
                  : const Text("Drag Unused Letters Here"),
            );
          },
        ),
        Expanded(
          child: SizedBox(
            height: cLetterSizeInPixels,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: exclusionViewModel.getExcludedLetterTotal(),
              itemBuilder: (context, index) {
                return absentLetter(context, index, exclusionViewModel);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget letterDisplay(BuildContext context, int index) {
    Set<String> theAlphabetSet = AlphabetClass.alphabet;
    List<String> theAlphabetList = theAlphabetSet.toList();
    String theCurrentLetter = theAlphabetList[index];

    HangManWheelOfFortuneExclusionViewModel exclusionViewModel =
        Provider.of<HangManWheelOfFortuneExclusionViewModel>(context,
            listen: true);

    if (exclusionViewModel.excludedLettersContains(theCurrentLetter)) {
      return Container();
    }

    return Draggable(
      data: theCurrentLetter,
      feedback: Material(
        child: Container(
          width: cLetterSizeInPixels,
          height: cLetterSizeInPixels,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
              child: Text(
                  theCurrentLetter)),
        ),
      ),
      childWhenDragging: Container(
        width: cLetterSizeInPixels,
        height: cLetterSizeInPixels,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Container(
        width: cLetterSizeInPixels,
        margin: const EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () => {},
          child: Align(
            alignment: Alignment.center,
            child: Text(
                theCurrentLetter), // Replace "items[index]" with actual data
          ),
        ),
      ),
    );
  }

  Widget alphabetDisplay(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: cLetterSizeInPixels,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cSizeOfPlainAlphabet,
              itemBuilder: (context, index) {
                return letterDisplay(context, index);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget possibleMatch(BuildContext context, int index,
      HangManWheelOfFortunePossibleMatchesViewModel possibleMatchViewModel) {
    return SizedBox(
      height: 20,
      child: ListTile(
        title: Text(
          possibleMatchViewModel.getPossibleMatch(index),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  Widget possibleMatches(BuildContext context) {
    HangManWheelOfFortunePossibleMatchesViewModel possibleMatchViewModel =
        Provider.of<HangManWheelOfFortunePossibleMatchesViewModel>(context,
            listen: true);

    double calculateHeightForPossibleMatches(BuildContext context) {
      double screenHeight =
          MediaQuery.of(context).size.height - (cCommonMarginInPixels * 2);

      double possibleMatchesHeight = 450;

      return possibleMatchesHeight;
    }

    possibleMatchViewModel.buildPossibleMatches();

    return SizedBox(
      height: calculateHeightForPossibleMatches(context),
      child: Scrollbar(
        thumbVisibility: true, // I want the user to see the scrollbar at all times
        controller: matchesScrollController,
        child: ListView.builder(
          controller: matchesScrollController,
          itemCount: possibleMatchViewModel.getPossibleMatchesTotal(),
          itemBuilder: (context, index) {
            return possibleMatch(context, index, possibleMatchViewModel);
          },
        ),
      ),
    );
  }

  Widget headingText(String heading) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(heading),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {

    HangManWheelOfFortuneViewModel viewModel =
        Provider.of<HangManWheelOfFortuneViewModel>(context, listen: true);

    // these provider.of references must be here to ensure the providers get initialized
    // they need the persistent storage as that initializes any
    // saved settings by the last cheat the user entered

    HangManWheelOfFortuneViewCheaterModel cheaterViewModel =
    Provider.of<HangManWheelOfFortuneViewCheaterModel>(context, listen: false);

    HangManWheelOfFortuneExclusionViewModel exclusionViewModel =
    Provider.of<HangManWheelOfFortuneExclusionViewModel>(context, listen: false);

    HangManWheelOfFortunePossibleMatchesViewModel possibleMatchesViewModel =
    Provider.of<HangManWheelOfFortunePossibleMatchesViewModel>(context, listen: false);

    HangManWheelOfFortunePersistentStorage persistentStorageViewModel =
        Provider.of<HangManWheelOfFortunePersistentStorage>(context, listen: false);

    String mode = viewModel.fetchGameMode();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Cheater for Hangman/Wheel of Fortune"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(cCommonMarginInPixels),
        child: Column(
          children: <Widget>[
            cheaterMode(viewModel),
            headingText("Current cheat is $mode"),
            if (mode == cHangManMode) hangManPrep(context),
            (mode == cHangManMode)
                ? hangManWordItself(context)
                : (mode == cWheelOfFortuneMode)
                    ? wheelOfFortuneGrid(context)
                    : Container(),
            headingText("Letters not present"),
            absentLetters(context),
            headingText("Alphabet"),
            alphabetDisplay(context),
            // without consumer here, this doesn't update immediately
            Consumer<HangManWheelOfFortunePossibleMatchesViewModel>(
              builder: (context, possibleMatchViewModel, child) {
                return headingText("${possibleMatchViewModel.getPossibleMatchesTotal()} possible matches");
              },
            ),
            possibleMatches(context),
          ],
        ),
      ),
    );
  }
}
