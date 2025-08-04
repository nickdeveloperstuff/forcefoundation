defmodule ForcefoundationWeb.LayoutTestLive do
  use ForcefoundationWeb, :live_view
  use ForcefoundationWeb.Widgets
  
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :selected_demo, :grid)}
  end
  
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100">
      <!-- Navigation -->
      <.section_widget background={:white} shadow={:md} padding={4}>
        <.flex_widget justify={:between} align={:center}>
          <h1 class="text-2xl font-bold">Layout Widget Tests</h1>
          <.flex_widget gap={2}>
            <button 
              class={["btn", @selected_demo == :grid && "btn-primary" || "btn-ghost"]}
              phx-click="select_demo" 
              phx-value-demo="grid"
            >
              Grid Demo
            </button>
            <button 
              class={["btn", @selected_demo == :flex && "btn-primary" || "btn-ghost"]}
              phx-click="select_demo" 
              phx-value-demo="flex"
            >
              Flex Demo
            </button>
            <button 
              class={["btn", @selected_demo == :section && "btn-primary" || "btn-ghost"]}
              phx-click="select_demo" 
              phx-value-demo="section"
            >
              Section Demo
            </button>
          </.flex_widget>
        </.flex_widget>
      </.section_widget>
      
      <!-- Content -->
      <div class="p-8">
        <%= case @selected_demo do %>
          <% :grid -> %>
            <%= render_grid_demo(assigns) %>
          <% :flex -> %>
            <%= render_flex_demo(assigns) %>
          <% :section -> %>
            <%= render_section_demo(assigns) %>
        <% end %>
      </div>
    </div>
    """
  end
  
  defp render_grid_demo(assigns) do
    ~H"""
    <div class="space-y-8">
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6}>
        <h2 class="text-xl font-semibold mb-4">Basic Grid (12 columns)</h2>
        <.grid_widget columns={12} gap={4} debug_mode={true}>
          <div class="col-span-12 bg-blue-200 p-4 rounded">Full width (span-12)</div>
          <div class="col-span-6 bg-green-200 p-4 rounded">Half width (span-6)</div>
          <div class="col-span-6 bg-green-200 p-4 rounded">Half width (span-6)</div>
          <div class="col-span-4 bg-yellow-200 p-4 rounded">Third (span-4)</div>
          <div class="col-span-4 bg-yellow-200 p-4 rounded">Third (span-4)</div>
          <div class="col-span-4 bg-yellow-200 p-4 rounded">Third (span-4)</div>
          <div class="col-span-3 bg-purple-200 p-4 rounded">Quarter</div>
          <div class="col-span-3 bg-purple-200 p-4 rounded">Quarter</div>
          <div class="col-span-3 bg-purple-200 p-4 rounded">Quarter</div>
          <div class="col-span-3 bg-purple-200 p-4 rounded">Quarter</div>
        </.grid_widget>
      </.section_widget>
      
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6}>
        <h2 class="text-xl font-semibold mb-4">Responsive Grid</h2>
        <.grid_widget 
          columns={%{mobile: 1, tablet: 2, desktop: 4}} 
          gap={4}
        >
          <%= for i <- 1..8 do %>
            <div class="bg-indigo-200 p-4 rounded text-center">
              Item <%= i %>
            </div>
          <% end %>
        </.grid_widget>
      </.section_widget>
    </div>
    """
  end
  
  defp render_flex_demo(assigns) do
    ~H"""
    <div class="space-y-8">
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6}>
        <h2 class="text-xl font-semibold mb-4">Flex Layouts</h2>
        
        <!-- Horizontal layouts -->
        <div class="space-y-4">
          <div>
            <h3 class="font-medium mb-2">Justify: Space Between</h3>
            <.flex_widget justify={:between} align={:center} debug_mode={true}>
              <div class="bg-red-200 p-4 rounded">Left</div>
              <div class="bg-green-200 p-4 rounded">Center</div>
              <div class="bg-blue-200 p-4 rounded">Right</div>
            </.flex_widget>
          </div>
          
          <div>
            <h3 class="font-medium mb-2">Justify: Center with Gap</h3>
            <.flex_widget justify={:center} gap={4}>
              <div class="bg-yellow-200 p-4 rounded">Item 1</div>
              <div class="bg-yellow-200 p-4 rounded">Item 2</div>
              <div class="bg-yellow-200 p-4 rounded">Item 3</div>
            </.flex_widget>
          </div>
          
          <div>
            <h3 class="font-medium mb-2">Column Direction</h3>
            <.flex_widget direction={:col} gap={2} align={:start}>
              <div class="bg-purple-200 p-2 rounded w-full">Row 1</div>
              <div class="bg-purple-200 p-2 rounded w-3/4">Row 2 (75%)</div>
              <div class="bg-purple-200 p-2 rounded w-1/2">Row 3 (50%)</div>
            </.flex_widget>
          </div>
        </div>
      </.section_widget>
    </div>
    """
  end
  
  defp render_section_demo(assigns) do
    ~H"""
    <div class="space-y-8">
      <.section_widget 
        background={:white} 
        rounded={:lg} 
        shadow={:lg} 
        padding={6}
        border={true}
      >
        <:header sticky={true}>
          <.flex_widget justify={:between} align={:center} padding={4}>
            <h2 class="text-xl font-semibold">Section with Sticky Header</h2>
            <span class="text-sm text-gray-500">Scroll to see sticky behavior</span>
          </.flex_widget>
        </:header>
        
        <div class="space-y-4">
          <%= for i <- 1..10 do %>
            <p class="text-gray-700">
              This is paragraph <%= i %>. Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
              Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
            </p>
          <% end %>
        </div>
        
        <:footer>
          <div class="border-t pt-4 mt-4">
            <p class="text-sm text-gray-500">This is the footer section</p>
          </div>
        </:footer>
      </.section_widget>
      
      <.section_widget background={:gradient} rounded={:xl} padding={8}>
        <h2 class="text-2xl font-bold mb-4">Gradient Background Section</h2>
        <p>This section has a gradient background and extra padding.</p>
      </.section_widget>
    </div>
    """
  end
  
  def handle_event("select_demo", %{"demo" => demo}, socket) do
    {:noreply, assign(socket, :selected_demo, String.to_atom(demo))}
  end
end