# Build stage
FROM node:22-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./
RUN \
    if [ -f package-lock.json ]; then npm ci; \
    elif [ -f pnpm-lock.yaml ]; then npm install -g pnpm && pnpm install; \
    elif [ -f yarn.lock ]; then yarn install; \
    else npm install; fi

COPY . .

# Accept VITE_API_PROXY_TARGET as build arg for Vite
ARG VITE_API_PROXY_TARGET
ARG VITE_API_BASE_URL
ENV VITE_API_PROXY_TARGET=${VITE_API_PROXY_TARGET}
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}

RUN npm run build

# Production stage
FROM node:22-alpine AS runner

WORKDIR /app

RUN npm install -g serve

COPY --from=builder /app/dist ./dist

EXPOSE 3000

CMD ["serve", "-s", "dist", "-l", "3000"]