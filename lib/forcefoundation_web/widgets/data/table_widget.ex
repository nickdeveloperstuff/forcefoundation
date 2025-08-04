defmodule ForcefoundationWeb.Widgets.Data.TableWidget do
  @moduledoc """
  Table widget with support for:
  - Static and live data modes
  - Sortable columns
  - Pagination
  - Row selection (single/multi)
  - Inline row actions
  - Column visibility toggles
  - Responsive design
  - CSV export
  """
  use ForcefoundationWeb.Widgets.Base
  use ForcefoundationWeb.Widgets.Connectable
  
  import Phoenix.Component
  import ForcefoundationWeb.CoreComponents, only: [icon: 1]
  
  # Widget attributes
  defmacro widget_attrs() do
    quote do
      attr :id, :string, default: nil
      attr :class, :string, default: ""
      attr :variant, :atom, default: :default, values: [:default, :zebra, :bordered, :compact]
      attr :size, :atom, default: :md, values: [:xs, :sm, :md, :lg]
      attr :data_source, :any, default: :static
      attr :debug_mode, :boolean, default: false
      
      # Table specific attributes
      attr :rows, :list, default: []
      attr :columns, :list, required: true
      attr :selectable, :atom, default: false, values: [false, :single, :multi]
      attr :selected_rows, :list, default: []
      attr :sortable, :boolean, default: true
      attr :sort_by, :atom, default: nil
      attr :sort_direction, :atom, default: :asc
      attr :searchable, :boolean, default: false
      attr :search_term, :string, default: ""
      attr :paginate, :boolean, default: true
      attr :page_size, :integer, default: 10
      attr :current_page, :integer, default: 1
      attr :total_count, :integer, default: nil
      attr :exportable, :boolean, default: false
      attr :column_toggles, :boolean, default: false
      attr :visible_columns, :list, default: []
      attr :row_actions, :list, default: []
      attr :show_footer, :boolean, default: false
      attr :empty_message, :string, default: "No data available"
      attr :row_id_field, :atom, default: :id
      attr :loading, :boolean, default: false
    end
  end
  
  widget_attrs()
  
  def table_widget(assigns) do
    assigns = 
      assigns
      |> assign_defaults()
      |> prepare_data()
      |> calculate_pagination()
      
    ~H"""
    <div class={["table-widget", @class]} id={@id} phx-hook="TableWidget">
      <!-- Controls Bar -->
      <div class="flex justify-between items-center mb-4">
        <div class="flex gap-2 items-center">
          <%= if @selectable do %>
            <span class="text-sm opacity-70">
              <%= length(@selected_rows) %> selected
            </span>
            <%= if length(@selected_rows) > 0 do %>
              <button class="btn btn-ghost btn-xs" phx-click="clear_selection" phx-target={@id}>
                Clear
              </button>
            <% end %>
          <% end %>
        </div>
        
        <div class="flex gap-2">
          <%= if @searchable do %>
            <input
              type="text"
              class="input input-bordered input-sm w-64"
              placeholder="Search..."
              phx-change="search"
              phx-target={@id}
              value={@search_term}
            />
          <% end %>
          
          <%= if @exportable do %>
            <button class="btn btn-ghost btn-sm" phx-click="export" phx-target={@id}>
              <.icon name="hero-arrow-down-tray" class="w-4 h-4" />
              Export
            </button>
          <% end %>
          
          <%= if @column_toggles do %>
            <div class="dropdown dropdown-end">
              <label tabindex="0" class="btn btn-ghost btn-sm">
                <.icon name="hero-view-columns" class="w-4 h-4" />
                Columns
              </label>
              <ul tabindex="0" class="dropdown-content menu p-2 shadow bg-base-100 rounded-box w-52">
                <%= for column <- @columns do %>
                  <li>
                    <label class="label cursor-pointer">
                      <span class="label-text"><%= column.label %></span>
                      <input
                        type="checkbox"
                        class="checkbox checkbox-sm"
                        checked={column_visible?(column, assigns)}
                        phx-click="toggle_column"
                        phx-value-field={column.field}
                        phx-target={@id}
                      />
                    </label>
                  </li>
                <% end %>
              </ul>
            </div>
          <% end %>
        </div>
      </div>
      
      <!-- Table -->
      <div class="overflow-x-auto">
        <table class={table_class(@variant, @size)}>
          <thead>
            <tr>
              <%= if @selectable do %>
                <th class="w-10">
                  <%= if @selectable == :multi do %>
                    <input
                      type="checkbox"
                      class="checkbox checkbox-sm"
                      checked={all_selected?(assigns)}
                      phx-click="toggle_all"
                      phx-target={@id}
                    />
                  <% end %>
                </th>
              <% end %>
              
              <%= for column <- visible_columns(assigns) do %>
                <th class={column_header_class(column)}>
                  <%= if Map.get(column, :sortable, true) and @sortable do %>
                    <button
                      class="flex items-center gap-1 hover:opacity-80"
                      phx-click="sort"
                      phx-value-field={column.field}
                      phx-target={@id}
                    >
                      <%= column.label %>
                      <%= render_sort_icon(column.field, assigns) %>
                    </button>
                  <% else %>
                    <%= column.label %>
                  <% end %>
                </th>
              <% end %>
              
              <%= if @row_actions != [] do %>
                <th class="w-20">Actions</th>
              <% end %>
            </tr>
          </thead>
          
          <tbody>
            <%= if @loading do %>
              <tr>
                <td colspan={colspan(assigns)} class="text-center py-8">
                  <span class="loading loading-spinner loading-md"></span>
                  <p class="mt-2 text-sm opacity-70">Loading data...</p>
                </td>
              </tr>
            <% else %>
              <%= if @rows == [] do %>
                <tr>
                  <td colspan={colspan(assigns)} class="text-center py-8 opacity-50">
                    <%= @empty_message %>
                  </td>
                </tr>
              <% else %>
                <%= for {row, index} <- Enum.with_index(@rows) do %>
                  <tr class={row_class(row, index, assigns)}>
                    <%= if @selectable do %>
                      <td>
                        <input
                          type={if @selectable == :single, do: "radio", else: "checkbox"}
                          name={if @selectable == :single, do: "#{@id}-selection"}
                          class="checkbox checkbox-sm"
                          checked={row_selected?(row, assigns)}
                          phx-click="toggle_row"
                          phx-value-id={get_row_id(row, assigns)}
                          phx-target={@id}
                        />
                      </td>
                    <% end %>
                    
                    <%= for column <- visible_columns(assigns) do %>
                      <td class={column_class(column)}>
                        <%= render_cell(row, column, assigns) %>
                      </td>
                    <% end %>
                    
                    <%= if @row_actions != [] do %>
                      <td>
                        <%= render_row_actions(row, assigns) %>
                      </td>
                    <% end %>
                  </tr>
                <% end %>
              <% end %>
            <% end %>
          </tbody>
          
          <%= if @show_footer do %>
            <tfoot>
              <tr>
                <%= if @selectable do %>
                  <td></td>
                <% end %>
                
                <%= for column <- visible_columns(assigns) do %>
                  <td class="font-semibold">
                    <%= render_footer_cell(column, assigns) %>
                  </td>
                <% end %>
                
                <%= if @row_actions != [] do %>
                  <td></td>
                <% end %>
              </tr>
            </tfoot>
          <% end %>
        </table>
      </div>
      
      <!-- Pagination -->
      <%= if @paginate and total_pages(assigns) > 1 do %>
        <div class="flex justify-between items-center mt-4">
          <div class="text-sm opacity-70">
            Showing <%= page_start(assigns) %> to <%= page_end(assigns) %> of <%= @total_count || length(@rows) %> entries
          </div>
          
          <div class="join">
            <button
              class="join-item btn btn-sm"
              disabled={@current_page == 1}
              phx-click="page"
              phx-value-page={@current_page - 1}
              phx-target={@id}
            >
              «
            </button>
            
            <%= for page <- pagination_links(assigns) do %>
              <%= if page == "..." do %>
                <button class="join-item btn btn-sm btn-disabled">...</button>
              <% else %>
                <button
                  class={["join-item btn btn-sm", page == @current_page && "btn-active"]}
                  phx-click="page"
                  phx-value-page={page}
                  phx-target={@id}
                >
                  <%= page %>
                </button>
              <% end %>
            <% end %>
            
            <button
              class="join-item btn btn-sm"
              disabled={@current_page == total_pages(assigns)}
              phx-click="page"
              phx-value-page={@current_page + 1}
              phx-target={@id}
            >
              »
            </button>
          </div>
        </div>
      <% end %>
      
      <%= if @debug_mode do %>
        <div class="mt-4 p-4 bg-base-200 rounded text-xs">
          <strong>Table Debug:</strong>
          <pre><%= inspect(%{
            total_rows: length(@rows),
            current_page: @current_page,
            page_size: @page_size,
            sort_by: @sort_by,
            sort_direction: @sort_direction,
            selected_count: length(@selected_rows)
          }, pretty: true) %></pre>
        </div>
      <% end %>
    </div>
    """
  end
  
  # Helper functions
  defp assign_defaults(assigns) do
    assigns
    |> assign_new(:id, fn -> "table-#{System.unique_integer([:positive])}" end)
    |> assign_new(:class, fn -> "" end)
    |> assign_new(:variant, fn -> :default end)
    |> assign_new(:size, fn -> :md end)
    |> assign_new(:data_source, fn -> :static end)
    |> assign_new(:debug_mode, fn -> false end)
    |> assign_new(:rows, fn -> [] end)
    |> assign_new(:selectable, fn -> false end)
    |> assign_new(:selected_rows, fn -> [] end)
    |> assign_new(:sortable, fn -> true end)
    |> assign_new(:sort_by, fn -> nil end)
    |> assign_new(:sort_direction, fn -> :asc end)
    |> assign_new(:searchable, fn -> false end)
    |> assign_new(:search_term, fn -> "" end)
    |> assign_new(:paginate, fn -> true end)
    |> assign_new(:page_size, fn -> 10 end)
    |> assign_new(:current_page, fn -> 1 end)
    |> assign_new(:exportable, fn -> false end)
    |> assign_new(:column_toggles, fn -> false end)
    |> assign_new(:row_actions, fn -> [] end)
    |> assign_new(:show_footer, fn -> false end)
    |> assign_new(:empty_message, fn -> "No data available" end)
    |> assign_new(:row_id_field, fn -> :id end)
    |> assign_new(:loading, fn -> false end)
    |> assign_new(:visible_columns, fn -> 
      Enum.map(assigns.columns || [], & &1.field) 
    end)
    |> assign_new(:total_count, fn -> 
      length(assigns.rows || []) 
    end)
  end
  
  defp prepare_data(assigns) do
    # This will be handled by Connectable mixin
    assigns
  end
  
  defp calculate_pagination(assigns) do
    total_count = assigns.total_count || length(assigns.rows)
    page_size = Map.get(assigns, :page_size, 10)
    total_pages = div(total_count + page_size - 1, page_size)
    
    rows = 
      assigns.rows
      |> apply_search(assigns)
      |> apply_sort(assigns)
      |> apply_pagination(assigns)
    
    assigns
    |> assign(:rows, rows)
    |> assign(:total_pages, total_pages)
  end
  
  defp apply_search(rows, %{searchable: true, search_term: term} = assigns) when term != "" do
    searchable_fields = 
      assigns.columns
      |> Enum.filter(& Map.get(&1, :searchable, true))
      |> Enum.map(& &1.field)
    
    Enum.filter(rows, fn row ->
      Enum.any?(searchable_fields, fn field ->
        value = Map.get(row, field)
        String.contains?(to_string(value), term)
      end)
    end)
  end
  defp apply_search(rows, _), do: rows
  
  defp apply_sort(rows, %{sort_by: nil}), do: rows
  defp apply_sort(rows, %{sort_by: field, sort_direction: direction}) do
    Enum.sort_by(rows, & Map.get(&1, field), direction)
  end
  
  defp apply_pagination(rows, %{paginate: false}), do: rows
  defp apply_pagination(rows, assigns) do
    page = Map.get(assigns, :current_page, 1)
    size = Map.get(assigns, :page_size, 10)
    rows
    |> Enum.drop((page - 1) * size)
    |> Enum.take(size)
  end
  
  defp table_class(variant, size) do
    base = "table w-full"
    variant_class = case variant do
      :zebra -> "table-zebra"
      :bordered -> "table-bordered"
      :compact -> "table-compact"
      _ -> ""
    end
    
    size_class = case size do
      :xs -> "table-xs"
      :sm -> "table-sm"
      :lg -> "table-lg"
      _ -> ""
    end
    
    [base, variant_class, size_class]
    |> Enum.filter(& &1 != "")
    |> Enum.join(" ")
  end
  
  defp visible_columns(assigns) do
    if assigns.column_toggles do
      Enum.filter(assigns.columns, & column_visible?(&1, assigns))
    else
      assigns.columns
    end
  end
  
  defp column_visible?(column, assigns) do
    column.field in assigns.visible_columns
  end
  
  defp column_header_class(column) do
    Map.get(column, :header_class, "")
  end
  
  defp column_class(column) do
    Map.get(column, :class, "")
  end
  
  defp row_class(_row, index, assigns) do
    classes = []
    
    if assigns.variant == :zebra and rem(index, 2) == 1 do
      ["hover:bg-base-200" | classes]
    else
      classes
    end
    |> Enum.join(" ")
  end
  
  defp render_sort_icon(field, assigns) do
    if assigns.sort_by == field do
      if assigns.sort_direction == :asc do
        ~H"""
        <.icon name="hero-chevron-up" class="w-4 h-4" />
        """
      else
        ~H"""
        <.icon name="hero-chevron-down" class="w-4 h-4" />
        """
      end
    else
      ~H"""
      <.icon name="hero-chevron-up-down" class="w-4 h-4 opacity-50" />
      """
    end
  end
  
  defp render_cell(row, column, _assigns) do
    value = Map.get(row, column.field)
    
    cond do
      render_fn = Map.get(column, :render) ->
        render_fn.(value, row)
      format = Map.get(column, :format) ->
        format_value(value, format)
      true ->
        to_string(value)
    end
  end
  
  defp format_value(value, :date) do
    case value do
      %Date{} = date -> Calendar.strftime(date, "%Y-%m-%d")
      _ -> to_string(value)
    end
  end
  defp format_value(value, :datetime) do
    case value do
      %DateTime{} = dt -> Calendar.strftime(dt, "%Y-%m-%d %H:%M:%S")
      _ -> to_string(value)
    end
  end
  defp format_value(value, :currency) do
    "$#{:erlang.float_to_binary(value / 1.0, decimals: 2)}"
  end
  defp format_value(value, :percentage) do
    "#{value}%"
  end
  defp format_value(value, _), do: to_string(value)
  
  defp render_footer_cell(column, assigns) do
    if aggregate = Map.get(column, :aggregate) do
      values = Enum.map(assigns.rows, & Map.get(&1, column.field))
      
      case aggregate do
        :sum -> Enum.sum(values)
        :avg -> Enum.sum(values) / length(values)
        :count -> length(values)
        :min -> Enum.min(values)
        :max -> Enum.max(values)
        _ -> ""
      end
      |> format_value(Map.get(column, :format))
    else
      ""
    end
  end
  
  defp render_row_actions(row, assigns) do
    assigns = assign(assigns, :row, row)
    
    ~H"""
    <div class="dropdown dropdown-end">
      <label tabindex="0" class="btn btn-ghost btn-sm btn-square">
        <.icon name="hero-ellipsis-vertical" class="w-4 h-4" />
      </label>
      <ul tabindex="0" class="dropdown-content menu p-2 shadow bg-base-100 rounded-box w-52">
        <%= for action <- @row_actions do %>
          <li>
            <a
              phx-click={action.event}
              phx-value-id={get_row_id(@row, assigns)}
              phx-target={assigns.id}
            >
              <%= if Map.get(action, :icon) do %>
                <.icon name={action.icon} class="w-4 h-4" />
              <% end %>
              <%= action.label %>
            </a>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
  
  defp get_row_id(row, assigns) do
    Map.get(row, assigns.row_id_field, Map.get(row, :id))
  end
  
  defp all_selected?(assigns) do
    assigns.selectable == :multi and
    length(assigns.selected_rows) > 0 and
    length(assigns.selected_rows) == length(assigns.rows)
  end
  
  defp row_selected?(row, assigns) do
    get_row_id(row, assigns) in assigns.selected_rows
  end
  
  defp colspan(assigns) do
    col_count = length(visible_columns(assigns))
    col_count = if assigns.selectable, do: col_count + 1, else: col_count
    if assigns.row_actions != [], do: col_count + 1, else: col_count
  end
  
  defp total_pages(assigns) do
    total_count = assigns.total_count || length(assigns.rows)
    page_size = Map.get(assigns, :page_size, 10)
    div(total_count + page_size - 1, page_size)
  end
  
  defp page_start(assigns) do
    page = Map.get(assigns, :current_page, 1)
    size = Map.get(assigns, :page_size, 10)
    (page - 1) * size + 1
  end
  
  defp page_end(assigns) do
    total_count = assigns.total_count || length(assigns.rows)
    page = Map.get(assigns, :current_page, 1)
    size = Map.get(assigns, :page_size, 10)
    min(page * size, total_count)
  end
  
  defp pagination_links(assigns) do
    total = total_pages(assigns)
    current = Map.get(assigns, :current_page, 1)
    
    cond do
      total <= 7 ->
        1..total |> Enum.to_list()
      current <= 4 ->
        [1, 2, 3, 4, 5, "...", total]
      current >= total - 3 ->
        [1, "..."] ++ Enum.to_list((total - 4)..total)
      true ->
        [1, "...", current - 1, current, current + 1, "...", total]
    end
  end
end