import importlib
from pathlib import Path
from fastapi import FastAPI
# from routers.healthz import router as healthz_router
# from routes.root import router as root_router
import os
import uvicorn
from globals import globals

from utils.utils import discover_router_modules

app = FastAPI(title="account-svc-api", version=globals.app_version)


# 1. Define the path to your routers directory.
#    This assumes your main.py is in the project root, alongside the 'api' folder.
ROUTERS_DIR = Path(__file__).parent / "routers"

# 2. Define the Python import path for the routers package.
ROUTERS_PACKAGE = "routers"

# 3. Call our discovery function to get the list of modules.
modules_to_load = discover_router_modules(ROUTERS_DIR)
print(f"Discovered router modules: {modules_to_load}")

# Routers
for module_name in modules_to_load:
    module = importlib.import_module(f"{ROUTERS_PACKAGE}.{module_name}")
    app.include_router(module.router)


if __name__ == "__main__":
    port = int(os.getenv("PORT", "8082"))
    uvicorn.run(app, host="0.0.0.0", port=port)
