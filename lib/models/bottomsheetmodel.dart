import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyBottomSheetModel extends StateNotifier<bool> {
  MyBottomSheetModel() : super(false);

  bool get visible => state;//getter

  void changeState() {//method to change state
    state = !state;
  }
}

// Define the provider for MyBottomSheetModel
final myBottomSheetProvider = StateNotifierProvider<MyBottomSheetModel, bool>(
      (ref) => MyBottomSheetModel(),
);
