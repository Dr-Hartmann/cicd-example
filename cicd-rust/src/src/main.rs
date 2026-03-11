use poem::{Route, Server, listener::TcpListener};
use poem_openapi::{OpenApi, OpenApiService, payload::PlainText};
use std::env;

struct Api;
 
#[OpenApi]
impl Api {
    #[oai(path = "/", method = "get")]
    async fn index(&self) -> PlainText<&'static str> {
        PlainText("Hello World")
    }
}

#[tokio::main]
async fn main() -> Result<(), std::io::Error> {
    let host = env::var("HOST").unwrap_or_else(|f| {
        eprintln!("{}: HOST должна быть установлена!", f);
        "localhost".to_string()
    });

    let port = env::var("PORT").unwrap_or_else(|f| {
        eprintln!("{}: PORT должна быть установлена!", f);
        "3000".to_string()
    });

    let url = format!("http://{}:{}", host, port);

    let api_service = OpenApiService::new(Api, "Простой пример API", "1.0").server(&url);
    let ui = api_service.swagger_ui();
    let app = Route::new().nest("/", api_service).nest("/docs", ui);
    let listener = TcpListener::bind(format!("0.0.0.0:{}", port));

    println!("Сервер запущен на {url}");

    dfv

    Server::new(listener).run(app).await
}
