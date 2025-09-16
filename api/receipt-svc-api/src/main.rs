use actix_web::{get, web, App, HttpResponse, HttpServer, Responder};
use serde::Serialize;
use std::env;

#[derive(Serialize)]
struct Health { status: &'static str, service: &'static str }

#[derive(Serialize)]
struct Makeline { items: Vec<&'static str> }

#[get("/health")]
async fn health() -> impl Responder {
    HttpResponse::Ok().json(Health { status: "ok", service: "receipt-svc-api" })
}

#[get("/healthz")]
async fn healthz() -> impl Responder {
    HttpResponse::Ok().json(Health { status: "ok", service: "receipt-svc-api" })
}

async fn makeline() -> impl Responder {
    let data = Makeline { items: vec!["prep", "cook", "pack"] };
    HttpResponse::Ok().json(data)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let port = env::var("PORT").unwrap_or_else(|_| "8081".to_string());
    HttpServer::new(|| {
        App::new()
            .service(health)
            .service(healthz)
            .route("/makeline", web::get().to(makeline))
    })
    .bind(format!("0.0.0.0:{}", port))?
    .run()
    .await
}
