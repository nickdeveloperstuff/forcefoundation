defmodule ForcefoundationWeb.Widgets.Helpers do
  @moduledoc """
  Helper functions for widget styling, spacing, and layout.
  
  Implements a 4px atomic spacing system:
  - 1 unit = 4px
  - 2 units = 8px
  - 3 units = 12px
  - 4 units = 16px (base)
  - 6 units = 24px
  - 8 units = 32px
  """
  
  # Grid column classes (12-column system)
  def span_class(nil), do: nil
  def span_class(1), do: "col-span-1"
  def span_class(2), do: "col-span-2"
  def span_class(3), do: "col-span-3"
  def span_class(4), do: "col-span-4"
  def span_class(6), do: "col-span-6"
  def span_class(8), do: "col-span-8"
  def span_class(12), do: "col-span-12"
  
  # Padding classes (4px base)
  def padding_class(nil), do: nil
  def padding_class(0), do: "p-0"
  def padding_class(1), do: "p-1"   # 4px
  def padding_class(2), do: "p-2"   # 8px
  def padding_class(3), do: "p-3"   # 12px
  def padding_class(4), do: "p-4"   # 16px (default)
  def padding_class(6), do: "p-6"   # 24px
  def padding_class(8), do: "p-8"   # 32px
  
  # Margin classes (4px base)
  def margin_class(nil), do: nil
  def margin_class(0), do: "m-0"
  def margin_class(1), do: "m-1"   # 4px
  def margin_class(2), do: "m-2"   # 8px
  def margin_class(3), do: "m-3"   # 12px
  def margin_class(4), do: "m-4"   # 16px
  def margin_class(6), do: "m-6"   # 24px
  def margin_class(8), do: "m-8"   # 32px
  
  # Gap classes for flex/grid
  def gap_class(nil), do: nil
  def gap_class(0), do: "gap-0"
  def gap_class(1), do: "gap-1"   # 4px
  def gap_class(2), do: "gap-2"   # 8px
  def gap_class(3), do: "gap-3"   # 12px
  def gap_class(4), do: "gap-4"   # 16px
  def gap_class(6), do: "gap-6"   # 24px
  def gap_class(8), do: "gap-8"   # 32px
end