defmodule ForcefoundationWeb.StreamTableTestLive do
  use ForcefoundationWeb, :live_view
  import ForcefoundationWeb.Widgets
  import ForcefoundationWeb.CoreComponents
  
  @impl true
  def mount(_params, _session, socket) do
    # Initialize with some users
    users = generate_initial_users()
    
    socket =
      socket
      |> assign(:selected_rows, [])
      |> assign(:next_id, 11)
      |> assign(:update_log, [])
      |> stream(:users, users)
      |> stream(:activity_log, [])
    
    # Simulate real-time updates
    if connected?(socket) do
      :timer.send_interval(5000, self(), :random_update)
    end
    
    {:ok, socket}
  end
  
  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-8 max-w-7xl">
      <h1 class="text-3xl font-bold mb-8">Stream Table Test Page</h1>
      
      <!-- Controls -->
      <div class="mb-8 space-y-4">
        <div class="flex gap-4">
          <button class="btn btn-primary" phx-click="add_user">
            <.icon name="hero-plus" class="w-4 h-4 mr-2" />
            Add User
          </button>
          
          <button class="btn btn-secondary" phx-click="bulk_add">
            <.icon name="hero-user-group" class="w-4 h-4 mr-2" />
            Add 5 Users
          </button>
          
          <button class="btn btn-accent" phx-click="simulate_activity">
            <.icon name="hero-bolt" class="w-4 h-4 mr-2" />
            Simulate Activity
          </button>
          
          <button class="btn btn-ghost" phx-click="clear_all">
            <.icon name="hero-trash" class="w-4 h-4 mr-2" />
            Clear All
          </button>
        </div>
      </div>
      
      <!-- Main Stream Table -->
      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-4">Users Table (Phoenix Streams)</h2>
        
        <div class="overflow-x-auto">
          <table class="table table-zebra w-full">
            <thead>
              <tr>
                <th class="w-12">
                  <input
                    type="checkbox"
                    class="checkbox checkbox-sm"
                    phx-click="toggle_all"
                  />
                </th>
                <th class="w-20">ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Status</th>
                <th>Last Login</th>
                <th class="text-right">Actions</th>
              </tr>
            </thead>
            
            <tbody id="users-tbody" phx-update="stream">
              <%= for {dom_id, user} <- @streams.users do %>
                <tr id={dom_id} class={[
                  dom_id in @selected_rows && "active",
                  "transition-colors duration-200"
                ]}>
                  <td>
                    <input
                      type="checkbox"
                      class="checkbox checkbox-sm"
                      checked={dom_id in @selected_rows}
                      phx-click="toggle_row"
                      phx-value-dom-id={dom_id}
                    />
                  </td>
                  <td><%= user.id %></td>
                  <td><%= user.name %></td>
                  <td><%= user.email %></td>
                  <td>
                    <%= render_status_badge(user.status) %>
                  </td>
                  <td><%= format_datetime(user.last_login) %></td>
                  <td class="text-right">
                    <div class="dropdown dropdown-end">
                      <label tabindex="0" class="btn btn-ghost btn-sm btn-square">
                        <.icon name="hero-ellipsis-vertical" class="w-4 h-4" />
                      </label>
                      <ul tabindex="0" class="dropdown-content menu p-2 shadow bg-base-100 rounded-box w-52">
                        <li>
                          <a phx-click="edit_user" phx-value-dom-id={dom_id}>
                            <.icon name="hero-pencil" class="w-4 h-4" />
                            Edit
                          </a>
                        </li>
                        <li>
                          <a phx-click="view_user" phx-value-dom-id={dom_id}>
                            <.icon name="hero-eye" class="w-4 h-4" />
                            View Details
                          </a>
                        </li>
                        <li><hr class="my-1" /></li>
                        <li>
                          <a phx-click="delete_user" phx-value-dom-id={dom_id} class="text-error">
                            <.icon name="hero-trash" class="w-4 h-4" />
                            Delete
                          </a>
                        </li>
                      </ul>
                    </div>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
          
          <%= if @streams.users == [] do %>
            <div class="text-center py-8 opacity-50">
              No users available. Click "Add User" to add some.
            </div>
          <% end %>
        </div>
        
        <!-- Selected Actions -->
        <%= if length(@selected_rows) > 0 do %>
          <div class="alert alert-info mt-4">
            <div class="flex justify-between items-center">
              <span>
                <%= length(@selected_rows) %> user(s) selected
              </span>
              <div class="flex gap-2">
                <button class="btn btn-sm btn-success" phx-click="bulk_activate">
                  <.icon name="hero-check-circle" class="w-4 h-4" />
                  Activate
                </button>
                <button class="btn btn-sm btn-warning" phx-click="bulk_deactivate">
                  <.icon name="hero-x-circle" class="w-4 h-4" />
                  Deactivate
                </button>
                <button class="btn btn-sm btn-error" phx-click="bulk_delete">
                  <.icon name="hero-trash" class="w-4 h-4" />
                  Delete
                </button>
                <button class="btn btn-sm btn-ghost" phx-click="clear_selection">
                  Clear
                </button>
              </div>
            </div>
          </div>
        <% end %>
      </div>
      
      <!-- Activity Log -->
      <div>
        <h2 class="text-xl font-semibold mb-4">Activity Log (Real-time Stream)</h2>
        <div class="bg-base-200 rounded-lg p-4 max-h-64 overflow-y-auto">
          <div id="activity-log" phx-update="stream">
            <%= for {dom_id, log_entry} <- @streams.activity_log do %>
              <div id={dom_id} class="py-2 border-b border-base-300 last:border-0">
                <span class="text-sm opacity-70"><%= log_entry.timestamp %></span>
                <span class="ml-2"><%= log_entry.message %></span>
              </div>
            <% end %>
          </div>
          <%= if @streams.activity_log == [] do %>
            <p class="text-center opacity-50">No activity yet...</p>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
  
  # Event Handlers
  @impl true
  def handle_event("add_user", _, socket) do
    new_user = generate_user(socket.assigns.next_id)
    
    socket =
      socket
      |> stream_insert(:users, new_user)
      |> update(:next_id, &(&1 + 1))
      |> add_log_entry("Added user: #{new_user.name}")
    
    {:noreply, socket}
  end
  
  @impl true
  def handle_event("bulk_add", _, socket) do
    users = for i <- 0..4 do
      generate_user(socket.assigns.next_id + i)
    end
    
    socket = 
      Enum.reduce(users, socket, fn user, acc ->
        stream_insert(acc, :users, user)
      end)
      |> update(:next_id, &(&1 + 5))
      |> add_log_entry("Added 5 users in bulk")
    
    {:noreply, socket}
  end
  
  @impl true
  def handle_event("simulate_activity", _, socket) do
    # Get list of current user dom_ids  
    user_ids = get_stream_ids(socket, :users)
    
    if length(user_ids) > 0 do
      {dom_id, user} = Enum.random(user_ids)
      updated_user = %{user | status: Enum.random(["active", "inactive", "pending"])}
      
      socket =
        socket
        |> stream_insert(:users, updated_user, at: -1)
        |> add_log_entry("Status changed for #{user.name}")
      
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end
  
  @impl true
  def handle_event("clear_all", _, socket) do
    socket =
      socket
      |> stream(:users, [], reset: true)
      |> assign(:selected_rows, [])
      |> add_log_entry("Cleared all users")
    
    {:noreply, socket}
  end
  
  @impl true
  def handle_event("edit_user", %{"dom-id" => dom_id}, socket) do
    if user = find_stream_item(socket, :users, dom_id) do
      socket = add_log_entry(socket, "Edit action for #{user.name}")
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end
  
  @impl true
  def handle_event("view_user", %{"dom-id" => dom_id}, socket) do
    if user = find_stream_item(socket, :users, dom_id) do
      socket = add_log_entry(socket, "View details for #{user.name}")
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end
  
  @impl true
  def handle_event("delete_user", %{"dom-id" => dom_id}, socket) do
    if user = find_stream_item(socket, :users, dom_id) do
      socket =
        socket
        |> stream_delete_by_dom_id(:users, dom_id)
        |> update(:selected_rows, &List.delete(&1, dom_id))
        |> add_log_entry("Deleted user: #{user.name}")
      
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end
  
  @impl true
  def handle_event("toggle_row", %{"dom-id" => dom_id}, socket) do
    selected = 
      if dom_id in socket.assigns.selected_rows do
        List.delete(socket.assigns.selected_rows, dom_id)
      else
        [dom_id | socket.assigns.selected_rows]
      end
    
    {:noreply, assign(socket, :selected_rows, selected)}
  end
  
  @impl true
  def handle_event("toggle_all", _, socket) do
    all_ids = get_stream_dom_ids(socket, :users)
    
    selected = 
      if length(socket.assigns.selected_rows) == length(all_ids) do
        []
      else
        all_ids
      end
    
    {:noreply, assign(socket, :selected_rows, selected)}
  end
  
  @impl true
  def handle_event("clear_selection", _, socket) do
    {:noreply, assign(socket, :selected_rows, [])}
  end
  
  @impl true
  def handle_event("bulk_activate", _, socket) do
    socket = update_selected_users(socket, "active")
    {:noreply, socket}
  end
  
  @impl true
  def handle_event("bulk_deactivate", _, socket) do
    socket = update_selected_users(socket, "inactive")
    {:noreply, socket}
  end
  
  @impl true
  def handle_event("bulk_delete", _, socket) do
    selected_users = 
      socket.assigns.selected_rows
      |> Enum.map(&find_stream_item(socket, :users, &1))
      |> Enum.filter(& &1)
    
    socket = 
      Enum.reduce(socket.assigns.selected_rows, socket, fn dom_id, acc ->
        stream_delete_by_dom_id(acc, :users, dom_id)
      end)
      |> assign(:selected_rows, [])
      |> add_log_entry("Deleted #{length(selected_users)} users")
    
    {:noreply, socket}
  end
  
  # Timer handler for simulated updates
  @impl true
  def handle_info(:random_update, socket) do
    user_ids = get_stream_ids(socket, :users)
    
    if length(user_ids) > 0 do
      {dom_id, user} = Enum.random(user_ids)
      updated_user = %{user | last_login: DateTime.utc_now()}
      
      socket =
        socket
        |> stream_insert(:users, updated_user)
        |> add_log_entry("Auto-update: #{user.name} last login refreshed")
      
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end
  
  # Private helpers
  defp generate_initial_users do
    for i <- 1..10 do
      generate_user(i)
    end
  end
  
  defp generate_user(id) do
    first_names = ["John", "Jane", "Mike", "Sarah", "David", "Emily", "Chris", "Lisa", "Tom", "Amy"]
    last_names = ["Smith", "Johnson", "Williams", "Brown", "Davis", "Miller", "Wilson", "Moore", "Taylor", "Anderson"]
    
    first_name = Enum.random(first_names)
    last_name = Enum.random(last_names)
    
    %{
      id: id,
      name: "#{first_name} #{last_name}",
      email: "#{String.downcase(first_name)}.#{String.downcase(last_name)}@example.com",
      status: Enum.random(["active", "inactive", "pending"]),
      last_login: DateTime.utc_now() |> DateTime.add(-:rand.uniform(30), :day)
    }
  end
  
  defp render_status_badge(status) do
    {color, icon} = case status do
      "active" -> {"badge-success", "hero-check-circle"}
      "inactive" -> {"badge-error", "hero-x-circle"}
      "pending" -> {"badge-warning", "hero-clock"}
      _ -> {"", "hero-question-mark-circle"}
    end
    
    assigns = %{color: color, icon: icon, status: status}
    
    ~H"""
    <span class={"badge #{@color} gap-1"}>
      <.icon name={@icon} class="w-3 h-3" />
      <%= @status %>
    </span>
    """
  end
  
  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%b %d, %Y %I:%M %p")
  end
  
  defp add_log_entry(socket, message) do
    log_entry = %{
      id: System.unique_integer([:positive]),
      timestamp: Calendar.strftime(DateTime.utc_now(), "%H:%M:%S"),
      message: message
    }
    
    stream_insert(socket, :activity_log, log_entry, at: 0)
  end
  
  # Stream helper functions
  defp get_stream_ids(socket, stream_name) do
    case socket.assigns.streams[stream_name] do
      %Phoenix.LiveView.LiveStream{inserts: inserts} ->
        Enum.map(inserts, fn {dom_id, _idx, item, _} -> {dom_id, item} end)
      _ ->
        []
    end
  end
  
  defp get_stream_dom_ids(socket, stream_name) do
    get_stream_ids(socket, stream_name)
    |> Enum.map(fn {dom_id, _} -> dom_id end)
  end
  
  defp find_stream_item(socket, stream_name, dom_id) do
    get_stream_ids(socket, stream_name)
    |> Enum.find_value(fn 
      {^dom_id, item} -> item
      _ -> nil
    end)
  end
  
  defp update_selected_users(socket, new_status) do
    selected_users = 
      socket.assigns.selected_rows
      |> Enum.map(&find_stream_item(socket, :users, &1))
      |> Enum.filter(& &1)
    
    socket = 
      Enum.reduce(selected_users, socket, fn user, acc ->
        updated_user = %{user | status: new_status}
        stream_insert(acc, :users, updated_user)
      end)
      |> assign(:selected_rows, [])
      |> add_log_entry("Updated #{length(selected_users)} users to #{new_status}")
    
    socket
  end
end