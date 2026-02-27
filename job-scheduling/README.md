# UIM Job Scheduling Service

Job Scheduling style service built with D, vibe.d, and uim-framework.

## Feature coverage

- Define and run jobs once or on recurring schedules
- Flexible schedule formats: human-readable, repeatAt, repeatInterval, and cron-style patterns
- Synchronous and asynchronous execution modes for regular and long-running jobs
- Cloud Foundry task-style asynchronous runs for resource optimization
- Multitenant API design with tenant-scoped jobs, schedules, runs, alerts, and dashboard data
- OAuth2 bearer protection for incoming APIs and secure outbound calls to action endpoints
- Alert event emission hooks for Alert Notification service
- Cloud ALM automation monitoring hooks for execution telemetry forwarding
- Built-in web dashboard for managing jobs, schedules, and monitoring runs/logs

## Build and run

```bash
cd "Job Scheduling"
dub build
./build/uim-sap-job-scheduling-service
```

Environment variables:

- JOBS_HOST (default 0.0.0.0)
- JOBS_PORT (default 8101)
- JOBS_BASE_PATH (default /api/job-scheduling)
- JOBS_SERVICE_NAME (default uim-sap-job-scheduling)
- JOBS_SERVICE_VERSION (default 1.0.0)
- JOBS_SCHEDULER_TICK_MS (default 1000)
- JOBS_AUTH_TOKEN (optional bearer token for API protection)
- JOBS_OUTBOUND_OAUTH_TOKEN (optional bearer token for action endpoint calls)
- JOBS_ALERT_ENDPOINT / JOBS_ALERT_API_KEY (optional alert forwarding)
- JOBS_CLOUD_ALM_ENDPOINT / JOBS_CLOUD_ALM_API_KEY (optional ALM forwarding)

## Podman

```bash
cd "Job Scheduling"
podman build -t uim-sap-job-scheduling:local -f Dockerfile .
podman run --rm -p 8101:8101 --name uim-sap-job-scheduling uim-sap-job-scheduling:local
```

## Dashboard

- Web UI: `GET /api/job-scheduling/dashboard`
- Tenant summary API: `GET /api/job-scheduling/v1/tenants/{tenant_id}/dashboard`

## API

Base path: `/api/job-scheduling`

- GET `/health`
- GET `/ready`
- GET `/dashboard`
- GET `/v1/runtimes`
- POST `/v1/admin/alerts/test`
- POST `/v1/admin/cloud-alm/test`
- POST|GET `/v1/tenants/{tenant_id}/jobs`
- GET|PUT|DELETE `/v1/tenants/{tenant_id}/jobs/{job_id}`
- POST `/v1/tenants/{tenant_id}/jobs/{job_id}/run`
- POST|GET `/v1/tenants/{tenant_id}/schedules`
- GET|PUT|DELETE `/v1/tenants/{tenant_id}/schedules/{schedule_id}`
- GET `/v1/tenants/{tenant_id}/runs`
- GET `/v1/tenants/{tenant_id}/alerts`
- POST `/v1/tenants/{tenant_id}/tasks/cf/run`
- GET `/v1/tenants/{tenant_id}/tasks/cf/runs`
- GET `/v1/tenants/{tenant_id}/dashboard`

## Examples

Create a job:

```bash
curl -X POST "http://localhost:8101/api/job-scheduling/v1/tenants/acme/jobs" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "invoice-sync",
    "action_endpoint": "https://example.org/jobs/invoice-sync",
    "http_method": "POST",
    "runtime": "cloud-foundry",
    "execution_mode": "async",
    "payload": {"source": "erp"}
  }'
```

Create a recurring schedule using repeat interval:

```bash
curl -X POST "http://localhost:8101/api/job-scheduling/v1/tenants/acme/schedules" \
  -H "Content-Type: application/json" \
  -d '{
    "job_id": "job-1",
    "format": "repeat_interval",
    "repeat_interval_seconds": 300
  }'
```

Create schedule using cron expression:

```bash
curl -X POST "http://localhost:8101/api/job-scheduling/v1/tenants/acme/schedules" \
  -H "Content-Type: application/json" \
  -d '{
    "job_id": "job-1",
    "format": "cron",
    "cron": "*/5 * * * *"
  }'
```

Run a CF task asynchronously:

```bash
curl -X POST "http://localhost:8101/api/job-scheduling/v1/tenants/acme/tasks/cf/run" \
  -H "Content-Type: application/json" \
  -d '{
    "task_name": "data-archival",
    "duration_seconds": 45
  }'
```

Test Alert Notification connector:

```bash
curl -X POST "http://localhost:8101/api/job-scheduling/v1/admin/alerts/test" \
  -H "Content-Type: application/json" \
  -d '{
    "tenant_id": "acme",
    "job_id": "job-1",
    "run_id": "run-1"
  }'
```

Test Cloud ALM connector:

```bash
curl -X POST "http://localhost:8101/api/job-scheduling/v1/admin/cloud-alm/test" \
  -H "Content-Type: application/json" \
  -d '{
    "tenant_id": "acme",
    "job_id": "job-1",
    "run_id": "run-1",
    "status": "succeeded",
    "runtime": "cloud-foundry"
  }'
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
