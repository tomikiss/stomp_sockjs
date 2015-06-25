library stomp_sockjs;

import "dart:async";

import "package:stomp/stomp.dart" show StompClient;
import "package:stomp/impl/plugin.dart" show StringStompConnector;
import "package:sockjs_client/sockjs_client.dart" as SockJS;

SockJS.Client _socket;
Future<StompClient> connect(String url, {
        String host,
        String login,
        String passcode,
        List<int> heartbeat,
        List<String> protocolsWhiteList,
        void onDisconnect(StompClient client),
        void onError(StompClient client, String message, String detail, [Map<String, String> headers]),
        void onConnectionError(error, stacktrace),
        void onClose(),
        bool debugFlag:false
      }) {
        Future<Object> waitingForConnection = _SockDartConnector.start(url, protocolsWhiteList, debugFlag,
          onClose: onClose);

        return waitingForConnection.then((connector){
            if (debugFlag) print("Got SockJS/SockDart connection");
            Future<StompClient> waitingForStompClientHolder = StompClient.connect(connector,
                host: host,
                login: login,
                passcode: passcode,
                heartbeat: heartbeat,
                onDisconnect: onDisconnect,
                onError: onError).catchError((e) {
                  print(e);
                  onConnectionError(e, e);
                });

            return(waitingForStompClientHolder);
        });
}

///The implementation
class _SockDartConnector extends StringStompConnector {
  final SockJS.Client _socket;
  Completer<_SockDartConnector> _starting = new Completer();

    static Future<_SockDartConnector> start(String url, List<String> protocolsWhiteList, bool debugFlag, {
        void onClose()} ) {

      SockJS.Client sockJs = new SockJS.Client(url, protocolsWhitelist:protocolsWhiteList, debug:debugFlag, devel:true);

      _SockDartConnector connector = new _SockDartConnector(sockJs, onClose:onClose);

      return connector._starting.future;
  }

  _SockDartConnector(this._socket, {onClose()}) {
    this.onClose = onClose;
    _init();
  }


  void _init() {
    _socket.onOpen.listen((_) {
      if (_socket.debug) print("here is onOpen");
      _starting.complete(this);
      _starting = null;
    });
    ///Note: when this method is called, onString/onError/onClose are not set yet
    _socket.onMessage.listen((event) {
      if (_socket.debug) print("here is onMessage");
      final data = event.data;
      if (data != null) {
        //TODO: handle Blob and TypedData more effectively
        final String sdata = data.toString();
        if (!sdata.isEmpty)
          onString(sdata);
      }
    }, onError: (error, stackTrace) {
      onError(error, stackTrace);
    }, onDone: () {
      //if Socket cannot connect there is no onClose
      if (onClose != null) onClose();
    });
    _socket.onClose.listen((event) {
      if (onClose != null) onClose();
    });

  }

  @override
  void writeString_(String string) {
    _socket.send(string);
  }

  @override
  Future close() {
    print("Not sure what to do with close here...close...");
    return new Future.value();
  }
}