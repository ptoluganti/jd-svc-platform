from fastapi import APIRouter
from globals import globals

router = APIRouter(prefix=globals.api_prefix_v1, tags=["health"])

@router.get("/healthz")
def healthz():
	return {"status": "ok", "service": "account-svc-api"}

@router.get("/")
def read_root():
    return {"message": "Welcome to the Account Service API"}