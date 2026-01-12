# Bubble Works API

A simple Node.js Express application with basic endpoints for demonstration and bootstrapping.

## Features

- **Root Endpoint**: Welcome message.
- **Health Check**: Service status and uptime tracking.
- **Echo Endpoint**: POST JSON bodies back to the client.
- **Info Endpoint**: Basic application metadata.

## Prerequisites

- [Node.js](https://nodejs.org/) (v14 or later recommended)
- [npm](https://www.npmjs.com/)

## Getting Started

1. **Install Dependencies**:
   ```bash
   npm install
   ```

2. Environment Variables
   ```bash
   PORT=3000
   ```

3. **Start the Server**:
   ```bash
   npm start
   ```
   The server will start on `http://localhost:{{PORT}}`.


## API Endpoints

| Method | Endpoint | Description |
| --- | --- | --- |
| `GET` | `/` | Welcome message |
| `GET` | `/api/health` | Service health status |
| `GET` | `/api/info` | Application information |
| `POST` | `/api/echo` | Echoes back the request body |

### Example Usage

**Echo Endpoint**:
```bash
curl -X POST http://localhost:3000/api/echo \
     -H "Content-Type: application/json" \
     -d '{"message": "Hello World"}'
```

## License

ISC
