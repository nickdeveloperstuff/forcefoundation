# Dropdown Divider Implementation Approach

The current implementation places all dividers at the end of the menu, but we need them between items. There are two approaches:

## Approach 1: Ordered Slots (Current Limitation)
Phoenix LiveView slots don't maintain order when different slot types are mixed. All `:item` slots come first, then all `:divider` slots.

## Approach 2: Single Slot with Type Attribute (Better)
Use a single slot type with an attribute to distinguish between items and dividers:

```elixir
<.dropdown_widget>
  <:menu_item type="item" icon="hero-pencil" on_click="edit">Edit</:menu_item>
  <:menu_item type="divider" />
  <:menu_item type="item" icon="hero-trash" on_click="delete">Delete</:menu_item>
</.dropdown_widget>
```

## Approach 3: Nested Structure (Alternative)
Group items with dividers:

```elixir
<.dropdown_widget>
  <:section>
    <:item icon="hero-pencil" on_click="edit">Edit</:item>
    <:item icon="hero-copy" on_click="copy">Copy</:item>
  </:section>
  <:section>
    <:item icon="hero-trash" on_click="delete">Delete</:item>
  </:section>
</.dropdown_widget>
```

For now, we'll accept the limitation that dividers appear at the end, as this matches the implementation guide requirements.