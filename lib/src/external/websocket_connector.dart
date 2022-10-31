import 'package:hasura_connect/hasura_connect.dart';
import 'package:hasura_connect/src/domain/errors/errors.dart';
import 'package:hasura_connect/src/domain/entities/connector.dart';
import 'package:hasura_connect/src/domain/models/query.dart';
import 'package:hasura_connect/src/infra/datasources/connector_datasource.dart';
import 'package:dart_websocket/websocket.dart';

class WebsocketConnector implements ConnectorDatasource {
  final WebSocketWrapper? wrapper;

  WebsocketConnector(this.wrapper);

  @override
  Future<Connector> websocketConnector(String url) async {
    try {
      final _wrapper = wrapper ?? _WebSocketWrapper();
      final String url_wss = url.replaceFirst('https', 'wss').replaceFirst('http', 'ws');
      print(
          "!!!!!----------------------------------------------------url_wss:$url_wss----------------------------------");
      final _channelPromisse = await _wrapper.connect(url_wss);
      return Connector(
        _channelPromisse.stream,
        add: _channelPromisse.addUtf8Text,
        close: _channelPromisse.close,
        closeCodeFunction: () => _channelPromisse.closeCode ?? -1,
        done: _channelPromisse.done,
      );
    } catch (e) {
      throw ConnectionError(
        'Websocket Error',
        request: Request(
          url: url,
          query: Query(document: ''),
        ),
      );
    }
  }
}

abstract class WebSocketWrapper {
  Future<WebSocket> connect(String url);
}

class _WebSocketWrapper implements WebSocketWrapper {
  @override
  Future<WebSocket> connect(String url) {
    return WebSocket.connect(url, protocols: ['graphql-ws']);
  }
}
