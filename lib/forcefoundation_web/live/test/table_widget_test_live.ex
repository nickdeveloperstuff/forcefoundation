defmodule ForcefoundationWeb.Test.TableWidgetTestLive do
  use ForcefoundationWeb, :live_view
  use ForcefoundationWeb.Widgets
  import ForcefoundationWeb.Widgets.Data.TableWidget
  
  @impl true
  def mount(_params, _session, socket) do
    # Generate sample data
    users = generate_sample_users()
    
    {:ok,
     socket
     |> assign(:static_users, users)
     |> assign(:selected_ids, [])
     |> assign(:last_action, nil)
     |> assign(:search_term, "")
     |> assign(:sort_by, nil)
     |> assign(:sort_direction, :asc)
     |> assign(:current_page, 1)
     |> assign(:visible_columns, [:id, :name, :email, :role, :status, :department, :salary, :joined_at, :active, :performance])}
  end
  
  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-8 space-y-12">
      <div>
        <.heading_widget level={1} text="Table Widget Test" class="mb-8" />
        
        <!-- Basic Table -->
        <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6} class="mb-8">
          <.heading_widget level={2} text="Basic Table" class="mb-4" />
          
          <.table_widget
            id="basic-table"
            columns={[
              %{field: :id, label: "ID", sortable: true},
              %{field: :name, label: "Name", sortable: true},
              %{field: :email, label: "Email", sortable: true},
              %{field: :role, label: "Role"},
              %{field: :status, label: "Status", render: &render_status_badge/2}
            ]}
            rows={@static_users}
            variant={:zebra}
            paginate={false}
          />
        </.section_widget>
        
        <!-- Advanced Table with All Features -->
        <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6} class="mb-8">
          <.heading_widget level={2} text="Advanced Table" class="mb-4" />
          
          <.table_widget
            id="advanced-table"
            columns={[
              %{field: :id, label: "ID", sortable: true, header_class: "text-center", class: "text-center"},
              %{field: :name, label: "Name", sortable: true, searchable: true},
              %{field: :email, label: "Email", sortable: true, searchable: true},
              %{field: :department, label: "Department", sortable: true, searchable: true},
              %{field: :salary, label: "Salary", format: :currency, header_class: "text-right", class: "text-right", aggregate: :sum},
              %{field: :joined_at, label: "Joined", format: :date, sortable: true},
              %{field: :active, label: "Active", render: &render_active_badge/2, header_class: "text-center", class: "text-center"},
              %{field: :performance, label: "Performance", render: &render_performance/2}
            ]}
            rows={@static_users}
            variant={:bordered}
            size={:sm}
            selectable={:multi}
            selected_rows={@selected_ids}
            searchable={true}
            search_term={@search_term}
            exportable={true}
            column_toggles={true}
            visible_columns={@visible_columns}
            show_footer={true}
            row_actions={[
              %{label: "View", icon: "hero-eye", event: "view_user"},
              %{label: "Edit", icon: "hero-pencil", event: "edit_user"},
              %{label: "Delete", icon: "hero-trash", event: "delete_user"}
            ]}
            sort_by={@sort_by}
            sort_direction={@sort_direction}
            current_page={@current_page}
          />
        </.section_widget>
        
        <!-- Compact Table -->
        <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6} class="mb-8">
          <.heading_widget level={2} text="Compact Table" class="mb-4" />
          
          <.table_widget
            id="compact-table"
            columns={[
              %{field: :name, label: "Employee"},
              %{field: :department, label: "Dept"},
              %{field: :performance, label: "Score", render: &render_score/2}
            ]}
            rows={Enum.take(@static_users, 5)}
            variant={:compact}
            size={:xs}
            paginate={false}
            empty_message="No employees found"
          />
        </.section_widget>
        
        <!-- Empty State Table -->
        <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6} class="mb-8">
          <.heading_widget level={2} text="Empty State" class="mb-4" />
          
          <.table_widget
            id="empty-table"
            columns={[
              %{field: :name, label: "Name"},
              %{field: :email, label: "Email"},
              %{field: :role, label: "Role"}
            ]}
            rows={[]}
            empty_message="No data available. Try adding some records."
          />
        </.section_widget>
        
        <!-- Loading State Table -->
        <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6} class="mb-8">
          <.heading_widget level={2} text="Loading State" class="mb-4" />
          
          <.table_widget
            id="loading-table"
            columns={[
              %{field: :name, label: "Name"},
              %{field: :email, label: "Email"}
            ]}
            rows={[]}
            loading={true}
          />
        </.section_widget>
        
        <!-- Status Display -->
        <.section_widget background={:gray} rounded={:lg} padding={4}>
          <.heading_widget level={3} text="Last Action" class="mb-2" />
          <%= if @last_action do %>
            <pre class="text-sm font-mono"><%= inspect(@last_action, pretty: true) %></pre>
          <% else %>
            <.text_widget text="No action performed yet" class="text-sm opacity-70" />
          <% end %>
        </.section_widget>
      </div>
    </div>
    """
  end
  
  @impl true
  def handle_event("sort", %{"field" => field}, socket) do
    field_atom = String.to_existing_atom(field)
    
    {sort_by, sort_direction} = 
      if socket.assigns.sort_by == field_atom do
        {field_atom, toggle_direction(socket.assigns.sort_direction)}
      else
        {field_atom, :asc}
      end
    
    {:noreply, 
     socket
     |> assign(:sort_by, sort_by)
     |> assign(:sort_direction, sort_direction)
     |> assign(:last_action, %{action: "sort", field: field, direction: sort_direction})}
  end
  
  def handle_event("search", %{"value" => term}, socket) do
    {:noreply, 
     socket
     |> assign(:search_term, term)
     |> assign(:last_action, %{action: "search", term: term})}
  end
  
  def handle_event("page", %{"page" => page}, socket) do
    page = String.to_integer(page)
    {:noreply, 
     socket
     |> assign(:current_page, page)
     |> assign(:last_action, %{action: "page", page: page})}
  end
  
  def handle_event("toggle_row", %{"id" => id}, socket) do
    id = String.to_integer(id)
    selected = 
      if id in socket.assigns.selected_ids do
        List.delete(socket.assigns.selected_ids, id)
      else
        [id | socket.assigns.selected_ids]
      end
    
    {:noreply, 
     socket
     |> assign(:selected_ids, selected)
     |> assign(:last_action, %{action: "toggle_row", id: id})}
  end
  
  def handle_event("toggle_all", _params, socket) do
    selected = 
      if length(socket.assigns.selected_ids) == length(socket.assigns.static_users) do
        []
      else
        Enum.map(socket.assigns.static_users, & &1.id)
      end
    
    {:noreply, 
     socket
     |> assign(:selected_ids, selected)
     |> assign(:last_action, %{action: "toggle_all"})}
  end
  
  def handle_event("clear_selection", _params, socket) do
    {:noreply, 
     socket
     |> assign(:selected_ids, [])
     |> assign(:last_action, %{action: "clear_selection"})}
  end
  
  def handle_event("toggle_column", %{"field" => field}, socket) do
    field_atom = String.to_existing_atom(field)
    visible = 
      if field_atom in socket.assigns.visible_columns do
        List.delete(socket.assigns.visible_columns, field_atom)
      else
        socket.assigns.visible_columns ++ [field_atom]
      end
    
    {:noreply, 
     socket
     |> assign(:visible_columns, visible)
     |> assign(:last_action, %{action: "toggle_column", field: field})}
  end
  
  def handle_event("export", _params, socket) do
    # In a real app, this would trigger CSV download
    {:noreply, assign(socket, :last_action, %{action: "export"})}
  end
  
  def handle_event("view_user", %{"id" => id}, socket) do
    {:noreply, assign(socket, :last_action, %{action: "view", id: id})}
  end
  
  def handle_event("edit_user", %{"id" => id}, socket) do
    {:noreply, assign(socket, :last_action, %{action: "edit", id: id})}
  end
  
  def handle_event("delete_user", %{"id" => id}, socket) do
    {:noreply, assign(socket, :last_action, %{action: "delete", id: id})}
  end
  
  defp toggle_direction(:asc), do: :desc
  defp toggle_direction(:desc), do: :asc
  
  defp generate_sample_users do
    departments = ["Engineering", "Sales", "Marketing", "HR", "Finance"]
    
    for i <- 1..50 do
      %{
        id: i,
        name: "User #{i}",
        email: "user#{i}@example.com",
        role: Enum.random(["Admin", "Manager", "Employee"]),
        department: Enum.random(departments),
        salary: Enum.random(40000..120000),
        joined_at: Date.add(Date.utc_today(), -Enum.random(1..1000)),
        active: Enum.random([true, false]),
        status: Enum.random(["online", "offline", "away"]),
        performance: Enum.random(40..100)
      }
    end
  end
  
  defp render_status_badge(status, _row) do
    color = 
      case status do
        "online" -> "badge-success"
        "away" -> "badge-warning"
        "offline" -> "badge-ghost"
        _ -> ""
      end
      
    assigns = %{status: status, color: color}
    
    ~H"""
    <span class={"badge badge-sm #{@color}"}><%= @status %></span>
    """
  end
  
  defp render_active_badge(active, _row) do
    assigns = %{active: active}
    
    ~H"""
    <%= if @active do %>
      <span class="badge badge-success badge-sm">Active</span>
    <% else %>
      <span class="badge badge-ghost badge-sm">Inactive</span>
    <% end %>
    """
  end
  
  defp render_performance(value, _row) do
    color = 
      cond do
        value >= 80 -> "text-success"
        value >= 60 -> "text-warning"
        true -> "text-error"
      end
      
    assigns = %{value: value, color: color}
    
    ~H"""
    <span class={@color}>
      <%= @value %>%
    </span>
    """
  end
  
  defp render_score(value, _row) do
    "#{value}%"
  end
end