# BotPEASS (Docker) 

Thanks to https://github.com/peass-ng/BotPEASS

If you need support check out https://arphost.com

BotPEASS is a CVE alerting tool that polls the **CIRCL CVE v5 (Vulnerability Lookup) API** and sends notifications when new or modified CVEs are published.

This Dockerized version supports:
- Keyword-based filtering
- Full CVE backfill
- Slack, Telegram, Discord, Pushover, and ntfy notifications
- Incremental state tracking so you only see new changes

---

## How It Works

- CVEs are fetched from:
  **https://cve.circl.lu/api/vulnerability/**
- Keywords are loaded from:
  `config/botpeas.yaml`
- Last processed timestamps are stored in:
  `output/botpeas.json`
- Each run:
  1. Loads keywords
  2. Loads last-seen timestamps
  3. Fetches new + modified CVEs
  4. Filters by keywords (unless ALL_VALID is enabled)
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

Create Required Directories

mkdir -p config output


⸻

Configuration

Keyword Configuration

Edit:

config/botpeas.yaml

Example:

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

ALL_VALID Explained

Value	Behavior
true	Alert on every CVE returned (very noisy)
false	Alert only if keywords match (recommended)

Recommended:
Use ALL_VALID: true temporarily for testing or backfill, then switch to false.

⸻

Notification Providers

Configure notifications via environment variables.

Create a .env file (recommended):

touch .env

Slack

SLACK_WEBHOOK=https://hooks.slack.com/services/XXX/YYY/ZZZ

Telegram

TELEGRAM_BOT_TOKEN=123456:ABCDEF
TELEGRAM_CHAT_ID=-1001234567890

Discord

DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...

Pushover

PUSHOVER_DEVICE_NAME=your_device
PUSHOVER_USER_KEY=your_user_key
PUSHOVER_TOKEN=your_app_token

ntfy

NTFY_URL=https://ntfy.sh
NTFY_TOPIC=botpeass
# Optional authorization
NTFY_AUTH=Bearer yourtoken

You may configure multiple providers at once.

⸻

Running the Bot

One-Time Run

docker compose up --build

The container will:
	•	Run once
	•	Send alerts
	•	Update output/botpeas.json
	•	Exit cleanly

⸻

Backfill (Example: Last 7 Days)

To fetch historical CVEs for the last 7 days:

docker compose run --rm -e BACKFILL_DAYS=7 botpeass

This ignores the saved timestamps for that run only.

⚠️ Do not keep BACKFILL_DAYS set permanently, or it will re-alert every run.

⸻

Scheduling with Cron (Recommended)

Because BotPEASS is run-once, use cron on the host.

Every 8 Hours

0 */8 * * * cd /path/to/BotPEASS && /usr/bin/docker compose run --rm botpeass >> /var/log/botpeass.log 2>&1

Daily at 8 AM

0 8 * * * cd /path/to/BotPEASS && /usr/bin/docker compose run --rm botpeass


⸻

Reset State (Start Fresh)

If you want to forget all previously processed CVEs:

rm -f output/botpeas.json

Next run will start fresh.

⸻

Troubleshooting

No Alerts
	•	If ALL_VALID: false, ensure keywords actually match CVE summaries/products
	•	Test pipeline with:

docker compose run --rm -e BACKFILL_DAYS=3 botpeass


	•	Temporarily set:

ALL_VALID: true



Too Many Alerts
	•	Set ALL_VALID: false
	•	Reduce keyword scope

Warnings About Python Deprecation

Warnings like cgi or audioop deprecation are harmless and do not affect execution.

⸻

Security Notes
	•	Do not commit .env files with real tokens
	•	Treat all webhook URLs and bot tokens as secrets

⸻

License

See the LICENSE file.
