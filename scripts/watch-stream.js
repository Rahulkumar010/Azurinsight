#!/usr/bin/env node
/**
 * Simple WebSocket client to stream telemetry from Azurinsight
 * Usage: node watch-stream.js
 */

const WebSocket = require('ws');

const ws = new WebSocket('ws://localhost:5000');

const colors = {
    reset: '\x1b[0m',
    bright: '\x1b[1m',
    dim: '\x1b[2m',
    cyan: '\x1b[36m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    red: '\x1b[31m',
    magenta: '\x1b[35m',
    blue: '\x1b[34m',
};

const typeColors = {
    Message: colors.cyan,
    Event: colors.green,
    Exception: colors.red,
    Request: colors.yellow,
    Dependency: colors.magenta,
    Metric: colors.blue,
};

let itemCount = 0;

ws.on('open', () => {
    console.log(`${colors.bright}${colors.green}✓ Connected to Azurinsight WebSocket${colors.reset}`);
    console.log(`${colors.dim}Listening for telemetry events... (Ctrl+C to exit)${colors.reset}`);
    console.log('');
});

ws.on('message', (data) => {
    try {
        const item = JSON.parse(data);
        itemCount++;

        const type = item.data?.baseType?.replace('Data', '') || 'unknown';
        const color = typeColors[type] || colors.reset;
        const timestamp = new Date(item.time).toLocaleTimeString();
        const message = item.data?.baseData?.message || item.data?.baseData?.name || '';
        const name = item.name || 'Unnamed';

        console.log(`${colors.dim}[${timestamp}]${colors.reset} ${color}${type.toUpperCase()}${colors.reset}`);
        console.log(`  ${colors.bright}${name}${colors.reset}`);
        if (message) {
            console.log(`  ${message}`);
        }

        // Show tags
        if (item.tags && Object.keys(item.tags).length > 0) {
            const tags = Object.entries(item.tags)
                .map(([k, v]) => `${colors.dim}${k}${colors.reset}=${v}`)
                .join(', ');
            console.log(`  ${tags}`);
        }

        console.log('');

    } catch (e) {
        console.error(`${colors.red}Error parsing telemetry:${colors.reset}`, e.message);
    }
});

ws.on('error', (error) => {
    console.error(`${colors.red}WebSocket error:${colors.reset}`, error.message);
    console.log(`${colors.yellow}Make sure Azurinsight is running: docker-compose ps${colors.reset}`);
});

ws.on('close', () => {
    console.log('');
    console.log(`${colors.yellow}✗ Disconnected from Azurinsight${colors.reset}`);
    console.log(`${colors.dim}Total events received: ${itemCount}${colors.reset}`);
    process.exit(0);
});

// Handle Ctrl+C gracefully
process.on('SIGINT', () => {
    console.log('');
    console.log(`${colors.dim}Closing connection...${colors.reset}`);
    ws.close();
});
