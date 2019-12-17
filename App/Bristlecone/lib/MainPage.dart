import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';

import './DiscoveryPage.dart';
import './SelectBondedDevicePage.dart';
import './BackgroundCollectingTask.dart';
import './BackgroundCollectedPage.dart';
import 'BackgroundWork.dart';
import 'Graphs.dart';

//import './LineChart.dart';
class MainPage extends StatefulWidget {

  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer _discoverableTimeoutTimer;

  BackgroundCollectingTask _collectingTask;

  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();
    
    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() { _bluetoothState = state; });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() { _name = name; });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predictive Maintenance',
        ),
          centerTitle: true,

      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Divider(),
            /*ListTile(
              title: const Text('General')
            ),*/
            SwitchListTile(
              title: const Text('Enable Bluetooth',
                  style: TextStyle(
                  fontSize: 18.0,
                    fontWeight: FontWeight.w800

              ),
              ),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                // Do the request and update with the true value then
                future() async { // async lambda seems to not working
                  if (value)
                    await FlutterBluetoothSerial.instance.requestEnable();
                  else
                    await FlutterBluetoothSerial.instance.requestDisable();
                }
                future().then((_) {
                  setState(() {});
                });
              },
            ),
            ListTile(
              title: const Text('Bluetooth status',
                style: TextStyle(
                    fontSize: 18.0,


                ),),
              subtitle: Text(_bluetoothState.toString()),
              trailing: RaisedButton(
                child: const Text('Settings'),
                onPressed: () { 
                  FlutterBluetoothSerial.instance.openSettings();
                },
              ),
            ),
           /* ListTile(
              title: const Text('Local adapter address'),
              subtitle: Text(_address),
            ),*/
            ListTile(
              title: const Text('Local adapter name',
                style: TextStyle(
                  fontSize: 18.0,


                ),),
              subtitle: Text(_name),
              onLongPress: null,
            ),

            Divider(),
            Padding(padding: EdgeInsets.all(10.0)),
            ListTile(
              title: const Text('Devices discovery and connection',
                style: TextStyle(
                  fontSize: 18.0,


                ),)
            ),
            SwitchListTile(
              title: const Text('Auto-try specific pin when pairing',
                style: TextStyle(
                  fontSize: 18.0,


                ),),
              subtitle: const Text('Pin 1234',
              ),
              value: _autoAcceptPairingRequests,
              onChanged: (bool value) {
                setState(() {
                  _autoAcceptPairingRequests = value;
                });
                if (value) {
                  FlutterBluetoothSerial.instance.setPairingRequestHandler((BluetoothPairingRequest request) {
                    print("Trying to auto-pair with Pin 1234");
                    if (request.pairingVariant == PairingVariant.Pin) {
                      return Future.value("1234");
                    }
                    return null;
                  });
                }
                else {
                  FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
                }
              },
            ),
            Container(height: 100,),
            ListTile(
              title: RaisedButton(

                child: const Text('Explore discovered devices',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600
                ),),
                  padding: EdgeInsets.all(15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0) ),
                highlightColor: Colors.blue,
                splashColor: Colors.white,
                onPressed: () async {
                  final BluetoothDevice selectedDevice = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) { return DiscoveryPage(); })
                  );

                  if (selectedDevice != null) {
                    print('Discovery -> selected ' + selectedDevice.address);
                  }
                  else {
                    print('Discovery -> no device selected');
                  }
                }
              ),
            ),

            Padding(padding: EdgeInsets.all(10.0)),
            ListTile(

              title: RaisedButton(

                  padding: EdgeInsets.all(15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0) ),
                highlightColor: Colors.blue,
                splashColor: Colors.white,
                child: (
                  (_collectingTask != null && _collectingTask.inProgress) 
                  ? const Text('Disconnect and stop background collecting',style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600
                  ),
                  )
                  : const Text('Connect to start background collecting',
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600
                    ),
              )
            ),
                onPressed: () async {
                  if (_collectingTask != null && _collectingTask.inProgress) {
                    await _collectingTask.cancel();
                    setState(() {/* Update for `_collectingTask.inProgress` */});
                  }
                  else {
                    final BluetoothDevice selectedDevice = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) { return SelectBondedDevicePage(checkAvailability: false); })
                    );

                    if (selectedDevice != null) {
                      await _startBackgroundTask(context, selectedDevice);
                      setState(() {/* Update for `_collectingTask.inProgress` */});
                    }
                  }
                },
              ),
            ),
            Padding(padding: EdgeInsets.all(10.0)),
            ListTile(
              title: RaisedButton(
                padding: EdgeInsets.all(15.0) ,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0) ),
                  highlightColor: Colors.blue,
                  splashColor: Colors.white,
                child: const Text('View background collected data',
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600
                  ),
                ),
                onPressed: (_collectingTask != null) ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return ScopedModel<BackgroundCollectingTask>(
                        model: _collectingTask,
                        child: BackgroundCollectedPage(),
                      );
                    })
                  );
                } : () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)
                  {
                    return Graphs();

                  }));
                }
              )
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startBackgroundTask(BuildContext context, BluetoothDevice server) async {
    try {
      _collectingTask = await BackgroundCollectingTask.connect(server);
      await _collectingTask.start();
    }
    catch (ex) {
      if (_collectingTask != null) {
        _collectingTask.cancel();
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error occured while connecting'),
            content: Text("${ex.toString()}"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
