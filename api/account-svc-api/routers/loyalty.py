
from fastapi import APIRouter, Depends
from globals import globals
from fastapi.security import HTTPBasic

router = APIRouter(prefix=globals.api_prefix_v1, tags=["loyalty"], dependencies=[Depends(HTTPBasic())])

@router.get("/loyalty")
def loyalty():
    return {"points": 120, "tier": "gold"}