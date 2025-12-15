# BotPEASS (Docker)

Thanks to https://github.com/peass-ng/BotPEASS

If you need support, check out https://arphost.com

BotPEASS is a CVE alerting tool that polls the **CIRCL CVE API (cve.circl.lu)** and sends notifications when new or modified CVEs are published.

This Dockerized version supports:

- Keyword-based filtering
- Full CVE backfill
- Slack, Telegram, Discord, Pushover, ntfy **and Email** notifications
- Incremental state tracking so you only see new changes
- Run-once execution (ideal for cron)

---

## How It Works

- CVEs are fetched from:
  **https://cve.circl.lu/api/query**
- Keywords are loaded from:
  `config/botpeas.yaml`
- Last processed timestamps are stored in:
  `output/botpeas.json`

Each run:

1. Loads keywords
2. Loads last-seen timestamps
3. Fetches new and modified CVEs
4. Filters by keywords (unless `ALL_VALID` is enabled)
5. Sends notifications
6. Updates timestamps and exits

The container is **run-once by design**, making it ideal for cron.

---

## Requirements

- Docker
- Docker Compose (v2+)

---

## Installation

### Clone the Repository

```bash
git clone https://github.com/arphost-com/BotPEASS.git
cd BotPEASS
````

### Create Required Directories

```bash
mkdir -p config output
```

---

## Configuration

### Keyword Configuration

Edit:

```text
config/botpeas.yaml
```

Example:

```yaml
ALL_VALID: false

DESCRIPTION_KEYWORDS_I:
  - privilege escalation
  - privesc
  - docker
  - proxmox
  - freepbx

DESCRIPTION_KEYWORDS:
  - ThisIsACaseSensitiveExample

PRODUCT_KEYWORDS_I:
  - docker
  - proxmox
  - nginx
  - freepbx

PRODUCT_KEYWORDS:
  - ThisIsACaseSensitiveExample
```

### ALL_VALID Explained

| Value | Behavior                                   |
| ----- | ------------------------------------------ |
| true  | Alert on every CVE returned (very noisy)   |
| false | Alert only if keywords match (recommended) |

**Recommended:**
Use `ALL_VALID: true` temporarily for testing or backfill, then switch to `false`.

---

## Notification Providers

Configure notifications via environment variables.

Create a `.env` file (recommended):

```bash
touch .env
```

### Slack

```env
SLACK_WEBHOOK=https://hooks.slack.com/services/XXX/YYY/ZZZ
```

### Telegram

```env
TELEGRAM_BOT_TOKEN=123456:ABCDEF
TELEGRAM_CHAT_ID=-1001234567890
```

### Discord

```env
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...
```

### Pushover

```env
PUSHOVER_DEVICE_NAME=your_device
PUSHOVER_USER_KEY=your_user_key
PUSHOVER_TOKEN=your_app_token
```

### ntfy

```env
NTFY_URL=https://ntfy.sh
NTFY_TOPIC=botpeass
# Optional authorization
NTFY_AUTH=Bearer yourtoken
```

---

## Email Notifications (Digest)

BotPEASS can send **one email per run** containing **all new and modified CVEs**.

### Enable Email

```env
EMAIL_PROVIDER=smtp
# or
EMAIL_PROVIDER=sendgrid

EMAIL_FROM=alerts@yourdomain.com
EMAIL_TO=you@yourdomain.com,another@yourdomain.com
```

### Optional

```env
EMAIL_SUBJECT=CVSAlerts Digest
EMAIL_SEND_ON_EMPTY=false
```

* By default, email is sent **only if CVEs are found**
* Set `EMAIL_SEND_ON_EMPTY=true` to receive a “no CVEs” status email

### SMTP Configuration

Required when `EMAIL_PROVIDER=smtp`:

```env
SMTP_HOST=smtp.yourmailserver.com
SMTP_PORT=587
SMTP_TLS=true
SMTP_USER=optional_username
SMTP_PASS=optional_password
```

### SendGrid Configuration

Required when `EMAIL_PROVIDER=sendgrid`:

```env
SENDGRID_API_KEY=your_sendgrid_api_key
```

> Email notifications are **digest-only** (one email per run).
> Other providers (Slack, Telegram, etc.) still send **per CVE**.

---

## Running the Bot

### One-Time Run

```bash
docker compose up --build
```

The container will:

* Run once
* Send alerts
* Update `output/botpeas.json`
* Exit cleanly

---

## Backfill (Example: Last 7 Days)

To fetch historical CVEs for the last 7 days:

```bash
docker compose run --rm -e BACKFILL_DAYS=7 botpeass
```

This ignores the saved timestamps **for that run only**.

⚠️ Do **not** keep `BACKFILL_DAYS` set permanently or it will re-alert every run.

---

## Scheduling with Cron (Recommended)

Because BotPEASS is run-once, use cron on the host.

### Every 8 Hours

```cron
0 */8 * * * cd /path/to/BotPEASS && /usr/bin/docker compose run --rm botpeass >> /var/log/botpeass.log 2>&1
```

### Daily at 8 AM

```cron
0 8 * * * cd /path/to/BotPEASS && /usr/bin/docker compose run --rm botpeass
```

---

## Reset State (Start Fresh)

If you want to forget all previously processed CVEs:

```bash
rm -f output/botpeas.json
```

Next run will start fresh.

---

## Troubleshooting

### No Alerts

* If `ALL_VALID: false`, ensure keywords actually match CVE summaries/products
* Test the pipeline with:

```bash
docker compose run --rm -e BACKFILL_DAYS=3 botpeass
```

* Temporarily set:

```yaml
ALL_VALID: true
```

### Too Many Alerts

* Set `ALL_VALID: false`
* Reduce keyword scope

### Python Deprecation Warnings

Warnings like `cgi` or `audioop` deprecation are harmless and do not affect execution.

---

## Security Notes

* Do not commit `.env` files with real tokens
* Treat all webhook URLs, API keys, and bot tokens as secrets

---

## License

See the LICENSE file.

```
