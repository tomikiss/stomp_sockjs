library echo;

import "dart:html";

import 'package:logging/logging.dart';
import 'dart:convert';
import 'package:stomp/stomp.dart';
import 'package:stomp_sockjs/stomp_sockjs.dart' as StompSockJs;



DivElement div  = querySelector('#first div');
InputElement inp  = querySelector('#first input');
FormElement form = querySelector('#first form');

_log(LogRecord l) {
  div
    ..append(new Element.html("<code/>")..text = "${l.message}")
    ..append(new Element.html("<br>"))
    ..scrollTop += 10000;
}

main() {
  // Setup Logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen(_log);

  final LOG = new Logger("sockjs");

  LOG.info("Starting");

  
  print("before connect");;
  //STOMP+SOCKJS 3.  
  StompSockJs.connect('/hello', host: 'http://localhost:8080').then((StompClient client) {  
    print("success sockjs connection");        

    //sending STOMP message
    var message={ "name": "hi dart" };
    print(JSON.encode(message));
    client.sendJson('/app/hello', message);    
    
    //subscribe STOMP messages
    client.subscribeString("0", '/topic/greetings',
        (headers, message) {  
      print("get message"+message);
    });
    
    
  });
  
}
