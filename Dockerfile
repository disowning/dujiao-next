# syntax=docker/dockerfile:1

FROM node:24-alpine AS admin-builder

WORKDIR /src/admin
COPY admin/package*.json ./
RUN npm ci
COPY admin/ ./
RUN npm run build:fullstack

FROM node:24-alpine AS user-builder

WORKDIR /src/user
COPY user/package*.json ./
RUN npm ci
COPY user/ ./
RUN npm run build

FROM golang:1.26.3-alpine AS api-builder

ARG APP_VERSION=self-hosted

WORKDIR /src
ENV CGO_ENABLED=0

COPY dujiao-next/go.mod dujiao-next/go.sum ./
RUN go mod download

COPY dujiao-next/ ./
COPY --from=admin-builder /src/admin/dist ./internal/web/dist/admin
COPY --from=user-builder /src/user/dist ./internal/web/dist/user

RUN go build \
    -trimpath \
    -tags "release fullstack" \
    -ldflags="-s -w -X github.com/dujiao-next/internal/version.Version=${APP_VERSION}" \
    -o /out/dujiao-api \
    ./cmd/server

FROM alpine:3.22

WORKDIR /app

RUN apk --no-cache add ca-certificates tzdata \
    && mkdir -p /app/db /app/uploads /app/logs

COPY --from=api-builder /out/dujiao-api /app/dujiao-api

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD wget -qO- http://127.0.0.1:8080/health || exit 1

CMD ["./dujiao-api"]
