#
# A helper function to discover router modules
#

from pathlib import Path
import importlib
from fastapi import FastAPI

def discover_router_modules(routers_path: Path) -> list[str]:
    """
    Dynamically discovers Python modules in a directory that contain an APIRouter.

    Args:
        routers_path: A pathlib.Path object pointing to the routers directory.

    Returns:
        A list of module names (e.g., ['users', 'items']) that are ready to be imported.
    """
    router_module_names = []
    # Use .glob() to find all Python files. This is cleaner than os.listdir().
    for py_file in routers_path.glob("*.py"):
        # Skip __init__.py files
        if py_file.name == "__init__.py":
            continue

        # Read the file line-by-line to be memory-efficient
        with open(py_file, "r", encoding="utf-8") as f:
            for line in f:
                # If we find a line creating an APIRouter, we know it's a router file.
                # This is more robust than a complex regex.
                if "APIRouter" in line and "=" in line:
                    # py_file.stem gets the filename without the ".py" extension
                    module_name = py_file.stem
                    router_module_names.append(module_name)
                    # We found what we need, so we can stop reading this file and move to the next.
                    break 
                    
    return router_module_names