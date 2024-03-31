import 'package:custom_calendar_viewer/custom_calendar_viewer.dart';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

void main() {
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
  String local = 'en';

  List<RangeDate> ranges = [];

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

  void _handleSaveButtonPressed(List<RangeDate> ranges) {
    print(ranges);
  }

  void _handleCheckButtonPressed(List<RangeDate> ranges) {
    DateTime nextStartPrediction = (ranges[ranges.length - 1].start).add(
        Duration(days: averageDistanceBetweenDates(parseDateRanges(ranges))));
    RangeDate nextPrediction = RangeDate(
        start: nextStartPrediction,
        end: nextStartPrediction.add(Duration(days: averageDuration(ranges))),
        color: Color(0x272794ff));
    setState(() {
      ranges.add(nextPrediction);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: local == 'en' ? TextDirection.ltr : TextDirection.rtl,
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
                          // onDatesUpdated: (newDates) {
                          //   print('onDatesUpdated');
                          //   print(newDates.length);
                          // },
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
                          _handleSaveButtonPressed(ranges);
                        },
                        child: const Text('Save'),
                      ),
                      const SizedBox(height: 10), // Add space between buttons
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
}
