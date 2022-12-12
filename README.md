# download_demo

# Download images video etc.
  Uisng Flutter ISolates and Future Async
 
# ISolates used when we need to like parsing a huge chunk of data parallely , so Here 
   comes the concept of isolates we can first download data Using Async
   then parse it Using Isolate.spawn()
   
# Add these api in pubspec.yml
  flutter_downloader: ^1.9.1
  path_provider: ^2.0.11
  permission_handler: ^10.2.0
  http: ^0.13.5
   
   #init 
    @override
  void initState() {
      loadIsolate();
      super.initState();
  }
  
  
   Future loadIsolate() async {
    ReceivePort receiveport = ReceivePort();
    await Isolate.spawn(isolateEntry, receiveport.sendPort);
    SendPort sendPort = await receiveport.first;

    //multiple port each time
    List message = await sendRecieve(
        sendPort, "https://jsonplaceholder.typicode.com/comments");
    setState(() {
      list = message;
    });
  }

  static isolateEntry(SendPort sendPort) async {
    ReceivePort receiveport = ReceivePort();
    sendPort.send(receiveport.sendPort);

    await for (var msg in receiveport) {
      String newUrl = msg[0];
      print('newUrl-->' + newUrl);
      SendPort replyport = msg[1];
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
