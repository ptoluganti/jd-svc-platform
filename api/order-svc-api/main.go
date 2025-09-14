package main

import (
    "encoding/json"
    "log"
    "net/http"
    "os"
)

type response map[string]any

func writeJSON(w http.ResponseWriter, status int, v any) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    _ = json.NewEncoder(w).Encode(v)
}

func main() {
    mux := http.NewServeMux()

    mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
        writeJSON(w, http.StatusOK, response{"status": "ok", "service": "go-api"})
    })

    mux.HandleFunc("/orders", func(w http.ResponseWriter, r *http.Request) {
        switch r.Method {
        case http.MethodGet:
            writeJSON(w, http.StatusOK, response{"orders": []string{"123", "456"}})
        default:
            writeJSON(w, http.StatusMethodNotAllowed, response{"error": "method not allowed"})
        }
    })

    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }

    log.Printf("go-api listening on :%s", port)
    log.Fatal(http.ListenAndServe(":"+port, mux))
}
