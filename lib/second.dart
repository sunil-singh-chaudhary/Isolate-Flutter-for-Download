import 'dart:isolate';
import 'package:download_demo/model.dart';
import 'package:flutter/material.dart';

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
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Isolate isolate;
  late ReceivePort receivePort;
  late String msg = "";

  @override
  void initState() {
    // TODO: implement initState
    spawnNewIsolate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
          future: spawnNewIsolate(),
          initialData: "Loading text..",
          builder: (BuildContext context, AsyncSnapshot<String> text) {
            return Center(
              child: Text(
                text.data!.toString(),
              ),
            );
          }),
    );
  }

  Future<String> spawnNewIsolate() async {
    receivePort = ReceivePort();

    try {
      isolate = await Isolate.spawn(sayHello, receivePort.sendPort);

      print("Isolate: $isolate");

      receivePort.listen((dynamic message) {
        setState(() {
          msg = message;
        });

        print('New message from Isolate:' + msg);
      });
    } catch (e) {
      print("Error: $e");
    }
    return msg;
  }

  //spawn accepts only static methods or top-level functions

  static void sayHello(SendPort sendPort) {
    sendPort.send("Hello from Isolate");
  }

  @override
  void dispose() {
    super.dispose();

    receivePort.close();

    isolate.kill();
  }
}
