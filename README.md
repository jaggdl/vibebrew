# Vibebrew

Vibebrew is a Rails 8.0 application that helps you catalog and manage your coffee bean collection. Upload a photo of a coffee package and Vibebrew uses AI vision to automatically extract the brand, origin, variety, processing method, producer, and tasting notes.

## Features

- **Coffee bean management** — create, edit, and organize coffee bean records
- **AI-powered extraction** — analyze an uploaded package image to auto-fill bean details
- **AI recipe generation** — generate step-by-step brewing recipes tailored to each coffee bean and brewing method

## Tech stack

- Rails with Ruby
- SQLite with Solid Cache, Solid Queue, and Solid Cable
- RubyLLM (OpenAI) for vision analysis
- Hotwire (Turbo + Stimulus), Importmap, and Propshaft
- Tailwind CSS 4
- Kamal / Docker for deployment

## Requirements

- Ruby (see `.ruby-version`)
- Bundler
- An OpenAI API key (for AI extraction)

## Development

### Setting up

First, get everything installed and configured:

```bash
bin/setup
bin/setup --reset # Reset the database
```

Set `OPENAI_API_KEY` (e.g. in `.env`) if you want AI extraction to work locally.

And then run the development server (Rails + Tailwind CSS watchers):

```bash
bin/dev
```

## Testing

Run the test suite (excluding system tests):

```bash
bin/rails test
```

## Code quality

```bash
bin/rubocop    # linter
bin/brakeman   # security scanner
```

## Deployment with Docker

The application is packaged as the `jaggdl/vibebrew` image (see the `Dockerfile`).
It runs as a single web service that handles both requests and background jobs
(via Solid Queue in-process).

### Building and pushing the image

```bash
bin/docker-push
```

### Example `docker-compose.yml`

Run this next to the application on your server:

```yaml
services:
  web:
    image: jaggdl/vibebrew:latest
    restart: unless-stopped
    ports:
      - "3066:80"
    environment:
      # Generate one with: `bin/rails secret`
      SECRET_KEY_BASE: change-me
      OPENAI_API_KEY: change-me
      BASE_URL: https://coffee.example.com
      DISABLE_SSL: "true"               # true when TLS is terminated by a reverse proxy
      SOLID_QUEUE_IN_PUMA: "true"       # run background jobs in the web process
    volumes:
      - vibebrew:/rails/storage         # persists SQLite DBs and uploaded images

volumes:
  vibebrew:
```

Then start it:

```bash
docker compose up -d
```

### Environment variables

| Variable | Required | Description |
| --- | --- | --- |
| `SECRET_KEY_BASE` | Yes | Rails secret key for session encryption. Generate with `bin/rails secret`. |
| `OPENAI_API_KEY` | Yes | Used by RubyLLM for AI extraction. |
| `BASE_URL` | Yes | Public URL of the app (SEO/social metadata). |
| `DISABLE_SSL` | No | Set to `true` when TLS is handled by a reverse proxy. |
| `SOLID_QUEUE_IN_PUMA` | No | Runs Solid Queue inside the Puma process. Defaults on in production. |

The `vibebrew` named volume keeps your SQLite databases and Active Storage files across container restarts. `SECRET_KEY_BASE` and `OPENAI_API_KEY` should be treated as secrets — avoid committing real values.
