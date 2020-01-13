import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:adhara_socket_io/adhara_socket_io.dart';

void main() => runApp(MyApp());

const String URI = "http://ditec.eu-4.evennode.com";

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> toPrint = ["trying to connect"];
  SocketIOManager manager;
  Map<String, SocketIO> sockets = {};
  Map<String, bool> _isProbablyConnected = {};

  @override
  void initState() {
    super.initState();
    manager = SocketIOManager();
    initSocket("default");
  }

  initSocket(String identifier) async {
    setState(() => _isProbablyConnected[identifier] = true);
    SocketIO socket = await manager.createInstance(SocketOptions(
      //Socket IO server URI
        URI,
        nameSpace: "/users",
        //Query params - can be used for authentication
        /*query: {
          "auth": "--SOME AUTH STRING---",
          "info": "new connection from adhara-socketio",
          "timestamp": DateTime.now().toString()
        },*/
        //Enable or disable platform channel logging
        enableLogging: false,
        transports: [Transports.WEB_SOCKET/*, Transports.POLLING*/] //Enable required transport
    ));
    socket.onConnect((data) {
      pprint("connected...");
      pprint(data);
      signin(identifier);
    });
    socket.onConnectError(pprint);
    socket.onConnectTimeout(pprint);
    socket.onError(pprint);
    socket.onDisconnect(pprint);
    socket.on("recibirmensaje", (data) => pprint(data));
    socket.connect();
    sockets[identifier] = socket;
  }

  bool isProbablyConnected(String identifier){
    return _isProbablyConnected[identifier]??false;
  }

  disconnect(String identifier) async {
    await manager.clearInstance(sockets[identifier]);
    setState(() => _isProbablyConnected[identifier] = false);
  }

  sendMessage(identifier) {
    if (sockets[identifier] != null) {
      pprint("sending message from '$identifier'...");

      sockets[identifier].emit("signin", [
        "Hello world!"
      ]);
      pprint("Message emitted from '$identifier'...");
    }
  }
  sendMessageWithACK(identifier){
    pprint("Sending ACK message from '$identifier'...");
   // List msg = ["Hello world!", 1, true, {"p":1}, [3,'r']];
    sockets[identifier].emitWithAck("enviarmensaje", [
      "Hello world!"
    ]).then( (data) {
      // this callback runs when this specific message is acknowledged by the server
      pprint("ACK recieved from '$identifier' de :  $data");
    });
  }

  signin(identifier){
    pprint("Sending signin message from '$identifier'...");
    // List msg = ["Hello world!", 1, true, {"p":1}, [3,'r']];
    sockets[identifier].emitWithAck("signin", [
      "952000243"
    ]).then( (data) {
      // this callback runs when this specific message is acknowledged by the server
      pprint("ACK recieved from '$identifier' de :  $data");
    });
  }

  sendMessagerequest(identifier){
    pprint("Sending ACK message from '$identifier'...");
    // List msg = ["Hello world!", 1, true, {"p":1}, [3,'r']];

    var midata={'note': "mi referencia",'email' :  "952000243", "latitude":-18.028580,"address":"Para grande Maria parado de bellido 386",
    "longitude":-70.267391,"zona":"Cualquiera","to":"","price":"","exactprice":"","tipomovil":"Cualquiera"};
    sockets[identifier].emitWithAck("new request", [
     midata
    ]).then( (data) {
      // this callback runs when this specific message is acknowledged by the server
      pprint("ACK recieved from '$identifier' de :  $data");
    });
  }

  pprint(data) {
    setState(() {
      if (data is Map) {
        data = json.encode(data);
      }
      print(data);
      toPrint.add(data);
    });
  }

  Container getButtonSet(String identifier){
    bool ipc = isProbablyConnected(identifier);
    return Container(
      height: 60.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            child: RaisedButton(
              child: Text("Connect"),
              onPressed: ipc?null:()=>initSocket(identifier),
              padding: EdgeInsets.symmetric(horizontal: 8.0),
            ),
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: RaisedButton(
                child: Text("Send Message"),
                onPressed: ipc?()=>sendMessagerequest(identifier):null,
                padding: EdgeInsets.symmetric(horizontal: 8.0),
              )
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: RaisedButton(
                child: Text("Disconnect"),
                onPressed: ipc?()=>disconnect(identifier):null,
                padding: EdgeInsets.symmetric(horizontal: 8.0),
              )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          textTheme: TextTheme(
            title: TextStyle(color: Colors.white),
            headline: TextStyle(color: Colors.white),
            subtitle: TextStyle(color: Colors.white),
            subhead: TextStyle(color: Colors.white),
            body1: TextStyle(color: Colors.white),
            body2: TextStyle(color: Colors.white),
            button: TextStyle(color: Colors.white),
            caption: TextStyle(color: Colors.white),
            overline: TextStyle(color: Colors.white),
            display1: TextStyle(color: Colors.white),
            display2: TextStyle(color: Colors.white),
            display3: TextStyle(color: Colors.white),
            display4: TextStyle(color: Colors.white),
          ),
          buttonTheme: ButtonThemeData(
              padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
              disabledColor: Colors.lightBlueAccent.withOpacity(0.5),
              buttonColor: Colors.lightBlue,
              splashColor: Colors.cyan
          )
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Adhara Socket.IO example'),
          backgroundColor: Colors.black,
          elevation: 0.0,
        ),
        body: Container(
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  child: Center(
                    child: ListView(
                      children: toPrint.map((String _) => Text(_ ?? "")).toList(),
                    ),
                  )
              ),
              Padding(
                padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: Text("Default Connection",),
              ),
              getButtonSet("default"),
              SizedBox(height: 12.0,)
            ],
          ),
        ),
      ),
    );
  }
}
