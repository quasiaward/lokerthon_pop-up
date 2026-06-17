from .client import get_client
from .prompts import MENU_LIST, RECOMMEND_SYSTEM


async def get_recommendation(answers: list[str]) -> str:
    user_message = "\n".join(f"Q{i+1}: {a}" for i, a in enumerate(answers))

    response = await get_client().chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": RECOMMEND_SYSTEM},
            {"role": "user", "content": user_message},
        ],
        temperature=0.3,
    )

    raw = response.choices[0].message.content or ""
    menu = _parse_menu(raw)
    return menu


def _parse_menu(text: str) -> str:
    for menu in MENU_LIST:
        if menu in text:
            return menu
    # 매칭 실패 시 첫 번째 메뉴 반환 (추후 프롬프트 조정으로 해결)
    return MENU_LIST[0]
