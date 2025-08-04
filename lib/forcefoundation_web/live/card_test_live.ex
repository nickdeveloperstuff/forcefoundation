defmodule ForcefoundationWeb.CardTestLive do
  use ForcefoundationWeb, :live_view
  use ForcefoundationWeb.Widgets
  
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100 p-8">
      <.heading_widget level={1} text="Card Widget Examples" class="mb-8" />
      
      <!-- Basic Cards Grid -->
      <.section_widget background={:white} rounded={:lg} padding={6} class="mb-8">
        <.heading_widget level={2} text="Basic Card Variations" class="mb-4" />
        
        <.grid_widget columns={3} gap={6}>
          <!-- Simple Card -->
          <.card_widget title="Simple Card" bordered={true}>
            <p>This is a simple card with just a title and body content.</p>
          </.card_widget>
          
          <!-- Card with Actions -->
          <.card_widget bordered={true} hoverable={true}>
            <:body>
              <.heading_widget level={3} text="Card with Actions" />
              <p>This card has action buttons and hover effect.</p>
            </:body>
            <:actions>
              <button class="btn btn-primary btn-sm">Save</button>
              <button class="btn btn-ghost btn-sm">Cancel</button>
            </:actions>
          </.card_widget>
          
          <!-- Clickable Card -->
          <.card_widget 
            title="Clickable Card" 
            bordered={true}
            clickable={true}
            on_click="card_clicked"
            hoverable={true}
          >
            <p>Click anywhere on this card to trigger an event.</p>
            <.badge_widget label="New" color={:primary} />
          </.card_widget>
        </.grid_widget>
      </.section_widget>
      
      <!-- Cards with Images -->
      <.section_widget background={:white} rounded={:lg} padding={6} class="mb-8">
        <.heading_widget level={2} text="Cards with Images" class="mb-4" />
        
        <.grid_widget columns={3} gap={6}>
          <!-- Card with Top Image -->
          <.card_widget 
            image="https://picsum.photos/400/200?random=1"
            image_alt="Random image"
            bordered={true}
          >
            <:badge>
              <.badge_widget label="Featured" color={:accent} />
            </:badge>
            <:body>
              <.heading_widget level={3} text="Top Image Card" />
              <p>Card with image on top and badge overlay.</p>
            </:body>
            <:actions>
              <button class="btn btn-primary btn-sm">View Details</button>
            </:actions>
          </.card_widget>
          
          <!-- Compact Card -->
          <.card_widget 
            variant={:compact}
            image="https://picsum.photos/400/200?random=2"
            bordered={true}
          >
            <:body>
              <.heading_widget level={3} text="Compact Card" size={:lg} />
              <p class="text-sm">Less padding for dense layouts.</p>
            </:body>
          </.card_widget>
          
          <!-- Side Image Card (spans 2 columns) -->
          <div class="col-span-2">
            <.card_widget 
              variant={:side}
              image="https://picsum.photos/200/200?random=3"
              bordered={true}
            >
              <:body>
                <.heading_widget level={3} text="Side Image Card" />
                <p>This card has the image on the side, perfect for list views.</p>
                <div class="flex gap-2 mt-2">
                  <.badge_widget label="Design" color={:primary} size={:sm} />
                  <.badge_widget label="Development" color={:secondary} size={:sm} />
                </div>
              </:body>
              <:actions>
                <button class="btn btn-primary btn-sm">Learn More</button>
              </:actions>
            </.card_widget>
          </div>
        </.grid_widget>
      </.section_widget>
      
      <!-- Debug Mode Example -->
      <.section_widget background={:white} rounded={:lg} padding={6}>
        <.heading_widget level={2} text="Debug Mode" class="mb-4" />
        
        <.grid_widget columns={2} gap={6}>
          <.card_widget 
            title="Debug Mode Enabled" 
            debug_mode={true}
            bordered={true}
            span={6}
          >
            <p>This card shows debug information including the widget name and configuration.</p>
          </.card_widget>
          
          <.card_widget 
            title="With Grid Span"
            debug_mode={true}
            span={6}
            padding={4}
          >
            <p>This card uses the grid span attribute to take up 6 columns.</p>
          </.card_widget>
        </.grid_widget>
      </.section_widget>
    </div>
    """
  end
  
  def handle_event("card_clicked", _, socket) do
    socket = put_flash(socket, :info, "Card was clicked!")
    {:noreply, socket}
  end
end