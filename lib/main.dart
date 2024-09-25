import 'dart:async';
import 'package:reminder_app/Components/colors.dart';
import 'package:reminder_app/Provider/provider.dart';
import 'package:reminder_app/add_schedule.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!
      .requestNotificationsPermission();
  runApp(ChangeNotifierProvider(
    create: (contex) => Alarmprovider(),
    child: const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool value = false;
  @override
  void initState() {
    context.read<Alarmprovider>().inituilize(context);
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    super.initState();
    context.read<Alarmprovider>().getData();
  }

  @override
  Widget build(BuildContext context) {
    double topContainerHeight = MediaQuery.of(context).size.height * 0.4;
    return Scaffold(
      backgroundColor: primaryColor,
      body: SingleChildScrollView(
        reverse: true,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 50),
              height: topContainerHeight,
              child: Center(
                  child: Text(
                DateFormat.jms().format(
                  DateTime.now(),
                ),
                style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 46,
                    color: Colors.white),
              )),
            ),
            Consumer<Alarmprovider>(builder: (context, alarm, child) {
              return Column(
                children: [
                  Container(
                    height: 40,
                    padding: const EdgeInsets.only(left: 8, bottom: 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                            child: Text(
                          '  Alerts',
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        )),
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AddAlarm()));
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 28,
                            )),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.more_vert_outlined,
                                color: Colors.white, size: 28))
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 6, right: 6),
                    height: MediaQuery.of(context).size.height -
                        topContainerHeight -
                        40,
                    child: alarm.modelist.isEmpty
                        ? const Center(
                            child: Text('No alerts',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 18)),
                          )
                        : NotificationListener<OverscrollIndicatorNotification>(
                            onNotification: (overScroll) {
                              overScroll.disallowIndicator();
                              return false;
                            },
                            child: ListView.builder(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 15),
                                itemCount: alarm.modelist.length,
                                itemBuilder: (buildContext, index) {
                                  return Card(
                                    color: secondaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    elevation: 5,
                                    child: SizedBox(
                                      height: 85,
                                      child: Center(
                                        child: ListTile(
                                          title: Text(
                                            alarm.modelist[index].dateTime!,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                                color: Colors.white),
                                          ),
                                          subtitle: Text(
                                              alarm.modelist[index].label
                                                  .toString(),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15)),
                                          trailing: SizedBox(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.4,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                FittedBox(
                                                  child: Text(
                                                      alarm.modelist[index]
                                                          .when!,
                                                      style: const TextStyle(
                                                          color: Colors.white)),
                                                ),
                                                const SizedBox(width: 8),
                                                CupertinoSwitch(
                                                    value: (alarm
                                                                .modelist[index]
                                                                .milliseconds! <
                                                            DateTime.now()
                                                                .microsecondsSinceEpoch)
                                                        ? false
                                                        : alarm.modelist[index]
                                                            .check,
                                                    onChanged: (v) {
                                                      alarm.editSwitch(
                                                          index, v);
                                                      alarm.cancelNotification(
                                                          alarm.modelist[index]
                                                              .id!);
                                                    }),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
