# syntax=docker/dockerfile:1

FROM golang:1.22-alpine AS build
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /bin/order-svc-api ./

FROM gcr.io/distroless/base-debian12
ENV PORT=8080
EXPOSE 8080
COPY --from=build /bin/order-svc-api /order-svc-api
USER 65532:65532
ENTRYPOINT ["/order-svc-api"]
