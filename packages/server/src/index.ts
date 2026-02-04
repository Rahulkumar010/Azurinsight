import express from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import { gunzipSync } from 'zlib';
import { initDB } from './db';
import { ingestionRouter, setBroadcastCallback } from './routes/ingestion';
import { queryRouter } from './routes/query';
import { WebSocketServer } from 'ws';
import http from 'http';

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());

// Gzip decompression middleware - MUST come before body parser
// Application Insights SDK sends telemetry with content-encoding: gzip
app.use((req, res, next) => {
    const encoding = req.headers['content-encoding'];

    if (encoding === 'gzip') {
        const chunks: Buffer[] = [];

        req.on('data', (chunk: Buffer) => {
            chunks.push(chunk);
        });

        req.on('end', () => {
            try {
                const buffer = Buffer.concat(chunks);
                const decompressed = gunzipSync(buffer);
                const jsonString = decompressed.toString('utf8');

                // Application Insights sends newline-delimited JSON (NDJSON)
                // Parse each line as a separate JSON object
                const lines = jsonString.trim().split('\n').filter(line => line.trim().length > 0);

                if (lines.length === 1) {
                    // Single JSON object
                    req.body = JSON.parse(lines[0]);
                } else {
                    // Multiple JSON objects - parse each line
                    req.body = lines.map(line => JSON.parse(line));
                }

                // Remove content-encoding header so body-parser doesn't try to process it
                delete req.headers['content-encoding'];

                next();
            } catch (err) {
                console.error('Error decompressing gzip data:', err);
                res.status(400).json({
                    itemsReceived: 0,
                    itemsAccepted: 0,
                    errors: [{ message: 'Failed to decompress or parse request body' }]
                });
            }
        });
    } else {
        // Not gzipped, let body-parser handle it
        next();
    }
});

app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ extended: true }));

// Debug logging
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    console.log('Headers:', JSON.stringify(req.headers));
    next();
});

initDB();

app.use('/', ingestionRouter);
app.use('/api', queryRouter);

app.get('/', (req, res) => {
    res.send('AppInsights-ite Emulator Running');
});

const server = http.createServer(app);
const wss = new WebSocketServer({ server });

wss.on('connection', (ws: any) => {
    console.log('Client connected to Live Stream');
    ws.on('close', () => console.log('Client disconnected'));
});

// Broadcast telemetry to all connected clients
setBroadcastCallback((item: any) => {
    const message = JSON.stringify(item);
    wss.clients.forEach((client: any) => {
        if (client.readyState === 1) { // OPEN
            client.send(message);
        }
    });
});

server.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
