import logging
import os
import smtplib
from email.mime.text import MIMEText

logger = logging.getLogger(__name__)


async def send_email(subject: str, body: str) -> None:
    smtp_host = os.environ["SMTP_HOST"]
    smtp_port = int(os.environ["SMTP_PORT"])
    smtp_user = os.environ["SMTP_USER"]
    smtp_password = os.environ["SMTP_PASSWORD"]
    owner_email = os.environ["OWNER_EMAIL"]

    logger.info("Sending email to %s via %s:%s", owner_email, smtp_host, smtp_port)

    msg = MIMEText(body, "plain", "utf-8")
    msg["Subject"] = subject
    msg["From"] = smtp_user
    msg["To"] = owner_email

    try:
        with smtplib.SMTP(smtp_host, smtp_port) as server:
            server.starttls()
            server.login(smtp_user, smtp_password)
            server.sendmail(smtp_user, [owner_email], msg.as_string())
        logger.info("Email sent successfully")
    except Exception as e:
        logger.error("Email send failed: %s", repr(e))
        raise
