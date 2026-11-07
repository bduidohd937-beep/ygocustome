from .base import DeckProfile

OCEANTALE_PROFILE = DeckProfile(
    profile_id="ocean_tale",
    display_name="오션테일",
    implemented=False,
    required_inputs=(
        "실제 카드 ID와 카드명",
        "cards.json 카드 데이터",
        "Lua 스크립트와 효과 원문",
        "메인/엑스트라 덱 리스트",
        "WindBot 덱 등록명",
    ),
)
