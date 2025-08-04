defmodule ForcefoundationWeb.Widgets do
  @moduledoc """
  Central registry for all widgets in the system.
  
  This module:
  - Imports all widget modules
  - Provides a single import point for LiveViews
  - Manages widget discovery and registration
  """
  
  # Import all widgets here as we create them
  # This will grow as we add more widgets
  defmacro __using__(_opts) do
    quote do
      # Foundation widgets
      import ForcefoundationWeb.Widgets.GridWidget
      import ForcefoundationWeb.Widgets.FlexWidget
      import ForcefoundationWeb.Widgets.SectionWidget
      
      # Display widgets
      import ForcefoundationWeb.Widgets.TextWidget
      import ForcefoundationWeb.Widgets.HeadingWidget
      import ForcefoundationWeb.Widgets.CardWidget
      import ForcefoundationWeb.Widgets.BadgeWidget
      
      # Form widgets
      import ForcefoundationWeb.Widgets.FormWidget
      import ForcefoundationWeb.Widgets.InputWidget
      import ForcefoundationWeb.Widgets.SelectWidget
      import ForcefoundationWeb.Widgets.CheckboxWidget
      import ForcefoundationWeb.Widgets.RadioWidget
      import ForcefoundationWeb.Widgets.TextareaWidget
      import ForcefoundationWeb.Widgets.NestedFormWidget
      import ForcefoundationWeb.Widgets.FieldsetWidget
      import ForcefoundationWeb.Widgets.RepeaterWidget
      
      # Action widgets
      import ForcefoundationWeb.Widgets.ButtonWidget
      import ForcefoundationWeb.Widgets.IconButtonWidget
      import ForcefoundationWeb.Widgets.ButtonGroupWidget
      import ForcefoundationWeb.Widgets.DropdownButtonWidget
      import ForcefoundationWeb.Widgets.ActionButtonWidget
      import ForcefoundationWeb.Widgets.ConfirmDialogWidget
      import ForcefoundationWeb.Widgets.Action.DropdownWidget
      import ForcefoundationWeb.Widgets.Action.ToolbarWidget
      import ForcefoundationWeb.Widgets.Action.ContextMenuWidget
      
      # Data widgets
      import ForcefoundationWeb.Widgets.Data.TableWidget
      import ForcefoundationWeb.Widgets.StreamableTableWidget
      
      # Test widgets
      import ForcefoundationWeb.Widgets.TestWidget
      import ForcefoundationWeb.Widgets.ConnectionTestWidget
    end
  end
end