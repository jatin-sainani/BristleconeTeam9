import 'package:flutter/material.dart';
import 'BackgroundWork.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Graphs extends StatefulWidget
{
  _GraphsState createState()=> _GraphsState();
}

class _GraphsState extends State<Graphs>
{


  static List<charts.Series<Vib, DateTime>> _VibrationData() {
    final data = [
      new Vib(new DateTime(2019, 11, 27), 1000),
      new Vib(new DateTime(2019, 12, 5), 800),
      new Vib(new DateTime(2019, 12, 8), 1100),
      new Vib(new DateTime(2019, 12, 13), 1000),
      new Vib(new DateTime(2019, 12, 15), 800),
    ];

    return [
      new charts.Series<Vib, DateTime>(
        id: 'Vibrations',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Vib sales, _) => sales.time,
        measureFn: (Vib sales, _) => sales.vibration,
        data: data,

      )
    ];
  }

  /// Sample time series data type.

  static List<charts.Series<Vib, DateTime>> _currentData() {
    final data = [
      new Vib(new DateTime(2019, 11, 27), 100),
      new Vib(new DateTime(2019, 12, 5), 99),
      new Vib(new DateTime(2019, 12, 8), 95),
      new Vib(new DateTime(2019, 12, 13), 105),
      new Vib(new DateTime(2019, 12, 15), 100),
    ];

    return [
      new charts.Series<Vib, DateTime>(
        id: 'Current',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Vib sales, _) => sales.time,
        measureFn: (Vib sales, _) => sales.vibration,
        data: data,

      )
    ];
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: <Widget>[
              Tab(child: Text('Temperature'),),
              Tab(child: Text('Vibration'),),
              Tab(child: Text('Current'),)
            ],
          )),
        body:
              TabBarView(children: [
                Center(
                  child: Container(child: SimpleTimeSeriesChart.withSampleData(),
                    height: 400.0,
                  padding: EdgeInsets.all(10.0)
                  ),
                ),
                Center(
                  child: Container(child: SimpleTimeSeriesChart(_VibrationData()),
                    height: 400.0,
                      padding: EdgeInsets.all(10.0)),
                ),
                Center(
                  child: Container(child: SimpleTimeSeriesChart(_currentData()),
                    height: 400.0,
                      padding: EdgeInsets.all(10.0)),
                ),
              ]

      ),
      )
    );
  }
}

class Vib {
   DateTime time;
   double vibration;
   Vib(this.time, this.vibration);
}