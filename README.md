# jd-svc-platform
JD Services Platform
Monorepo containing example microservices (Go, Rust, Python), a React UI, Terraform infra, and CI via GitHub Actions.

## Structure

- `.github/workflows/ci-cd.yml` — CI jobs for build/validate
- `api/`
	- `go-api` — Order service (Go net/http)
	- `rust-api` — Makeline service (Actix-Web)
	- `python-api` — Loyalty service (FastAPI)
- `app/react-ui` — Vite React app
- `infra/` — Terraform stubs (Azure resource group)

## Quick start

### Go API

Run locally (in `api/go-api`):

```powershell
$env:PORT=8080
go run .
```

Docker:

```powershell
docker build -t go-api api/go-api
docker run -p 8080:8080 go-api
```

### Rust API

Run locally (in `api/rust-api`):

```powershell
cargo run
```

Docker (similar to Go API):

```powershell
docker build -t rust-api api/rust-api
docker run -p 8081:8081 rust-api
```

### Python API

Run locally (in `api/python-api`):

```powershell
pip install -r requirements.txt
python .\main.py
```

Docker:

```powershell
docker build -t python-api api/python-api
docker run -p 8082:8082 python-api
```

### React UI

Run locally (in `app/react-ui`):

```powershell
npm install
npm run dev
```

Docker:

```powershell
docker build -t react-ui app/react-ui
docker run -p 8080:80 react-ui
```

### Terraform

Validate (in `infra`):

```powershell
terraform init -backend=false
terraform validate
```

## Endpoints

- Go:     `GET /health`, `GET /orders`
- Rust:   `GET /health`, `GET /makeline`
- Python: `GET /health`, `GET /loyalty`

