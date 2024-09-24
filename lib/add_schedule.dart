import 'dart:math';
import 'package:reminder_app/Components/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:reminder_app/Provider/provider.dart';

class AddAlarm extends StatefulWidget {
  const AddAlarm({super.key});
  @override
  State<AddAlarm> createState() => _AddAlaramState();
}

class _AddAlaramState extends State<AddAlarm> {
  late TextEditingController controller;
  String? dateTime;
  bool repeat = false;
  String? selectedActivity; // To store the selected activity
  DateTime? notificationtime;
  String? name = "";
  int? milliseconds;
  final List<String> activities = [
    'Wake up',
    'Go to the gym',
    'Breakfast',
    'Meetings',
    'Lunch',
    'Quick nap',
    'Go to the library',
    'Dinner',
    'Go to sleep'
  ];
  @override
  void initState() {
    controller = TextEditingController();
    context.read<Alarmprovider>().GetData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              // color: Colors.amber,
              height: MediaQuery.of(context).size.height * 0.4,
              child: Center(
                  child: CupertinoTheme(
                data: const CupertinoThemeData(
                  brightness: Brightness.dark,
                ),
                child: CupertinoDatePicker(
                  showDayOfWeek: true,
                  minimumDate: DateTime.now(),
                  dateOrder: DatePickerDateOrder.dmy,
                  onDateTimeChanged: (va) {
                    dateTime = DateFormat().add_jms().format(va);
                    milliseconds = va.microsecondsSinceEpoch;
                    notificationtime = va;
                  },
                ),
              )),
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.7,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Repeat daily",
                      style: TextStyle(color: Colors.white, fontSize: 17)),
                  CupertinoSwitch(
                    value: repeat,
                    onChanged: (bool value) {
                      repeat = value;
                      setState(() {
                        if (repeat == true) {
                          name = "Everyday";
                        } else {
                          name =
                              DateFormat('EEE MMM d').format(notificationtime!);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(8, 5, 8, 8),
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.sizeOf(context).height * 0.3,
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overScroll) {
                  overScroll.disallowIndicator();
                  return false;
                },
                child: CupertinoPicker(
                  backgroundColor: primaryColor,
                  itemExtent: 32.0, // Height of each item in the picker
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      // Ensure "Select Activity" is treated as a placeholder
                      selectedActivity =
                          (index == 0) ? null : activities[index - 1];
                      controller.text =
                          selectedActivity ?? ""; // Update controller
                    });
                  },
                  children: [
                    const Center(
                      child: Text(
                        "Select Activity",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ...activities.map((String value) {
                      return Center(
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 55,
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.7,
              child: ElevatedButton(
                onPressed: selectedActivity == null
                    ? null
                    : () {
                        Random random = Random();
                        int randomNumber = random.nextInt(100);

                        if (repeat) {
                          name = "Everyday";
                        } else {
                          name =
                              DateFormat('EEE MMM d').format(notificationtime!);
                        }
                        context.read<Alarmprovider>().SetAlaram(
                              controller.text, // Selected activity
                              dateTime!, // Formatted date/time
                              true, // Alarm is active by default
                              name!, // "Everyday" or formatted date
                              randomNumber, // Random ID for the alarm
                              milliseconds!, // Timestamp in milliseconds
                            );
                        context.read<Alarmprovider>().SetData();
                        context.read<Alarmprovider>().secduleNotification(
                            notificationtime!, randomNumber);
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  backgroundColor:
                      selectedActivity == null ? Colors.grey : secondaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text("Set Alert"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
