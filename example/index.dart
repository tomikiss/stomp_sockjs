library echo;

import "dart:html";
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:stomp/stomp.dart';
import 'package:stomp_sockjs/stomp_sockjs.dart' as StompSockJs;


ButtonElement connectButton = querySelector("#connect");
ButtonElement disconnectButton = querySelector("#disconnect");
ParagraphElement response = querySelector("#response");
DivElement div = querySelector("#logdiv");
DivElement conversationDiv = querySelector("#conversationDiv");
Logger LOG = new Logger("sockjs-stomp");
TextInputElement nameInput = querySelector("#name");
StompClient stompClient;


_log(LogRecord l) {
  div
    ..append(new Element.html("<code/>")..text = "${l.message}")
    ..append(new Element.html("<br>"))
    ..scrollTop += 10000;
}

connect()
{
  StompSockJs.connect('/hello', host: 'http://localhost:8080').then((StompClient client) {  
    setConnected(true);
    stompClient = client;
    LOG.info("success sockjs connection");        
      
      
      //subscribe STOMP messages
      client.subscribeString("0", '/topic/greetings',
          (headers, message) {  
        showGreeting(message);
      });
    })
    .catchError((error) {
      print(error);
      LOG.info(error);
    });
}

disconnect()
{
  stompClient.disconnect();
  setConnected(false);
  LOG.info("Disconnected");
}

class Person
{
  String name;
}

sendName(){
  
  var message=new Person()..name = nameInput.value;
  print(JSON.encode(message));
  stompClient.sendJson('/app/hello', message);   
}

showGreeting(String message)
{
  ParagraphElement p = new ParagraphElement();
  p.style.wordWrap = 'break-word';
  p.append(new Text(message));
  response.append(p); 
}

setConnected(bool connected)
{
    connectButton.disabled = connected;
    disconnectButton.disabled = !connected;
    if(connected)
    {
        conversationDiv.hidden=false;  
    }else{
      conversationDiv.hidden=true;
    }
    
    response.innerHtml = "";
}

main() {
  // Setup Logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen(_log);
  LOG.info("Starting");
  connectButton.onClick.listen((event) => connect());
  disconnectButton.onClick.listen( (event) => disconnect());
}
