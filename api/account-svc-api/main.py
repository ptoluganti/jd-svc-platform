from fastapi import FastAPI
from fastapi.responses import JSONResponse
import os

app = FastAPI(title="account-svc-api")


@app.get("/health")
def health():
    return {"status": "ok", "service": "account-svc-api"}


@app.get("/loyalty")
def loyalty():
    return {"points": 120, "tier": "gold"}


if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", "8082"))
    uvicorn.run(app, host="0.0.0.0", port=port)
