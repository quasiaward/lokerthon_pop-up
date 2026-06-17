from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from services.email_sender import send_email

router = APIRouter()


class ExperienceRequest(BaseModel):
    type: str
    adults: int
    children: int
    date: str
    time: str
    total_price: int


class CustomRequest(BaseModel):
    name: str
    phone: str
    box_size: int
    quantity: int
    items: list[str]
    pickup_date: str
    pickup_time: str
    total_price: int


class EmailResponse(BaseModel):
    success: bool


@router.post("/experience", response_model=EmailResponse)
async def email_experience(body: ExperienceRequest):
    subject = f"[행궁다과] 원데이클래스 체험 문의 — {body.date} {body.time}"
    content = f"""원데이클래스 체험 문의가 접수되었습니다.

체험 종류: {body.type}
성인 인원: {body.adults}명
어린이 인원: {body.children}명
희망 날짜: {body.date}
희망 시간: {body.time}
예상 체험비: {body.total_price:,}원
"""
    try:
        await send_email(subject=subject, body=content)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    return EmailResponse(success=True)


@router.post("/custom", response_model=EmailResponse)
async def email_custom(body: CustomRequest):
    items_str = ", ".join(body.items)
    subject = f"[행궁다과] 커스텀 다과상자 주문 — {body.name}"
    content = f"""커스텀 다과상자 주문이 접수되었습니다.

성함: {body.name}
연락처: {body.phone}
상자 크기: {body.box_size}구
수량: {body.quantity}개
선택 다과: {items_str}
희망 픽업 날짜: {body.pickup_date}
희망 픽업 시간: {body.pickup_time}
총 금액: {body.total_price:,}원
"""
    try:
        await send_email(subject=subject, body=content)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    return EmailResponse(success=True)
