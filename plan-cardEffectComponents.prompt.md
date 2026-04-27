## Plan: Card-Specific Effect Components

Build a per-card class architecture where each card logic owns one or more reusable effect components derived from `CardEffect`. These effects are triggered from either board lifecycle events or explicit calling. This keeps behavior isolated per card, avoids giant `match` blocks, and lets you compose shared effects across multiple cards. This draft focuses on wiring the minimum end-to-end path for current cards (`defect`, `mob_slime`, `gold_nugget`) while keeping expansion straightforward.

### Steps
1. Define effect and card contracts in [`scripts/cards/card_effects/card_effect.gd`](scripts/cards/card_effects/card_effect.gd) and card logic in [`scripts/cards/card_logics/card_logic.gd`] (`on_enter_field`, `on_leave_field`, `on_move_in_f
4. Wire triggers from [`scripts/board_events.gd`](scripts/board_events.gd) payloads into the owning card logic instance callbacks.
5. Create per-card card logic classes (for `defect`, `mob_slime`, `gold_nugget`) plus reusable effect components in `scripts/cards/card_effects/`, then compose effects per card logic class.
6. Keep visual nodes unchanged (`Card`/`Pawn` in [`scripts/cards/card.gd`](scripts/cards/card.gd), [`scripts/cards/pawn.gd`](scripts/cards/pawn.gd)); attach logic objects to visual nodes.

### Decisions
1. card logic should live on 'Card' or 'Pawn' instances for simplicity and direct access to visual nodes and state.
2. Initial triggers: `enter_field`, `leave_field`, `move_in_field` for core mechanics; `turn_start`, `turn_end`, `battle_start` can be added iteratively as needed.
3. Explicit manual registry table for clarity and control, with potential for convention-based loading in future iterations.