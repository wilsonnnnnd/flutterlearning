import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Structured message for rendering
class QueueItem {
  final String? type;
  final String? message;
  final String? sender;
  final String? timestamp;
  final String raw;
  final bool structured;

  QueueItem({this.type, this.message, this.timestamp, this.sender, required this.raw, this.structured = false});
}

class WebSocketQueuePage extends StatefulWidget {
  const WebSocketQueuePage({super.key});

  @override
  State<WebSocketQueuePage> createState() => _WebSocketQueuePageState();
}

class _WebSocketQueuePageState extends State<WebSocketQueuePage> {
  final TextEditingController _urlController = TextEditingController(
      text: 'ws://10.0.2.2:8000/ws/chat/');
  final TextEditingController _sendController = TextEditingController();
  final TextEditingController _senderController = TextEditingController(text: 'Moblie');
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  // Queue stores either raw text items or structured QueueItem
  final List<dynamic> _queue = [];
  bool _connected = false;

  String _formatLocalTimestamp(String ts) {
    try {
      final dt = DateTime.parse(ts).toLocal();
      String p(int v) => v.toString().padLeft(2, '0');
      return '${dt.year}-${p(dt.month)}-${p(dt.day)} ${p(dt.hour)}:${p(dt.minute).padLeft(2, '0')}:${p(dt.second)}';
    } catch (_) {
      return ts;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  

  void _connect() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    _disconnect();
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _sub = _channel!.stream.listen((event) {
        setState(() {
          try {
            final decoded = jsonDecode(event.toString());
            if (decoded is Map<String, dynamic>) {
              final type = decoded['type']?.toString();
              final message = decoded['message']?.toString();
              final timestamp = decoded['timestamp']?.toString();
              if (type != null && message != null) {
                final sender = decoded['sender']?.toString();
                final formattedTimestamp = timestamp != null ? _formatLocalTimestamp(timestamp) : null;
                _queue.insert(0, QueueItem(type: type, message: message, timestamp: formattedTimestamp, sender: sender, raw: event.toString(), structured: true));
              } else {
                final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
                _queue.insert(0, QueueItem(raw: pretty));
              }
            } else {
              _queue.insert(0, QueueItem(raw: decoded.toString()));
            }
          } catch (e) {
            _queue.insert(0, QueueItem(raw: event.toString()));
          }
        });
      }, onError: (e) {
        setState(() {
          _queue.insert(0, QueueItem(raw: 'Error: $e'));
        });
      }, onDone: () {
        setState(() {
          _queue.insert(0, QueueItem(raw: 'Disconnected'));
        });
      });
      setState(() {
        _connected = true;
        _queue.insert(0, QueueItem(raw: 'Connected'));
      });
    } catch (e) {
      setState(() {
        _connected = false;
        _queue.insert(0, QueueItem(raw: 'Connect failed'));
      });
    }
  }

  void _disconnect() {
    _sub?.cancel();
    _sub = null;
    _channel?.sink.close();
    _channel = null;
    setState(() {
      _connected = false;
    });
  }

  void _send() {
    final text = _sendController.text;
    final sender = _senderController.text.trim();
    if (_channel == null) {
      setState(() {
        _queue.insert(0, QueueItem(raw: 'Not connected'));
      });
      return;
    }
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot send empty message')));
      return;
    }
    final message = jsonEncode({
      'type': 'chat',
      'message': text,
      'sender': sender,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
    _channel!.sink.add(message);
    _sendController.clear();
  }

  void _clear() {
    setState(() {
      _queue.clear();
    });
  }

  @override
  void dispose() {
    _disconnect();
    _urlController.dispose();
    _sendController.dispose();
    _senderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebSocket Queue')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Tooltip(
                  message: _connected ? 'Connected' : 'Disconnected',
                  child: Icon(
                    Icons.circle,
                    size: 14,
                    color: _connected ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Text(_connected ? 'Connected' : 'Disconnected', style: const TextStyle(fontSize: 14)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _connected ? _disconnect : _connect,
                  icon: Icon(_connected ? Icons.close : Icons.play_arrow),
                  label: Text(_connected ? 'Close' : 'Start'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(labelText: 'WebSocket URL'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: TextField(
                        controller: _senderController,
                        decoration: const InputDecoration(labelText: 'Sender', isDense: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _sendController,
                        decoration: const InputDecoration(labelText: 'Send Message', isDense: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _sendController,
                      builder: (context, value, child) {
                        final enabled = _connected && value.text.trim().isNotEmpty;
                        return ElevatedButton.icon(
                          onPressed: enabled ? _send : null,
                          icon: const Icon(Icons.send),
                          label: const Text('Send'),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    TextButton(onPressed: _clear, child: const Text('Clear')),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: _queue.isEmpty
                ? const Center(child: Text('Queue is empty'))
                : ListView.builder(
                    reverse: false,
                    padding: const EdgeInsets.all(12),
                    itemCount: _queue.length,
                    itemBuilder: (context, index) {
                      final item = _queue[index];
                      if (item is QueueItem && item.structured) {
                        final initials = (item.sender ?? 'U').isNotEmpty ? (item.sender ?? 'U')[0].toUpperCase() : 'U';
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(child: Text(initials)),
                            title: Text(item.message ?? ''),
                            subtitle: Text(item.type ?? ''),
                            trailing: item.timestamp != null ? Text(item.timestamp!, style: const TextStyle(fontSize: 12, color: Colors.grey)) : null,
                          ),
                        );
                      } else if (item is QueueItem) {
                        return Card(child: ListTile(title: Text(item.raw)));
                      } else {
                        return Card(child: ListTile(title: Text(item.toString())));
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
