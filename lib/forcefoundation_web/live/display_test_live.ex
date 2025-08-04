defmodule ForcefoundationWeb.DisplayTestLive do
  use ForcefoundationWeb, :live_view
  use ForcefoundationWeb.Widgets
  
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100 p-8">
      <.heading_widget level={1} text="Display Widget Examples" class="mb-8" />
      
      <!-- Text Widget Examples -->
      <.section_widget background={:white} rounded={:lg} padding={6} class="mb-8">
        <.heading_widget level={2} text="Text Widget" class="mb-6" />
        
        <div class="space-y-4">
          <!-- Size variations -->
          <div>
            <.heading_widget level={3} text="Text Sizes" class="mb-3" />
            <div class="space-y-2">
              <.text_widget text="Extra small text" size={:xs} />
              <br>
              <.text_widget text="Small text" size={:sm} />
              <br>
              <.text_widget text="Base text (default)" size={:base} />
              <br>
              <.text_widget text="Large text" size={:lg} />
              <br>
              <.text_widget text="Extra large text" size={:xl} />
              <br>
              <.text_widget text="2XL text" size={:xxl} />
              <br>
              <.text_widget text="3XL text" size={:xxxl} />
            </div>
          </div>
          
          <!-- Color variations -->
          <div>
            <.heading_widget level={3} text="Text Colors" class="mb-3" />
            <div class="space-x-4">
              <.text_widget text="Default" color={:default} />
              <.text_widget text="Primary" color={:primary} />
              <.text_widget text="Secondary" color={:secondary} />
              <.text_widget text="Accent" color={:accent} />
              <.text_widget text="Info" color={:info} />
              <.text_widget text="Success" color={:success} />
              <.text_widget text="Warning" color={:warning} />
              <.text_widget text="Error" color={:error} />
              <.text_widget text="Muted" color={:muted} />
            </div>
          </div>
          
          <!-- Weight variations -->
          <div>
            <.heading_widget level={3} text="Font Weights" class="mb-3" />
            <div class="space-y-2">
              <.text_widget text="Thin weight" weight={:thin} />
              <br>
              <.text_widget text="Light weight" weight={:light} />
              <br>
              <.text_widget text="Normal weight (default)" weight={:normal} />
              <br>
              <.text_widget text="Medium weight" weight={:medium} />
              <br>
              <.text_widget text="Semibold weight" weight={:semibold} />
              <br>
              <.text_widget text="Bold weight" weight={:bold} />
              <br>
              <.text_widget text="Extrabold weight" weight={:extrabold} />
              <br>
              <.text_widget text="Black weight" weight={:black} />
            </div>
          </div>
          
          <!-- Style variations -->
          <div>
            <.heading_widget level={3} text="Text Styles" class="mb-3" />
            <div class="space-x-4">
              <.text_widget text="Italic text" italic={true} />
              <.text_widget text="Underlined text" underline={true} />
              <.text_widget text="Italic underlined" italic={true} underline={true} />
              <.text_widget text="Truncated long text that will be cut off with ellipsis" truncate={true} class="max-w-xs" />
            </div>
          </div>
          
          <!-- Complex content with slot -->
          <div>
            <.heading_widget level={3} text="Complex Content (using slot)" class="mb-3" />
            <.text_widget text="" size={:lg} color={:primary}>
              This text has <strong>bold</strong> and <em>italic</em> elements inside it.
            </.text_widget>
          </div>
        </div>
      </.section_widget>
      
      <!-- Heading Widget Examples -->
      <.section_widget background={:white} rounded={:lg} padding={6} class="mb-8">
        <.heading_widget level={2} text="Heading Widget" class="mb-6" />
        
        <div class="space-y-4">
          <!-- All heading levels -->
          <div>
            <.heading_widget level={1} text="Heading Level 1" />
            <.heading_widget level={2} text="Heading Level 2" />
            <.heading_widget level={3} text="Heading Level 3" />
            <.heading_widget level={4} text="Heading Level 4" />
            <.heading_widget level={5} text="Heading Level 5" />
            <.heading_widget level={6} text="Heading Level 6" />
          </div>
          
          <!-- Custom colors and weights -->
          <div class="mt-8">
            <.heading_widget level={3} text="Custom Styled Headings" class="mb-4" />
            <.heading_widget level={2} text="Primary Color" color={:primary} />
            <.heading_widget level={2} text="Secondary Color" color={:secondary} />
            <.heading_widget level={2} text="Normal Weight" weight={:normal} />
            <.heading_widget level={2} text="Custom Size Override" size={:base} />
          </div>
        </div>
      </.section_widget>
      
      <!-- Badge Widget Examples -->
      <.section_widget background={:white} rounded={:lg} padding={6} class="mb-8">
        <.heading_widget level={2} text="Badge Widget" class="mb-6" />
        
        <div class="space-y-6">
          <!-- Color variations -->
          <div>
            <.heading_widget level={3} text="Badge Colors" class="mb-3" />
            <div class="flex flex-wrap gap-2">
              <.badge_widget label="Default" />
              <.badge_widget label="Primary" color={:primary} />
              <.badge_widget label="Secondary" color={:secondary} />
              <.badge_widget label="Accent" color={:accent} />
              <.badge_widget label="Info" color={:info} />
              <.badge_widget label="Success" color={:success} />
              <.badge_widget label="Warning" color={:warning} />
              <.badge_widget label="Error" color={:error} />
              <.badge_widget label="Ghost" color={:ghost} />
            </div>
          </div>
          
          <!-- Size variations -->
          <div>
            <.heading_widget level={3} text="Badge Sizes" class="mb-3" />
            <div class="flex items-center gap-2">
              <.badge_widget label="XS Badge" size={:xs} color={:primary} />
              <.badge_widget label="SM Badge" size={:sm} color={:primary} />
              <.badge_widget label="MD Badge (default)" size={:md} color={:primary} />
              <.badge_widget label="LG Badge" size={:lg} color={:primary} />
            </div>
          </div>
          
          <!-- Outline variations -->
          <div>
            <.heading_widget level={3} text="Outline Badges" class="mb-3" />
            <div class="flex flex-wrap gap-2">
              <.badge_widget label="Default" outline={true} />
              <.badge_widget label="Primary" color={:primary} outline={true} />
              <.badge_widget label="Secondary" color={:secondary} outline={true} />
              <.badge_widget label="Accent" color={:accent} outline={true} />
              <.badge_widget label="Info" color={:info} outline={true} />
              <.badge_widget label="Success" color={:success} outline={true} />
              <.badge_widget label="Warning" color={:warning} outline={true} />
              <.badge_widget label="Error" color={:error} outline={true} />
            </div>
          </div>
          
          <!-- Badges in context -->
          <div>
            <.heading_widget level={3} text="Badges in Context" class="mb-3" />
            <div class="space-y-2">
              <div>
                <.text_widget text="Product Status: " />
                <.badge_widget label="In Stock" color={:success} size={:sm} />
              </div>
              <div>
                <.text_widget text="User Role: " />
                <.badge_widget label="Admin" color={:primary} />
                <.badge_widget label="Moderator" color={:secondary} class="ml-2" />
              </div>
              <div>
                <.heading_widget level={4} text="Article Title" class="inline" />
                <.badge_widget label="NEW" color={:accent} size={:sm} class="ml-2" />
              </div>
            </div>
          </div>
        </div>
      </.section_widget>
      
      <!-- Debug Mode -->
      <.section_widget background={:white} rounded={:lg} padding={6}>
        <.heading_widget level={2} text="Debug Mode Examples" class="mb-6" />
        
        <.grid_widget columns={3} gap={4}>
          <.text_widget 
            text="Text with debug" 
            debug_mode={true} 
            size={:lg} 
            color={:primary}
            span={4}
          />
          
          <.heading_widget 
            level={3} 
            text="Heading with debug" 
            debug_mode={true}
            span={4}
          />
          
          <.badge_widget 
            label="Debug Badge" 
            color={:info} 
            debug_mode={true}
            span={4}
          />
        </.grid_widget>
      </.section_widget>
    </div>
    """
  end
end