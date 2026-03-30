# flutterlearning

This project is a small Flutter app for learning and testing. It works on
mobile, web, and desktop.

## What is in this project

- A simple home page created from the Flutter template.
- A Calculator page: open it from the home page. The calculator can do add,
	subtract, multiply, divide, decimal numbers, and parentheses.
- A WebSocket Queue page: open it from the home page. This page can connect
	to a WebSocket server, send JSON messages, and show received messages.

The WebSocket message format used by the app:

```json
{
	"type": "chat",
	"message": "Hello",
	"sender": "wilson",
	"timestamp": "2026-03-31T12:34:56.000Z"
}
```

When the app receives a JSON message, it shows the sender, message, type,
and a local time string on a card.

## Quick start

1. Install Flutter SDK and tools. Check with:

```bash
flutter doctor -v
```

2. Get project dependencies:

```bash
flutter pub get
```

3. Run the app on a device or browser:

```bash
flutter devices
flutter run -d <device-id>
# or run on Chrome
flutter run -d chrome
```

## Run tests

```bash
flutter test
```

## WebSocket testing notes

- Default test URL in the page: `ws://10.0.2.2:8000/ws/chat/` (Android emulator
	uses `10.0.2.2` for host machine).
- You can change the URL to a public echo server: `wss://echo.websocket.events`.
- The app sends JSON. Make sure your server sends and receives text frames
	with JSON strings.

## Important files

- App entry: `lib/main.dart`
- Calculator page: `lib/pages/calculator_page.dart`
- WebSocket page: `lib/pages/websocket_queue_page.dart`

If you want, I can also add a short demo server (Node or Python) to test the
WebSocket page.

