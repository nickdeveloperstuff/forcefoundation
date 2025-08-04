defmodule ForcefoundationWeb.AdditionalActionTestLive do
  use ForcefoundationWeb, :live_view
  use ForcefoundationWeb.Widgets
  import ForcefoundationWeb.Widgets.Action.DropdownWidget
  import ForcefoundationWeb.Widgets.Action.ToolbarWidget
  import ForcefoundationWeb.Widgets.Action.ContextMenuWidget
  
  def mount(_params, _session, socket) do
    {:ok, 
     socket
     |> assign(:last_action, nil)
     |> assign(:toolbar_variant, :default)}
  end
  
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-8">
      <.heading_widget level={1} text="Additional Action Widgets Test" class="mb-8" />
      
      <!-- Dropdown Widget Examples -->
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6} class="mb-8">
        <.heading_widget level={2} text="Dropdown Widgets" class="mb-6" />
        
        <div class="space-y-6">
          <!-- Basic Dropdown -->
          <div>
            <.heading_widget level={3} text="Basic Dropdown" class="mb-4" />
            <.dropdown_widget label="Actions">
              <:item icon="hero-pencil" on_click="action_edit">Edit</:item>
              <:item icon="hero-document-duplicate" on_click="action_duplicate">Duplicate</:item>
              <:item icon="hero-share" on_click="action_share">Share</:item>
              <:divider />
              <:item icon="hero-trash" on_click="action_delete" variant={:error}>Delete</:item>
            </.dropdown_widget>
          </div>
          
          <!-- Positioned Dropdown -->
          <div>
            <.heading_widget level={3} text="Positioned Dropdowns" class="mb-4" />
            <div class="flex gap-4 flex-wrap">
              <.dropdown_widget label="Bottom Start" position={:bottom_start} variant={:primary}>
                <:item on_click="action_click">Option 1</:item>
                <:item on_click="action_click">Option 2</:item>
              </.dropdown_widget>
              
              <.dropdown_widget label="Bottom End" position={:bottom_end} variant={:secondary}>
                <:item on_click="action_click">Option 1</:item>
                <:item on_click="action_click">Option 2</:item>
              </.dropdown_widget>
              
              <.dropdown_widget label="Right" position={:right} variant={:accent}>
                <:item on_click="action_click">Option 1</:item>
                <:item on_click="action_click">Option 2</:item>
              </.dropdown_widget>
            </div>
          </div>
          
          <!-- Dropdown with Disabled Items -->
          <div>
            <.heading_widget level={3} text="With Disabled Items" class="mb-4" />
            <.dropdown_widget label="File" variant={:ghost} icon="hero-document">
              <:item icon="hero-document-plus" on_click="action_new">New</:item>
              <:item icon="hero-folder-open" on_click="action_open">Open</:item>
              <:item icon="hero-arrow-down-tray" on_click="action_save">Save</:item>
              <:divider />
              <:item icon="hero-printer" on_click="action_print" disabled={true}>Print (Disabled)</:item>
              <:item icon="hero-arrow-up-on-square" on_click="action_export" disabled={true}>Export (Disabled)</:item>
            </.dropdown_widget>
          </div>
        </div>
      </.section_widget>
      
      <!-- Toolbar Widget Examples -->
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6} class="mb-8">
        <.heading_widget level={2} text="Toolbar Widgets" class="mb-6" />
        
        <div class="space-y-6">
          <!-- Basic Toolbar -->
          <div>
            <.heading_widget level={3} text="Basic Toolbar" class="mb-4" />
            <.toolbar_widget>
              <:start>
                <.button_widget label="New" icon="hero-plus" variant={:primary} on_click="toolbar_new" />
                <.button_widget label="Open" icon="hero-folder-open" on_click="toolbar_open" />
              </:start>
              
              <:end_section>
                <.button_widget label="Save" icon="hero-check" variant={:success} on_click="toolbar_save" />
                <.dropdown_widget label="More" icon="hero-ellipsis-horizontal">
                  <:item on_click="toolbar_settings">Settings</:item>
                  <:item on_click="toolbar_help">Help</:item>
                </.dropdown_widget>
              </:end_section>
            </.toolbar_widget>
          </div>
          
          <!-- Toolbar with Center Section -->
          <div>
            <.heading_widget level={3} text="Text Editor Toolbar" class="mb-4" />
            <.toolbar_widget variant={:bordered} size={:sm}>
              <:start>
                <.button_widget label="Undo" icon="hero-arrow-uturn-left" size={:sm} on_click="toolbar_undo" />
                <.button_widget label="Redo" icon="hero-arrow-uturn-right" size={:sm} on_click="toolbar_redo" />
              </:start>
              
              <:center>
                <.button_group_widget>
                  <.button_widget icon="hero-bold" size={:sm} on_click="toolbar_bold" tooltip="Bold" />
                  <.button_widget icon="hero-italic" size={:sm} on_click="toolbar_italic" tooltip="Italic" />
                  <.button_widget icon="hero-underline" size={:sm} on_click="toolbar_underline" tooltip="Underline" />
                </.button_group_widget>
                
                <.button_group_widget>
                  <.button_widget icon="hero-list-bullet" size={:sm} on_click="toolbar_list" tooltip="Bullet List" />
                  <.button_widget icon="hero-numbered-list" size={:sm} on_click="toolbar_numbered" tooltip="Numbered List" />
                </.button_group_widget>
              </:center>
              
              <:end_section>
                <.dropdown_widget label="Format" size={:sm}>
                  <:item on_click="toolbar_format_h1">Heading 1</:item>
                  <:item on_click="toolbar_format_h2">Heading 2</:item>
                  <:item on_click="toolbar_format_p">Paragraph</:item>
                </.dropdown_widget>
              </:end_section>
            </.toolbar_widget>
          </div>
          
          <!-- Toolbar Variants -->
          <div>
            <.heading_widget level={3} text="Toolbar Variants" class="mb-4" />
            <div class="space-y-4">
              <.toolbar_widget variant={:default}>
                <:start>
                  <.text_widget text="Default Variant" />
                </:start>
                <:end_section>
                  <.button_widget label="Action" on_click="toolbar_action" />
                </:end_section>
              </.toolbar_widget>
              
              <.toolbar_widget variant={:bordered}>
                <:start>
                  <.text_widget text="Bordered Variant" />
                </:start>
                <:end_section>
                  <.button_widget label="Action" on_click="toolbar_action" />
                </:end_section>
              </.toolbar_widget>
              
              <.toolbar_widget variant={:elevated}>
                <:start>
                  <.text_widget text="Elevated Variant" />
                </:start>
                <:end_section>
                  <.button_widget label="Action" on_click="toolbar_action" />
                </:end_section>
              </.toolbar_widget>
            </div>
          </div>
        </div>
      </.section_widget>
      
      <!-- Context Menu Widget Examples -->
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6} class="mb-8">
        <.heading_widget level={2} text="Context Menu Widget" class="mb-6" />
        
        <div class="space-y-6">
          <!-- Basic Context Menu -->
          <div>
            <.heading_widget level={3} text="Right-Click Context Menu" class="mb-4" />
            
            <.context_menu_widget target_id="context-area-1">
              <:item icon="hero-pencil" on_click="context_edit">Edit</:item>
              <:item icon="hero-document-duplicate" on_click="context_copy">Copy</:item>
              <:item icon="hero-clipboard" on_click="context_paste">Paste</:item>
              <:divider />
              <:item icon="hero-trash" on_click="context_delete" variant={:error}>Delete</:item>
            </.context_menu_widget>
            
            <div 
              id="context-area-1" 
              class="p-8 border-2 border-dashed border-gray-300 rounded-lg text-center bg-gray-50"
            >
              <.text_widget text="Right-click anywhere in this area" class="text-gray-600" />
            </div>
          </div>
          
          <!-- Context Menu with Different Content -->
          <div>
            <.heading_widget level={3} text="File Browser Context Menu" class="mb-4" />
            
            <.context_menu_widget target_id="context-area-2">
              <:item icon="hero-folder-plus" on_click="context_new_folder">New Folder</:item>
              <:item icon="hero-document-plus" on_click="context_new_file">New File</:item>
              <:divider />
              <:item icon="hero-arrow-down-tray" on_click="context_download">Download</:item>
              <:item icon="hero-share" on_click="context_share">Share</:item>
              <:divider />
              <:item icon="hero-information-circle" on_click="context_properties">Properties</:item>
            </.context_menu_widget>
            
            <div 
              id="context-area-2" 
              class="p-8 border-2 border-dashed border-blue-300 rounded-lg text-center bg-blue-50"
            >
              <.text_widget text="File browser simulation - right-click here" class="text-blue-600" />
            </div>
          </div>
        </div>
      </.section_widget>
      
      <!-- Action Result Display -->
      <%= if @last_action do %>
        <.section_widget background={:white} rounded={:lg} shadow={:md} padding={4}>
          <.heading_widget level={3} text="Last Action" class="mb-2" />
          <.text_widget text={"Action triggered: #{@last_action}"} class="font-mono text-sm" />
        </.section_widget>
      <% end %>
    </div>
    """
  end
  
  # Handle dropdown actions
  def handle_event("action_" <> action, _params, socket) do
    {:noreply, assign(socket, :last_action, "Dropdown: #{action}")}
  end
  
  # Handle toolbar actions
  def handle_event("toolbar_" <> action, _params, socket) do
    {:noreply, assign(socket, :last_action, "Toolbar: #{action}")}
  end
  
  # Handle context menu actions
  def handle_event("context_" <> action, _params, socket) do
    {:noreply, assign(socket, :last_action, "Context Menu: #{action}")}
  end
end