FROM python:3.11-slim

WORKDIR /app

# System deps (small + safe defaults)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl \
  && rm -rf /var/lib/apt/lists/*

# Install Python deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# App code
COPY . .

# Create expected folders (will be bind-mounted in compose too)
RUN mkdir -p /app/config /app/output

# Default: run once
CMD ["python", "botpeas.py"]
