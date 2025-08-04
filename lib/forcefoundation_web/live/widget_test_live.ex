defmodule ForcefoundationWeb.WidgetTestLive do
  use ForcefoundationWeb, :live_view
  import ForcefoundationWeb.Widgets.TestWidget
  
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-8">
      <h1 class="text-2xl font-bold mb-4">Widget System Test Page</h1>
      
      <!-- Test our widget system -->
      <.test_widget message="Success! The widget system is working!" color={:success} />
      
      <div class="mt-4">
        <.test_widget 
          message="Testing with debug mode" 
          color={:info}
          debug_mode={true}
          span={6}
          padding={4}
        />
      </div>
      
      <div class="mt-4 grid grid-cols-2 gap-4">
        <.test_widget message="Primary alert" color={:primary} />
        <.test_widget message="Warning alert" color={:warning} />
      </div>
    </div>
    """
  end
end