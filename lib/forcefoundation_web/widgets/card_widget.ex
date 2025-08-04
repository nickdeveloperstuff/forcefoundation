defmodule ForcefoundationWeb.Widgets.CardWidget do
  use ForcefoundationWeb.Widgets.Base
  
  @moduledoc """
  Card container wrapping DaisyUI's card component.
  Supports multiple layouts and content slots.
  
  ## Examples
  
      <.card_widget title="Simple Card">
        Card content goes here
      </.card_widget>
      
      <.card_widget image="/images/photo.jpg" variant={:compact}>
        <:body>
          <h2 class="card-title">Card with Image</h2>
          <p>Card description</p>
        </:body>
        <:actions>
          <button class="btn btn-primary">Action</button>
        </:actions>
      </.card_widget>
  """
  
  # Card configuration
  attr :variant, :atom, default: :default,
    values: [:default, :compact, :side, :overlay],
    doc: "Card layout variant"
  attr :image, :string, default: nil,
    doc: "Image URL for card"
  attr :image_alt, :string, default: "",
    doc: "Alt text for image"
  attr :title, :string, default: nil,
    doc: "Card title (shorthand)"
  attr :bordered, :boolean, default: false,
    doc: "Add border to card (uses card-border class in DaisyUI 5)"
  attr :hoverable, :boolean, default: false,
    doc: "Add hover effect"
  attr :clickable, :boolean, default: false,
    doc: "Make entire card clickable"
  attr :on_click, :any, default: nil,
    doc: "Click handler for card"
  
  # Content slots
  slot :figure, doc: "Figure/image area (alternative to image attr)"
  slot :body, doc: "Main card content"
  slot :actions, doc: "Card action buttons"
  slot :badge, doc: "Badge overlays"
  slot :inner_block, doc: "Shorthand for body content"
  
  # Include common widget attributes
  widget_attrs()
  
  def card_widget(assigns) do
    ~H"""
    <div 
      class={[
        "card",
        "bg-base-100",
        variant_class(@variant),
        @bordered && "card-bordered",
        @hoverable && "hover:shadow-xl transition-shadow",
        @clickable && "cursor-pointer",
        widget_classes(assigns)
      ]}
      phx-click={@clickable && @on_click}
    >
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      
      <!-- Image or Figure -->
      <%= if @image || @figure do %>
        <figure class={figure_class(@variant)}>
          <%= if @figure do %>
            <%= render_slot(@figure) %>
          <% else %>
            <img src={@image} alt={@image_alt} />
          <% end %>
          
          <!-- Badges overlay on image -->
          <%= for badge <- @badge do %>
            <div class="absolute top-2 right-2">
              <%= render_slot(badge) %>
            </div>
          <% end %>
        </figure>
      <% end %>
      
      <!-- Card Body -->
      <div class="card-body">
        <!-- Title if provided as attribute -->
        <h2 :if={@title} class="card-title">
          <%= @title %>
        </h2>
        
        <!-- Body content -->
        <%= if @body do %>
          <%= render_slot(@body) %>
        <% else %>
          <%= render_slot(@inner_block) %>
        <% end %>
        
        <!-- Actions -->
        <div :if={@actions} class="card-actions justify-end">
          <%= render_slot(@actions) %>
        </div>
      </div>
    </div>
    """
  end
  
  defp variant_class(:default), do: nil
  defp variant_class(:compact), do: "card-compact"
  defp variant_class(:side), do: "card-side"
  defp variant_class(:overlay), do: "image-full"
  
  defp figure_class(:side), do: "figure-side"
  defp figure_class(_), do: nil
end