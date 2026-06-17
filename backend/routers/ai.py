from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from ai.recommend import get_recommendation

router = APIRouter()


class RecommendRequest(BaseModel):
    answers: list[str]


class RecommendResponse(BaseModel):
    menu: str


@router.post("/recommend", response_model=RecommendResponse)
async def recommend(body: RecommendRequest):
    if len(body.answers) != 6:
        raise HTTPException(status_code=422, detail="answers must have exactly 6 items")
    menu = await get_recommendation(body.answers)
    return RecommendResponse(menu=menu)
