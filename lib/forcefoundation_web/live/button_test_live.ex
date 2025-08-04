defmodule ForcefoundationWeb.ButtonTestLive do
  use ForcefoundationWeb, :live_view
  use ForcefoundationWeb.Widgets
  
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:loading_button, nil)
     |> assign(:clicked, nil)
     |> assign(:dropdown_open, false)}
  end
  
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-8">
      <.heading_widget level={1} text="Button Widget Test" class="mb-8" />
      
      <!-- Basic Buttons -->
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6} class="mb-8">
        <.heading_widget level={2} text="Basic Buttons" class="mb-6" />
        
        <div class="space-y-4">
          <!-- Variants -->
          <div>
            <.heading_widget level={3} text="Variants" class="mb-4" />
            <div class="flex flex-wrap gap-2">
              <.button_widget label="Default" on_click="button_click" phx_value_type="default" />
              <.button_widget label="Primary" variant={:primary} on_click="button_click" phx_value_type="primary" />
              <.button_widget label="Secondary" variant={:secondary} on_click="button_click" phx_value_type="secondary" />
              <.button_widget label="Accent" variant={:accent} on_click="button_click" phx_value_type="accent" />
              <.button_widget label="Success" variant={:success} on_click="button_click" phx_value_type="success" />
              <.button_widget label="Info" variant={:info} on_click="button_click" phx_value_type="info" />
              <.button_widget label="Warning" variant={:warning} on_click="button_click" phx_value_type="warning" />
              <.button_widget label="Error" variant={:error} on_click="button_click" phx_value_type="error" />
              <.button_widget label="Neutral" variant={:neutral} on_click="button_click" phx_value_type="neutral" />
            </div>
          </div>
          
          <!-- Styles -->
          <div>
            <.heading_widget level={3} text="Styles" class="mb-4" />
            <div class="flex flex-wrap gap-2">
              <.button_widget label="Solid" variant={:primary} style={:solid} />
              <.button_widget label="Outline" variant={:primary} style={:outline} />
              <.button_widget label="Ghost" variant={:primary} style={:ghost} />
              <.button_widget label="Link" variant={:primary} style={:link} />
            </div>
          </div>
          
          <!-- Sizes -->
          <div>
            <.heading_widget level={3} text="Sizes" class="mb-4" />
            <div class="flex flex-wrap items-center gap-2">
              <.button_widget label="Extra Small" variant={:primary} size={:xs} />
              <.button_widget label="Small" variant={:primary} size={:sm} />
              <.button_widget label="Medium" variant={:primary} size={:md} />
              <.button_widget label="Large" variant={:primary} size={:lg} />
            </div>
          </div>
          
          <!-- States -->
          <div>
            <.heading_widget level={3} text="States" class="mb-4" />
            <div class="flex flex-wrap gap-2">
              <.button_widget label="Normal" variant={:primary} />
              <.button_widget label="Disabled" variant={:primary} disabled={true} />
              <.button_widget 
                label={@loading_button == "loading" && "Loading..." || "Click to Load"} 
                variant={:primary} 
                loading={@loading_button == "loading"}
                on_click="toggle_loading"
              />
              <.button_widget label="Full Width" variant={:primary} full_width={true} class="mt-2" />
            </div>
          </div>
          
          <!-- With Icons -->
          <div>
            <.heading_widget level={3} text="With Icons" class="mb-4" />
            <div class="flex flex-wrap gap-2">
              <.button_widget label="Save" variant={:success} icon="hero-check" on_click="button_click" phx_value_type="save" />
              <.button_widget label="Delete" variant={:error} icon="hero-trash" icon_position={:left} />
              <.button_widget label="Next" variant={:primary} icon="hero-arrow-right" icon_position={:right} />
              <.button_widget label="Download" variant={:info} icon="hero-arrow-down-tray" />
            </div>
          </div>
          
          <!-- Shapes -->
          <div>
            <.heading_widget level={3} text="Shapes" class="mb-4" />
            <div class="flex flex-wrap gap-2">
              <.button_widget label="Default" variant={:primary} />
              <.button_widget label="SQ" variant={:primary} shape={:square} />
              <.button_widget label="O" variant={:primary} shape={:circle} />
              <.button_widget label="Wide Button" variant={:primary} shape={:wide} />
            </div>
          </div>
          
          <!-- With Confirm -->
          <div>
            <.heading_widget level={3} text="With Confirmation" class="mb-4" />
            <div class="flex flex-wrap gap-2">
              <.button_widget 
                label="Delete Account" 
                variant={:error} 
                icon="hero-exclamation-triangle"
                confirm="Are you sure you want to delete your account? This action cannot be undone."
                on_click="button_click"
                phx_value_type="delete-confirm"
              />
            </div>
          </div>
        </div>
      </.section_widget>
      
      <!-- Icon Buttons -->
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6} class="mb-8">
        <.heading_widget level={2} text="Icon Buttons" class="mb-6" />
        
        <div class="space-y-4">
          <div class="flex flex-wrap items-center gap-2">
            <.icon_button_widget icon="hero-pencil" tooltip="Edit" on_click="button_click" phx_value_type="edit" />
            <.icon_button_widget icon="hero-trash" variant={:error} tooltip="Delete" />
            <.icon_button_widget icon="hero-heart" variant={:accent} tooltip="Favorite" />
            <.icon_button_widget icon="hero-share" variant={:info} tooltip="Share" />
            <.icon_button_widget icon="hero-cog-6-tooth" variant={:secondary} tooltip="Settings" />
          </div>
          
          <!-- Different sizes -->
          <div>
            <.heading_widget level={3} text="Icon Button Sizes" class="mb-4" />
            <div class="flex flex-wrap items-center gap-2">
              <.icon_button_widget icon="hero-plus" size={:xs} tooltip="Add (XS)" />
              <.icon_button_widget icon="hero-plus" size={:sm} tooltip="Add (SM)" />
              <.icon_button_widget icon="hero-plus" size={:md} tooltip="Add (MD)" />
              <.icon_button_widget icon="hero-plus" size={:lg} tooltip="Add (LG)" />
            </div>
          </div>
        </div>
      </.section_widget>
      
      <!-- Button Groups -->
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6} class="mb-8">
        <.heading_widget level={2} text="Button Groups" class="mb-6" />
        
        <div class="space-y-6">
          <!-- Horizontal Group -->
          <div>
            <.heading_widget level={3} text="Horizontal Group" class="mb-4" />
            <.button_group_widget>
              <:button label="Left" on_click="button_click" active={@clicked == "group-left"} />
              <:button label="Center" on_click="button_click" active={@clicked == "group-center"} />
              <:button label="Right" on_click="button_click" active={@clicked == "group-right"} />
            </.button_group_widget>
          </div>
          
          <!-- Vertical Group -->
          <div>
            <.heading_widget level={3} text="Vertical Group" class="mb-4" />
            <.button_group_widget layout={:vertical} size={:sm}>
              <:button icon="hero-arrow-up" tooltip="Up" />
              <:button icon="hero-pause" tooltip="Pause" />
              <:button icon="hero-arrow-down" tooltip="Down" />
            </.button_group_widget>
          </div>
          
          <!-- Mixed Content Group -->
          <div>
            <.heading_widget level={3} text="Mixed Content" class="mb-4" />
            <.button_group_widget variant={:primary}>
              <:button icon="hero-play" label="Play" />
              <:button icon="hero-pause" label="Pause" />
              <:button icon="hero-stop" label="Stop" />
            </.button_group_widget>
          </div>
        </div>
      </.section_widget>
      
      <!-- Dropdown Buttons -->
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6} class="mb-8">
        <.heading_widget level={2} text="Dropdown Buttons" class="mb-6" />
        
        <div class="space-y-6">
          <div class="flex flex-wrap gap-4">
            <!-- Basic Dropdown -->
            <.dropdown_button_widget label="Options">
              <:item label="Edit" icon="hero-pencil" on_click="dropdown_action" />
              <:item label="Duplicate" icon="hero-document-duplicate" on_click="dropdown_action" />
              <:item divider />
              <:item label="Delete" icon="hero-trash" on_click="dropdown_action" />
            </.dropdown_button_widget>
            
            <!-- Primary Dropdown -->
            <.dropdown_button_widget label="Actions" variant={:primary}>
              <:item label="Save" icon="hero-check" on_click="dropdown_action" />
              <:item label="Save As..." icon="hero-document-plus" on_click="dropdown_action" />
              <:item divider />
              <:item label="Export" icon="hero-arrow-up-tray" on_click="dropdown_action" />
              <:item label="Print" icon="hero-printer" on_click="dropdown_action" />
            </.dropdown_button_widget>
            
            <!-- With Disabled Items -->
            <.dropdown_button_widget label="File" variant={:secondary}>
              <:item label="New" icon="hero-document-plus" on_click="dropdown_action" />
              <:item label="Open" icon="hero-folder-open" on_click="dropdown_action" />
              <:item label="Recent" icon="hero-clock" disabled />
              <:item divider />
              <:item label="Settings" icon="hero-cog-6-tooth" on_click="dropdown_action" />
            </.dropdown_button_widget>
            
            <!-- Different Alignments -->
            <.dropdown_button_widget label="Align Start" align={:start}>
              <:item label="Option 1" />
              <:item label="Option 2" />
              <:item label="Option 3" />
            </.dropdown_button_widget>
          </div>
        </div>
      </.section_widget>
      
      <!-- Click Feedback -->
      <%= if @clicked do %>
        <.section_widget background={:white} rounded={:lg} shadow={:md} padding={4}>
          <div class="text-center">
            <.text_widget text={"Last clicked: #{@clicked}"} size={:lg} class="font-semibold" />
          </div>
        </.section_widget>
      <% end %>
    </div>
    """
  end
  
  def handle_event("button_click", %{"type" => type}, socket) do
    {:noreply, assign(socket, :clicked, type)}
  end
  
  def handle_event("button_click", _, socket) do
    {:noreply, assign(socket, :clicked, "button")}
  end
  
  def handle_event("toggle_loading", _, socket) do
    case socket.assigns.loading_button do
      "loading" ->
        {:noreply, assign(socket, :loading_button, nil)}
      _ ->
        # Simulate loading for 2 seconds
        Process.send_after(self(), :stop_loading, 2000)
        {:noreply, assign(socket, :loading_button, "loading")}
    end
  end
  
  def handle_event("dropdown_action", %{"label" => label}, socket) do
    {:noreply, 
     socket
     |> assign(:clicked, "dropdown: #{label}")
     |> put_flash(:info, "Dropdown action: #{label}")}
  end
  
  def handle_info(:stop_loading, socket) do
    {:noreply, assign(socket, :loading_button, nil)}
  end
end