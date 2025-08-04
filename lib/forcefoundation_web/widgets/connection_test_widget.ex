defmodule ForcefoundationWeb.Widgets.ConnectionTestWidget do
  use ForcefoundationWeb.Widgets.Base
  use ForcefoundationWeb.Widgets.Connectable
  
  @moduledoc """
  Widget for testing the connection resolution system.
  Displays the resolved data in a formatted way.
  """
  
  # Include common widget attributes
  widget_attrs()
  
  # Add data attribute that gets populated by Connectable
  attr :data, :any, default: nil
  
  def connection_test_widget(assigns) do
    ~H"""
    <div class={[
      "card bg-base-200",
      widget_classes(assigns)
    ]}>
      <%= Phoenix.HTML.raw(render_debug(assigns)) %>
      
      <div class="card-body">
        <%= if @loading do %>
          <div class="flex items-center space-x-2">
            <span class="loading loading-spinner loading-sm"></span>
            <span>Loading data...</span>
          </div>
        <% else %>
          <%= if @error do %>
            <div class="alert alert-error">
              <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
              <span>Error: {@error}</span>
            </div>
          <% else %>
            <div class="space-y-2">
              <h3 class="font-semibold">Connection Type: <%= connection_type(@data_source) %></h3>
              
              <div class="bg-base-300 p-4 rounded-lg">
                <h4 class="font-semibold mb-2">Resolved Data:</h4>
                <pre class="text-sm overflow-auto"><%= format_data(@data) %></pre>
              </div>
              
              <%= if @data_source != :static do %>
                <div class="text-sm text-base-content/70">
                  Source: <%= inspect(@data_source) %>
                </div>
              <% end %>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end
  
  defp connection_type(:static), do: "Static (Dumb Mode)"
  defp connection_type({:interface, _}), do: "Interface Query"
  defp connection_type({:resource, _, _}), do: "Single Resource"
  defp connection_type({:stream, _}), do: "PubSub Stream"
  defp connection_type({:form, _}), do: "Form Changeset"
  defp connection_type({:action, _, _, _}), do: "Domain Action"
  defp connection_type({:subscribe, _, _}), do: "Filtered Subscription"
  defp connection_type(_), do: "Unknown"
  
  defp format_data(nil), do: "No data (nil)"
  defp format_data(data) when is_list(data) do
    "[\n" <> Enum.map_join(data, "\n", &("  " <> inspect(&1))) <> "\n]"
  end
  defp format_data(data), do: inspect(data, pretty: true)
end