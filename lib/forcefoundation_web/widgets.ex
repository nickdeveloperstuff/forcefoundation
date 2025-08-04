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
      # import ForcefoundationWeb.Widgets.FormWidget
      # import ForcefoundationWeb.Widgets.InputWidget
      
      # Test widgets
      import ForcefoundationWeb.Widgets.TestWidget
      import ForcefoundationWeb.Widgets.ConnectionTestWidget
    end
  end
end