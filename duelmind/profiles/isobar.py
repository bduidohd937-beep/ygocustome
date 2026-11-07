from .base import DeckProfile

ISOBAR_CARD_IDS = frozenset(range(210000201, 210000217))

ISOBAR_PROFILE = DeckProfile(
    profile_id="isobar",
    display_name="흑철기상청 - 이소바르",
    implemented=True,
    card_ids=ISOBAR_CARD_IDS,
    strategy_version="v2.2",
)
