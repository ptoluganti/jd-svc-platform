# syntax=docker/dockerfile:1

FROM rust:1.80 as build
WORKDIR /app
COPY Cargo.toml .
RUN mkdir src && echo "fn main(){}" > src/main.rs && cargo build --release || true
COPY src ./src
RUN cargo build --release

FROM gcr.io/distroless/cc-debian12
ENV PORT=8081
EXPOSE 8081
COPY --from=build /app/target/release/receipt-svc-api /receipt-svc-api
USER 65532:65532
ENTRYPOINT ["/receipt-svc-api"]
