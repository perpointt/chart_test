import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru', 'RU')],
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _autoScrollingDeltaType = DateTimeIntervalType.months;
  var _dateRange = <ChartSampleData>[];
  var loading = false;

  @override
  void initState() {
    super.initState();
    _dateRange = generateDateRange(DateTime(2023, 8, 1)).map((e) {
      return ChartSampleData(x: e, y: Random().nextDouble());
    }).toList();
  }

  Future<void> _setDeltaType(DateTimeIntervalType value) async {
    setState(() {
      _autoScrollingDeltaType = value;
      loading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      loading = false;
    });
  }

  int get _autoScrollingDelta {
    switch (_autoScrollingDeltaType) {
      case DateTimeIntervalType.days:
        return 7;
      case DateTimeIntervalType.months:
        return 31;
      case DateTimeIntervalType.years:
        return 365;
      default:
        return 31;
    }
  }

  /*
  1) Дату самой первой тренировки — это будетп ервая дата для графика
  2) Если тренировка в эту дату была, то её показатели выводятся на графике
  3) Если тренировки в эту дату не было, то на графике в этот день выводятся пустые значения
  */

  DateFormat get _dateFormat {
    switch (_autoScrollingDeltaType) {
      case DateTimeIntervalType.days:
        return DateFormat('d MMMM', 'ru');
      case DateTimeIntervalType.months:
        return DateFormat('d-M-yyyy', 'ru');
      default:
        return DateFormat('d-M-yyyy', 'ru');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chart exampe')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SegmentedButton(
              segments: const [
                ButtonSegment(
                  value: DateTimeIntervalType.days,
                  label: Text('Days'),
                ),
                ButtonSegment(
                  value: DateTimeIntervalType.months,
                  label: Text('Months'),
                ),
                ButtonSegment(
                  value: DateTimeIntervalType.years,
                  label: Text('Years'),
                ),
              ],
              showSelectedIcon: false,
              selected: {_autoScrollingDeltaType},
              onSelectionChanged: (value) {
                _setDeltaType(value.first);
              },
            ),
            const SizedBox(height: 24),
            if (loading) ...[
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ] else ...[
              _buildDefaultColumnChart(),
            ],
            const Spacer(),
          ],
        ),
      ),
    );
  }

  /// Get default column chart
  SfCartesianChart _buildDefaultColumnChart() {
    return SfCartesianChart(
      trackballBehavior: TrackballBehavior(
        enable: true,
        hideDelay: 1000,
        activationMode: ActivationMode.longPress,
        builder: (context, details) {
          final value = details.point;
          return Container(
            color: Colors.black,
            padding: const EdgeInsets.all(4),
            child: Text(
              '${DateFormat('d-M-yyyy', 'ru').format(value?.x)}\n${value?.y?.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          );
        },
      ),
      primaryXAxis: DateTimeCategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        dateFormat: _dateFormat,
        autoScrollingDeltaType: _autoScrollingDeltaType,
        autoScrollingDelta: _autoScrollingDelta,
      ),
      primaryYAxis: const NumericAxis(),
      series: _getDefaultColumnSeries(),
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        zoomMode: ZoomMode.x,
        enablePanning: true,
      ),
    );
  }

  /// Get default column series
  List<ColumnSeries<ChartSampleData, DateTime>> _getDefaultColumnSeries() {
    return <ColumnSeries<ChartSampleData, DateTime>>[
      ColumnSeries<ChartSampleData, DateTime>(
        dataSource: _dateRange,
        xValueMapper: (ChartSampleData sales, _) => sales.x as DateTime,
        yValueMapper: (ChartSampleData sales, _) => sales.y,
      )
    ];
  }

  List<DateTime> generateDateRange(DateTime startDate) {
    DateTime now = DateTime.now();
    List<DateTime> dateList = [];

    for (DateTime date = startDate;
        date.isBefore(now) || date.isAtSameMomentAs(now);
        date = date.add(const Duration(days: 1))) {
      dateList.add(date);
    }

    return dateList;
  }
}

///Chart sample data
class ChartSampleData {
  /// Holds the datapoint values like x, y, etc.,
  ChartSampleData({
    this.x,
    this.y,
    this.xValue,
    this.yValue,
    this.secondSeriesYValue,
    this.thirdSeriesYValue,
    this.pointColor,
    this.size,
    this.text,
    this.open,
    this.close,
    this.low,
    this.high,
    this.volume,
  });

  /// Holds x value of the datapoint
  final dynamic x;

  /// Holds y value of the datapoint
  final num? y;

  /// Holds x value of the datapoint
  final dynamic xValue;

  /// Holds y value of the datapoint
  final num? yValue;

  /// Holds y value of the datapoint(for 2nd series)
  final num? secondSeriesYValue;

  /// Holds y value of the datapoint(for 3nd series)
  final num? thirdSeriesYValue;

  /// Holds point color of the datapoint
  final Color? pointColor;

  /// Holds size of the datapoint
  final num? size;

  /// Holds datalabel/text value mapper of the datapoint
  final String? text;

  /// Holds open value of the datapoint
  final num? open;

  /// Holds close value of the datapoint
  final num? close;

  /// Holds low value of the datapoint
  final num? low;

  /// Holds high value of the datapoint
  final num? high;

  /// Holds open value of the datapoint
  final num? volume;
}
