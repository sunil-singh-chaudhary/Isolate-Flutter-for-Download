import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ByteData data =
  //     await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  // SecurityContext.defaultContext
  //     .setTrustedCertificatesBytes(data.buffer.asUint8List());
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isolate API Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  var list = [];

  @override
  void initState() {
    loadIsolate();
    super.initState();
  }

  Future loadIsolate() async {
    ReceivePort receiveport = ReceivePort();
    await Isolate.spawn(isolateEntry, receiveport.sendPort);

    SendPort sendPort = await receiveport.first; // first port first is information other is port info so we get reciveport.first

    //multiple port each time
    List message = await sendRecieve(
        sendPort, "https://jsonplaceholder.typicode.com/comments");
    setState(() {
      list = message;
      print('LIST_EACH_TIME-->  ' + message.toString());
    });
  }

  static isolateEntry(SendPort sendPort) async {
    ReceivePort receiveport = ReceivePort();
    sendPort.send(receiveport.sendPort);

    await for (var msg in receiveport) {
      String newUrl = msg[0];
      print('newUrl-->' + newUrl);
      SendPort replyport = msg[1];
      print('replyport-->' + replyport.toString());
      var response = await http.get(Uri.parse(newUrl));
      print('response-->' + response.statusCode.toString());
      replyport.send(json.decode(response.body));
    }
  }

//for multiple calls

  Future sendRecieve(SendPort send, message) {
    ReceivePort responsePort = ReceivePort();
    send.send([message, responsePort.sendPort]);
    return responsePort.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: loadData(),
    );
  }

  Widget loadData() {
    if (list.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return ListView.separated(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return Container(child: Text('Item-->: ${list[index]['email']}'));
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            height: 1,
          );
        },
      );
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
