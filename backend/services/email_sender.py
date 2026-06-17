import os
import resend


async def send_email(subject: str, body: str) -> None:
    resend.api_key = os.environ["RESEND_API_KEY"]
    owner_email = os.environ["OWNER_EMAIL"]
    from_email = os.environ.get("FROM_EMAIL", "onboarding@resend.dev")

    resend.Emails.send({
        "from": from_email,
        "to": [owner_email],
        "subject": subject,
        "text": body,
    })
