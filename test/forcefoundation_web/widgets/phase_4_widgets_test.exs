defmodule ForcefoundationWeb.Phase4WidgetsTest do
  use ForcefoundationWeb.ConnCase
  import Phoenix.LiveViewTest
  import Phoenix.Component
  use ForcefoundationWeb.Widgets
  
  describe "Phase 4 Button Widgets" do
    test "ButtonWidget compiles and renders" do
      assigns = %{}
      
      html = ~H"""
      <.button_widget 
        label="Test Button" 
        variant={:primary}
        size={:md}
        on_click="test_click"
      />
      """
      
      rendered = Phoenix.HTML.safe_to_string(html)
      assert rendered =~ "Test Button"
      assert rendered =~ "btn-primary"
      assert rendered =~ "phx-click=\"test_click\""
    end
    
    test "IconButtonWidget compiles and renders" do
      assigns = %{}
      
      html = ~H"""
      <.icon_button_widget 
        icon="hero-check"
        variant={:success}
        size={:sm}
      />
      """
      
      rendered = Phoenix.HTML.safe_to_string(html)
      assert rendered =~ "hero-check"
      assert rendered =~ "btn-success"
      assert rendered =~ "btn-sm"
    end
    
    test "ButtonGroupWidget compiles and renders" do
      assigns = %{}
      
      html = ~H"""
      <.button_group_widget>
        <.button_widget label="First" />
        <.button_widget label="Second" />
      </.button_group_widget>
      """
      
      rendered = Phoenix.HTML.safe_to_string(html)
      assert rendered =~ "btn-group"
      assert rendered =~ "First"
      assert rendered =~ "Second"
    end
    
    test "DropdownButtonWidget compiles and renders" do
      assigns = %{}
      
      html = ~H"""
      <.dropdown_button_widget label="Options">
        <:item on_click="edit">Edit</:item>
        <:item on_click="delete">Delete</:item>
      </.dropdown_button_widget>
      """
      
      rendered = Phoenix.HTML.safe_to_string(html)
      assert rendered =~ "dropdown"
      assert rendered =~ "Options"
      assert rendered =~ "Edit"
      assert rendered =~ "Delete"
    end
  end
  
  describe "Phase 4 Action Widgets" do
    test "ActionButtonWidget compiles and renders" do
      assigns = %{loading_actions: %{}}
      
      html = ~H"""
      <.action_button_widget 
        label="Create"
        action={:create}
        resource="User"
        variant={:primary}
      />
      """
      
      rendered = Phoenix.HTML.safe_to_string(html)
      assert rendered =~ "Create"
      assert rendered =~ "phx-click=\"execute_action\""
      assert rendered =~ "phx-value-action=\"create\""
    end
    
    test "ConfirmDialogWidget compiles and renders" do
      assigns = %{}
      
      html = ~H"""
      <.confirm_dialog_widget 
        id="test-confirm"
        title="Confirm Action"
        message="Are you sure?"
        confirm_event="do_action"
      />
      """
      
      rendered = Phoenix.HTML.safe_to_string(html)
      assert rendered =~ "modal"
      assert rendered =~ "Confirm Action"
      assert rendered =~ "Are you sure?"
    end
  end
  
  describe "Phase 4 Additional Action Widgets" do
    test "DropdownWidget compiles and renders" do
      assigns = %{}
      
      html = ~H"""
      <.dropdown_widget label="Menu">
        <:item on_click="action1">Action 1</:item>
        <:item on_click="action2">Action 2</:item>
      </.dropdown_widget>
      """
      
      rendered = Phoenix.HTML.safe_to_string(html)
      assert rendered =~ "dropdown"
      assert rendered =~ "Menu"
      assert rendered =~ "Action 1"
    end
    
    test "ToolbarWidget compiles and renders" do
      assigns = %{}
      
      html = ~H"""
      <.toolbar_widget>
        <:start>
          <.button_widget label="Save" />
        </:start>
        <:end_section>
          <.button_widget label="Cancel" />
        </:end_section>
      </.toolbar_widget>
      """
      
      rendered = Phoenix.HTML.safe_to_string(html)
      assert rendered =~ "toolbar"
      assert rendered =~ "Save"
      assert rendered =~ "Cancel"
    end
    
    test "ContextMenuWidget compiles and renders" do
      assigns = %{}
      
      html = ~H"""
      <.context_menu_widget target_id="test-target">
        <:item on_click="copy">Copy</:item>
        <:item on_click="paste">Paste</:item>
      </.context_menu_widget>
      """
      
      rendered = Phoenix.HTML.safe_to_string(html)
      assert rendered =~ "dropdown-content"
      assert rendered =~ "Copy"
      assert rendered =~ "Paste"
      assert rendered =~ "data-target-id=\"test-target\""
    end
  end
  
  describe "Phase 4 Integration" do
    test "all widgets are accessible through use ForcefoundationWeb.Widgets" do
      # This test verifies that all widgets can be imported and used
      module_functions = ForcefoundationWeb.Widgets.__info__(:functions)
      
      # Check button widgets
      assert {:button_widget, 1} in module_functions
      assert {:icon_button_widget, 1} in module_functions
      assert {:button_group_widget, 1} in module_functions
      assert {:dropdown_button_widget, 1} in module_functions
      
      # Check action widgets
      assert {:action_button_widget, 1} in module_functions
      assert {:confirm_dialog_widget, 1} in module_functions
    end
    
    test "action handler module functions are available" do
      # Verify ActionHandler module exists and has expected functions
      assert function_exported?(ForcefoundationWeb.Widgets.ActionHandler, :handle_action, 3)
      assert function_exported?(ForcefoundationWeb.Widgets.ActionHandler, :loading?, 2)
      assert function_exported?(ForcefoundationWeb.Widgets.ActionHandler, :confirm_action, 3)
      assert function_exported?(ForcefoundationWeb.Widgets.ActionHandler, :execute_action, 3)
    end
  end
end