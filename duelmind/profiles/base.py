from dataclasses import dataclass, field


@dataclass(frozen=True)
class DeckProfile:
    profile_id: str
    display_name: str
    implemented: bool
    card_ids: frozenset[int] = field(default_factory=frozenset)
    required_inputs: tuple[str, ...] = ()
    strategy_version: str = "unimplemented"
