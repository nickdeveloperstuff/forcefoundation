defmodule ForcefoundationWeb.Widgets.SectionWidget do
  use ForcefoundationWeb.Widgets.Base
  
  @moduledoc """
  Section container with consistent spacing and optional styling.
  Use for grouping related content with proper spacing.
  """
  
  attr :background, :atom, default: :transparent,
    values: [:transparent, :white, :gray, :primary, :gradient],
    doc: "Background style"
  attr :rounded, :atom, default: :none,
    values: [:none, :sm, :md, :lg, :xl, :full],
    doc: "Border radius"
  attr :shadow, :atom, default: :none,
    values: [:none, :sm, :md, :lg, :xl],
    doc: "Box shadow"
  attr :border, :boolean, default: false,
    doc: "Show border"
  attr :container, :boolean, default: false,
    doc: "Constrain width with container"
  attr :full_width, :boolean, default: false,
    doc: "Take full width"
  attr :full_height, :boolean, default: false,
    doc: "Take full height"
    
  slot :header do
    attr :sticky, :boolean
  end
  slot :inner_block, required: true
  slot :footer
  
  # Include common widget attributes
  widget_attrs()
  
  def section_widget(assigns) do
    ~H"""
    <section class={[
      background_class(@background),
      rounded_class(@rounded),
      shadow_class(@shadow),
      @border && "border border-gray-200",
      @container && "container mx-auto",
      @full_width && "w-full",
      @full_height && "h-full",
      widget_classes(assigns)
    ]}>
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      
      <div :if={@header} class={[
        "section-header",
        @header[:sticky] && "sticky top-0 z-10 bg-inherit"
      ]}>
        <%= render_slot(@header) %>
      </div>
      
      <div class="section-body">
        <%= render_slot(@inner_block) %>
      </div>
      
      <div :if={@footer} class="section-footer">
        <%= render_slot(@footer) %>
      </div>
    </section>
    """
  end
  
  defp background_class(:transparent), do: "bg-transparent"
  defp background_class(:white), do: "bg-white"
  defp background_class(:gray), do: "bg-gray-50"
  defp background_class(:primary), do: "bg-primary-50"
  defp background_class(:gradient), do: "bg-gradient-to-br from-primary-50 to-secondary-50"
  
  defp rounded_class(:none), do: nil
  defp rounded_class(:sm), do: "rounded-sm"
  defp rounded_class(:md), do: "rounded-md"
  defp rounded_class(:lg), do: "rounded-lg"
  defp rounded_class(:xl), do: "rounded-xl"
  defp rounded_class(:full), do: "rounded-full"
  
  defp shadow_class(:none), do: nil
  defp shadow_class(:sm), do: "shadow-sm"
  defp shadow_class(:md), do: "shadow-md"
  defp shadow_class(:lg), do: "shadow-lg"
  defp shadow_class(:xl), do: "shadow-xl"
end