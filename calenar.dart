import 'package:flutter/material.dart';
import 'package:flutter_application_3/boxes.dart';
import 'package:flutter_application_3/ranges.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:custom_calendar_viewer/custom_calendar_viewer.dart';

Future main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(RangesAdapter());
  boxRanges = await Hive.openBox<Range>('rangesBox');
  runApp(const MyCalendar());
}

class MyCalendar extends StatelessWidget {
  const MyCalendar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffffffff)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Calendar'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int checked =
      0; //  USED AS BOOL. CHANGES TO 1 IF THE "CHECK" BUTTON WAS PRESSED. needed not to save the predicted date.
  String local = 'en';
  List<RangeDate> ranges = [];

  late Future<Box<Range>> _boxRangesFuture;

  @override
  void initState() {
    super.initState();
    _boxRangesFuture = _openBoxRanges();
  }

  Future<Box<Range>> _openBoxRanges() async {
    await Hive.initFlutter();
    Hive.registerAdapter(RangesAdapter());
    return Hive.openBox<Range>('rangesBox');
  }

  int averageDistanceBetweenDates(List<DateTime> dates) {
    // РАССЧИТЫВАЕТ СРЕДНИЙ ПЕРИОД ВРЕМЕНИ(ЧИСЛО ДНЕЙ) МЕЖДУ ПЕРВЫМ ДНЕМ КАЖДОГО ЦИКЛА
    if (dates.isEmpty || dates.length == 1) {
      return 0;
    }
    int totalDays = 0;
    for (int i = 1; i < dates.length; i++) {
      totalDays += dates[i].difference(dates[i - 1]).inDays;
    }
    return totalDays ~/ (dates.length - 1);
  }

  int averageDuration(List<RangeDate> dateRanges) {
    int totalDurationInDays = 0;
    for (int i = 0; i < dateRanges.length; i++) {
      totalDurationInDays +=
          dateRanges[i].end.difference(dateRanges[i].start).inDays;
    }
    return totalDurationInDays ~/
        dateRanges.length; // Calculate integer division
  }

  List<DateTime> parseDateRanges(List<RangeDate> dateRanges) {
    // СОЗДАЕТ СПИСОК С ДНЯМИ (DATETIME) НАЧАЛА КАЖДОГО ЦИКЛА
    List<DateTime> startDates = [];
    for (RangeDate range in dateRanges) {
      startDates.add(range.start);
    }
    return startDates;
  }

  void _handleSaveButtonPressed(Box<Range> boxRanges, List<RangeDate> ranges) {
    boxRanges.clear();
    for (int i = 0; i < ranges.length - checked; i++) {
      boxRanges.add(Range(start: ranges[i].start, end: ranges[i].end));
    }
  }

  void _handleCheckButtonPressed(List<RangeDate> ranges) {
    DateTime nextStartPrediction = (ranges[ranges.length - 1].start).add(
        Duration(days: averageDistanceBetweenDates(parseDateRanges(ranges))));
    RangeDate nextPrediction = RangeDate(
        start: nextStartPrediction,
        end: nextStartPrediction.add(Duration(days: averageDuration(ranges))),
        color: Colors.cyan);
    setState(() {
      checked = 1;
      ranges.add(nextPrediction);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Box<Range>>(
      future: _boxRangesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final boxRanges = snapshot.data as Box<Range>;
          Iterable storedRanges = boxRanges.values;
          for (Range range in storedRanges) {
            ranges.add(RangeDate(start: range.start, end: range.end));
          }
          return Directionality(
            textDirection:
                local == 'en' ? TextDirection.ltr : TextDirection.rtl,
            child: Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Ella Calendar',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              CustomCalendarViewer(
                                local: local,
                                dates: dates,
                                ranges: ranges,
                                calendarType: CustomCalendarType.multiRanges,
                                calendarStyle: CustomCalendarStyle.normal,
                                animateDirection:
                                    CustomCalendarAnimatedDirection.vertical,
                                movingArrowSize: 24,
                                spaceBetweenMovingArrow: 20,
                                closedDatesColor: Colors.grey.withOpacity(0.7),
                                showBorderAfterDayHeader: true,
                                showTooltip: false,
                                toolTipMessage: '',
                                calendarStartDay: CustomCalendarStartDay.monday,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Divider(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _handleSaveButtonPressed(boxRanges, ranges);
                              },
                              child: const Text('Save'),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                _handleCheckButtonPressed(ranges);
                              },
                              child: const Text('Check'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
