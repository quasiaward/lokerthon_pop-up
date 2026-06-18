import logging
import os

import httpx

logger = logging.getLogger(__name__)


async def send_email(subject: str, body: str) -> None:
    api_key = os.environ["SENDGRID_API_KEY"]
    sender_email = os.environ["SMTP_USER"]
    owner_email = os.environ["OWNER_EMAIL"]

    payload = {
        "personalizations": [{"to": [{"email": owner_email}]}],
        "from": {"email": sender_email},
        "subject": subject,
        "content": [{"type": "text/plain", "value": body}],
    }

    async with httpx.AsyncClient() as client:
        res = await client.post(
            "https://api.sendgrid.com/v3/mail/send",
            headers={"Authorization": f"Bearer {api_key}"},
            json=payload,
        )

    if res.status_code not in (200, 202):
        logger.error("SendGrid error %s: %s", res.status_code, res.text)
        raise RuntimeError(f"SendGrid error {res.status_code}: {res.text}")

    logger.info("Email sent successfully")
