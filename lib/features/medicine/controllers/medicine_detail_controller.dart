import 'package:flutter/material.dart';

class MedicineDetailController {
  late TextEditingController medicineNameController;

  late TextEditingController functionController;

  List<TextEditingController> consumeTimeControllers = [];

  late TextEditingController doseController;

  late String selectedCondition;

  List<bool> activeDays = [];

  void init({
    required String medicineName,
    required String function,
    required String dose,
    required String condition,
    required List<bool> days,
    required List<String> consumeTimes,
  }) {
    medicineNameController = TextEditingController(text: medicineName);

    functionController = TextEditingController(text: function);

    consumeTimeControllers = consumeTimes
        .map((time) => TextEditingController(text: time))
        .toList();

    doseController = TextEditingController(text: dose);

    selectedCondition = condition;

    activeDays = List.from(days);
  }

  void dispose() {
    medicineNameController.dispose();

    functionController.dispose();

    for (final controller in consumeTimeControllers) {
      controller.dispose();
    }

    doseController.dispose();
  }

  void toggleDay(int index) {
    activeDays[index] = !activeDays[index];
  }

  void addConsumeTime() {
    consumeTimeControllers.add(TextEditingController());
  }

  void removeConsumeTime(int index) {
    consumeTimeControllers[index].dispose();

    consumeTimeControllers.removeAt(index);
  }

  void changeCondition(String value) {
    selectedCondition = value;
  }
}
