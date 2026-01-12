const path = require('path');
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

// Root endpoint
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({
        status: 'UP',
        timestamp: new Date().toISOString()
    });
});

// Echo endpoint (POST example)
app.post('/api/echo', (req, res) => {
    res.json({
        received: req.body,
        timestamp: new Date().toISOString()
    });
});

// Sample Resource endpoint
app.get('/api/info', (req, res) => {
    res.json({
        app: 'bubble-works',
        version: '1.0.0',
        description: 'A simple Node.js Express application.'
    });
});

app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});
