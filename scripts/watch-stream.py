#!/usr/bin/env python3
"""
Simple WebSocket client to stream telemetry from Azurinsight
Usage: python watch-stream.py

Install dependencies:
  pip install websocket-client
"""

import sys
import json
import signal
from datetime import datetime

try:
    import websocket
except ImportError:
    print("Error: websocket-client not installed")
    print("Install it with: pip install websocket-client")
    sys.exit(1)

# ANSI color codes
class Colors:
    RESET = '\033[0m'
    BRIGHT = '\033[1m'
    DIM = '\033[2m'
    CYAN = '\033[36m'
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    RED = '\033[31m'
    MAGENTA = '\033[35m'
    BLUE = '\033[34m'

TYPE_COLORS = {
    'Message': Colors.CYAN,
    'Event': Colors.GREEN,
    'Exception': Colors.RED,
    'Request': Colors.YELLOW,
    'Dependency': Colors.MAGENTA,
    'Metric': Colors.BLUE,
}

item_count = 0

def on_message(ws, message):
    global item_count
    try:
        item = json.loads(message)
        item_count += 1

        item_type = item.get('data', {}).get('baseType', 'unknown').replace('Data', '')
        color = TYPE_COLORS.get(item_type, Colors.RESET)
        timestamp = datetime.fromisoformat(item['time'].replace('Z', '+00:00')).strftime('%H:%M:%S')
        msg = item.get('data', {}).get('baseData', {}).get('message') or \
              item.get('data', {}).get('baseData', {}).get('name') or ''
        name = item.get('name', 'Unnamed')

        print(f"{Colors.DIM}[{timestamp}]{Colors.RESET} {color}{item_type.upper()}{Colors.RESET}")
        print(f"  {Colors.BRIGHT}{name}{Colors.RESET}")
        if msg:
            print(f"  {msg}")

        # Show tags
        tags = item.get('tags', {})
        if tags:
            tag_str = ', '.join([f"{Colors.DIM}{k}{Colors.RESET}={v}" for k, v in tags.items()])
            print(f"  {tag_str}")

        print()

    except Exception as e:
        print(f"{Colors.RED}Error parsing telemetry:{Colors.RESET} {e}")

def on_error(ws, error):
    print(f"{Colors.RED}WebSocket error:{Colors.RESET} {error}")
    print(f"{Colors.YELLOW}Make sure Azurinsight is running: docker-compose ps{Colors.RESET}")

def on_close(ws, close_status_code, close_msg):
    print()
    print(f"{Colors.YELLOW}✗ Disconnected from Azurinsight{Colors.RESET}")
    print(f"{Colors.DIM}Total events received: {item_count}{Colors.RESET}")

def on_open(ws):
    print(f"{Colors.BRIGHT}{Colors.GREEN}✓ Connected to Azurinsight WebSocket{Colors.RESET}")
    print(f"{Colors.DIM}Listening for telemetry events... (Ctrl+C to exit){Colors.RESET}")
    print()

def signal_handler(sig, frame):
    print()
    print(f"{Colors.DIM}Closing connection...{Colors.RESET}")
    sys.exit(0)

if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal_handler)

    ws = websocket.WebSocketApp(
        "ws://localhost:5000",
        on_open=on_open,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close
    )

    ws.run_forever()
