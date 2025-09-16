# jd-svc-platform
JD Services Platform
Monorepo containing example microservices (Go, Rust, Python), a React UI, Terraform infra, and CI via GitHub Actions.

## Structure

- `.github/workflows/ci-cd.yml` — CI jobs for build/validate
- `api/`
	- `order-svc-api` — Order service (Go net/http)
	- `receipt-svc-api` — Makeline service (Actix-Web)
	- `account-svc-api` — Loyalty service (FastAPI)
- `app/self-svc-ui` — Vite React app
- `infra/` — Terraform stubs (Azure resource group)

## Quick start

### Go API

Run locally (in `api/order-svc-api`):

```powershell
$env:PORT=8080
go run .
```

Docker:

```powershell
docker build -t order-svc-api api/order-svc-api
docker run -p 8080:8080 order-svc-api
```

### Rust API

Run locally (in `api/receipt-svc-api`):

```powershell
cargo run
```

Docker (similar to Go API):

```powershell
docker build -t receipt-svc-api api/receipt-svc-api
docker run -p 8081:8081 receipt-svc-api
```

### Python API

Run locally (in `api/account-svc-api`):

```powershell
pip install -r requirements.txt
python .\main.py
```

Docker:

```powershell
docker build -t account-svc-api api/account-svc-api
docker run -p 8082:8082 account-svc-api
```

### React UI

Run locally (in `app/self-svc-ui`):

```powershell
npm install
npm run dev
```

Docker:

```powershell
docker build -t self-svc-ui app/self-svc-ui
docker run -p 8080:80 self-svc-ui
```

### Run everything with Docker Compose

From the repo root:

```powershell
docker compose up --build
```

Then open:

- React UI: <http://localhost:8083>
- Go API: <http://localhost:8080/health>
- Rust API: <http://localhost:8081/health>
- Python API: <http://localhost:8082/health>

Stop and remove:

```powershell
docker compose down
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

