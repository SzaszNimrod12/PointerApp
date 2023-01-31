import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:developer';
import 'package:websocket/main.dart';

class PointerController extends StatefulWidget {
  const PointerController({
    super.key,
    required this.title,
  });

  final String title;

  @override
  _PointerControllerState createState() => _PointerControllerState();
}

class _PointerControllerState extends State<PointerController> {
  final TextEditingController _controller = TextEditingController();
  final _channel = WebSocketChannel.connect(
    //Uri.parse('ws://192.168.0.154:8080'),
    Uri.parse('ws://$resultUri'),
  );
  List<double>? _accelerometerValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  dynamic isPressed;
  dynamic response;

  @override
  Widget build(BuildContext context) {
    final accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            StreamBuilder(
              stream: _channel.stream,
              builder: (context, snapshot) {
                return Text(snapshot.hasData ? '${snapshot.data}' : '');
              },
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Accelerometer: $accelerometer'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: GestureDetector(
                  onLongPressStart: (_) async {
                    _sendMessageCalibrate();
                    _sendMessageStartLaserPointer();
                    isPressed = true;
                    do {
                      //print('long pressing');
                      _sendMessage();
                      //testeles milyat 1 masodperc kesleltetes van de lehet ez sokall kisebb.
                      await Future.delayed(const Duration(milliseconds: 100));
                    } while (isPressed);
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    color: Colors.blue,
                    padding: const EdgeInsets.all(12),
                    child: const Center(
                        child: Text(
                      "Laser Pointer",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    )),
                  ),
                  onLongPressEnd: (_) {
                    _sendMessageStopLaserPointer();
                    setState(() => isPressed = false);
                  }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: GestureDetector(
                  onLongPressStart: (_) async {
                    _sendMessageStartDraw();
                    isPressed = true;
                    do {
                      _sendMessage();
                      await Future.delayed(const Duration(milliseconds: 100));
                    } while (isPressed);
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    color: Colors.blue,
                    padding: const EdgeInsets.all(12),
                    child: const Center(
                        child: Text(
                      "Draw",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    )),
                  ),
                  onLongPressEnd: (_) {
                    _sendMessageStopDraw();
                    setState(() => isPressed = false);
                  }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0,25,0,10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _sendMessageLeftKey();
                      },
                      icon: const Icon(Icons.navigate_before_rounded, size: 25),
                      label: const Text(
                        "Previous slide",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(150, 50),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _sendMessageRightKey();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(150, 50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "Next slide",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                            child: Icon(Icons.navigate_next_rounded, size: 25),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessageStop,
        tooltip: 'Send server stop message',
        backgroundColor: Colors.blue,
        child: const Icon(Icons.stop_screen_share_outlined,color: Colors.white,),
      ),
    );
  }

  @override
  void initState() {
    lisenSensorData();
    super.initState();
  }

  void _sendMessage() {
    _channel.sink.add(response);
  }

  void _sendMessageStop() {
    var responseAction = json.encode({'type': 'actions', 'action': 'stop'});
    _channel.sink.add(responseAction);
  }

  void _sendMessageCalibrate() {
    var responseAction =
        json.encode({'type': 'actions', 'action': 'calibrate'});
    _channel.sink.add(responseAction);
  }

  void _sendMessageStopLaserPointer() {
    var responseAction =
        json.encode({'type': 'actions', 'action': 'stopLaserPointer'});
    _channel.sink.add(responseAction);
  }

  void _sendMessageStartLaserPointer() {
    var responseAction =
        json.encode({'type': 'actions', 'action': 'startLaserPointer'});
    _channel.sink.add(responseAction);
  }

  void _sendMessageStopDraw() {
    var responseAction = json.encode({'type': 'actions', 'action': 'stopDraw'});
    _channel.sink.add(responseAction);
  }

  void _sendMessageStartDraw() {
    var responseAction =
        json.encode({'type': 'actions', 'action': 'startDraw'});
    _channel.sink.add(responseAction);
  }

  void _sendMessageLeftKey() {
    var responseAction =
        json.encode({'type': 'actions', 'action': 'pressLeft'});
    _channel.sink.add(responseAction);
  }

  void _sendMessageRightKey() {
    var responseAction =
        json.encode({'type': 'actions', 'action': 'pressRight'});
    _channel.sink.add(responseAction);
  }

  void lisenSensorData() {
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
            response = json.encode(
                {'type': 'points', 'x': event.x, 'y': event.y, 'z': event.z});
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }
}
