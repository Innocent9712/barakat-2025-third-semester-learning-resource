# Demo App - FastAPI + React

A full-stack web application built with FastAPI backend and React frontend, featuring Redis caching and modern UI.

## Features

### Backend (FastAPI)
- **User Management**: CRUD operations with password hashing
- **Post Management**: Create, read, update, delete posts
- **Redis Caching**: User and post caching for improved performance
- **Authentication**: Basic login system
- **Analytics**: System statistics endpoint
- **Health Checks**: Monitor system status
- **CORS Support**: Configured for frontend integration

### Frontend (React + TypeScript)
- **Modern Stack**: Vite + TypeScript + TanStack Router
- **State Management**: TanStack Query for server state
- **Responsive Design**: Tailwind CSS with custom components
- **Route Management**: File-based routing with TanStack Router
- **Form Handling**: React Hook Form with validation
- **Real-time Updates**: Optimistic updates and cache invalidation

## Prerequisites

- Python 3.8+
- Node.js 16+
- Redis (optional, but recommended)

## Backend Setup

1. **Create virtual environment:**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. **Install dependencies:**
```bash
pip install -r requirements.txt
```

3. **Configure environment:**
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. **Start Redis (optional):**
```bash
redis-server
```

5. **Run the FastAPI server:**
```bash
python main.py
# Or with uvicorn directly:
# uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`
- API Documentation: `http://localhost:8000/docs`
- Health Check: `http://localhost:8000/health`

## Frontend Setup

1. **Install dependencies:**
```bash
npm install
```

2. **Start the development server:**
```bash
npm run dev
```

The frontend will be available at `http://localhost:5173`

## API Endpoints

### Users
- `GET /users` - List users with optional search and pagination
- `GET /users/{user_id}` - Get user by ID
- `POST /users` - Create new user
- `PUT /users/{user_id}` - Update user
- `DELETE /users/{user_id}` - Delete user
- `POST /auth/login` - User login

### Posts
- `GET /posts` - List posts with optional filtering by author
- `GET /posts/{post_id}` - Get post by ID
- `POST /posts` - Create new post
- `PUT /posts/{post_id}` - Update post
- `DELETE /posts/{post_id}` - Delete post

### System
- `GET /health` - Health check with Redis status
- `GET /analytics/stats` - System statistics

## Redis Caching

The application implements Redis caching for:
- **User Data**: 15-minute TTL
- **Posts by Author**: 10-minute TTL
- **Analytics Stats**: 5-minute TTL

Cache is automatically invalidated on data updates.

## Frontend Routes

- `/` - Dashboard with analytics and recent activity
- `/users` - User management interface
- `/users/{userId}` - User detail view with posts
- `/posts` - Post management interface
- `/posts/{postId}` - Post detail view with author info
- `/health` - System health monitoring

## Development

### Backend Development
- FastAPI auto-reloads on file changes
- SQLAlchemy ORM with automatic table creation
- Pydantic models for request/response validation
- Structured error handling with HTTP exceptions

### Frontend Development
- Hot module replacement with Vite
- TypeScript for type safety
- TanStack Router for type-safe routing
- TanStack Query for server state management
- Tailwind CSS for styling

## Production Deployment

### Backend
1. Set production environment variables
2. Use a production WSGI server (gunicorn recommended)
3. Set up proper database (PostgreSQL recommended)
4. Configure Redis for production use

### Frontend
1. Build the production bundle: `npm run build`
2. Serve the `dist` folder with a web server (nginx recommended)
3. Configure proxy to backend API

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with appropriate tests
4. Submit a pull request

## License

MIT License