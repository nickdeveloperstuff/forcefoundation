defmodule ForcefoundationWeb.ActionButtonTestLive do
  use ForcefoundationWeb, :live_view
  use ForcefoundationWeb.Widgets
  alias ForcefoundationWeb.Widgets.ActionHandler
  
  # Mock Task resource for testing
  defmodule Task do
    use Ash.Resource, domain: nil
    
    attributes do
      uuid_primary_key :id
      attribute :title, :string, allow_nil?: false
      attribute :completed, :boolean, default: false
      attribute :priority, :atom, constraints: [one_of: [:low, :medium, :high]], default: :medium
    end
    
    actions do
      defaults [:create, :read, :update, :destroy]
      
      update :complete do
        change set_attribute(:completed, true)
      end
      
      update :toggle do
        change fn changeset, _ ->
          current = Ash.Changeset.get_attribute(changeset, :completed)
          Ash.Changeset.change_attribute(changeset, :completed, !current)
        end
      end
    end
  end
  
  defmodule TaskDomain do
    use Ash.Domain, validate_config_inclusion?: false
    
    resources do
      resource Task
    end
  end
  
  def mount(_params, _session, socket) do
    # Create some test tasks
    tasks = [
      %{id: Ash.UUID.generate(), title: "Complete documentation", completed: false, priority: :high},
      %{id: Ash.UUID.generate(), title: "Review pull requests", completed: true, priority: :medium},
      %{id: Ash.UUID.generate(), title: "Update dependencies", completed: false, priority: :low}
    ]
    
    {:ok,
     socket
     |> assign(:tasks, tasks)
     |> assign(:loading_actions, %{})
     |> assign(:show_confirm_dialog, false)
     |> assign(:action_result, nil)}
  end
  
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-8">
      <.heading_widget level={1} text="Action Button Test" class="mb-8" />
      
      <!-- Basic Action Buttons -->
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6} class="mb-8">
        <.heading_widget level={2} text="Basic Action Buttons" class="mb-6" />
        
        <div class="space-y-6">
          <!-- Create Action -->
          <div>
            <.heading_widget level={3} text="Create Action" class="mb-4" />
            <.action_button_widget
              label="Create Task"
              variant={:primary}
              icon="hero-plus"
              action={:create}
              resource={Task}
              params={%{title: "New Task from Button", priority: :medium}}
              success_message="Task created successfully!"
              loading={ActionHandler.loading?(assigns, "create-task")}
              id="create-task"
            />
          </div>
          
          <!-- Update Actions -->
          <div>
            <.heading_widget level={3} text="Update Actions" class="mb-4" />
            <div class="space-y-4">
              <%= for task <- @tasks do %>
                <div class="flex items-center gap-4 p-4 border rounded-lg">
                  <div class="flex-1">
                    <.text_widget text={task.title} class="font-medium" />
                    <div class="flex gap-2 mt-1">
                      <.badge_widget 
                        label={to_string(task.priority)} 
                        color={priority_variant(task.priority)} 
                        size={:sm} 
                      />
                      <%= if task.completed do %>
                        <.badge_widget label="Completed" color={:success} size={:sm} />
                      <% else %>
                        <.badge_widget label="Pending" color={:default} size={:sm} />
                      <% end %>
                    </div>
                  </div>
                  
                  <div class="flex gap-2">
                    <.action_button_widget
                      label={if task.completed, do: "Reopen", else: "Complete"}
                      variant={if task.completed, do: :warning, else: :success}
                      icon={if task.completed, do: "hero-arrow-path", else: "hero-check"}
                      action={:toggle}
                      resource={Task}
                      record={task}
                      success_message="Task updated!"
                      loading={ActionHandler.loading?(assigns, "toggle-#{task.id}")}
                      id={"toggle-#{task.id}"}
                      size={:sm}
                    />
                  </div>
                </div>
              <% end %>
            </div>
          </div>
          
          <!-- Delete with Confirmation -->
          <div>
            <.heading_widget level={3} text="Delete with Confirmation" class="mb-4" />
            <div class="space-y-4">
              <%= for task <- @tasks do %>
                <div class="flex items-center gap-4 p-4 border rounded-lg">
                  <div class="flex-1">
                    <.text_widget text={task.title} class="font-medium" />
                  </div>
                  
                  <.action_button_widget
                    label="Delete"
                    variant={:error}
                    icon="hero-trash"
                    action={:destroy}
                    resource={Task}
                    record={task}
                    confirm={"Are you sure you want to delete '#{task.title}'? This action cannot be undone."}
                    confirm_title="Delete Task"
                    success_message="Task deleted successfully!"
                    loading={ActionHandler.loading?(assigns, "delete-#{task.id}")}
                    id={"delete-#{task.id}"}
                    size={:sm}
                  />
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </.section_widget>
      
      <!-- Loading States Demo -->
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6} class="mb-8">
        <.heading_widget level={2} text="Loading States" class="mb-6" />
        
        <div class="space-y-4">
          <.action_button_widget
            label="Simulate Long Action"
            variant={:primary}
            icon="hero-clock"
            action={:custom}
            resource={Task}
            on_click="simulate_long_action"
            loading={ActionHandler.loading?(assigns, "long-action")}
            id="long-action"
          />
          
          <.text_widget text="Click to see loading state (simulates 3 second action)" class="text-sm text-gray-600" />
        </div>
      </.section_widget>
      
      <!-- Standalone Confirm Dialog -->
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6}>
        <.heading_widget level={2} text="Standalone Confirm Dialog" class="mb-6" />
        
        <.button_widget
          label="Show Confirm Dialog"
          variant={:warning}
          icon="hero-exclamation-triangle"
          on_click="show_confirm_dialog"
        />
        
        <.confirm_dialog_widget
          id="standalone-confirm"
          title="Important Action"
          message="This is a standalone confirmation dialog. Do you want to proceed with this action?"
          confirm_label="Yes, Proceed"
          cancel_label="No, Cancel"
          confirm_variant={:primary}
          on_confirm="confirm_action"
          on_cancel="cancel_action"
          open={@show_confirm_dialog}
        />
      </.section_widget>
      
      <!-- Action Result Display -->
      <%= if @action_result do %>
        <.section_widget background={:white} rounded={:lg} shadow={:md} padding={4} class="mt-8">
          <.heading_widget level={3} text="Last Action Result" class="mb-2" />
          <pre class="text-sm bg-gray-100 p-2 rounded"><%= inspect(@action_result, pretty: true) %></pre>
        </.section_widget>
      <% end %>
    </div>
    """
  end
  
  # Handle action events
  def handle_event("execute_action", params, socket) do
    # For demo purposes, simulate the action without actually using Ash
    action_id = params["action_id"]
    action = String.to_existing_atom(params["action"])
    
    socket = ActionHandler.start_loading(socket, action_id)
    
    # Simulate action execution
    Process.send_after(self(), {:complete_action, action_id, action}, 1000)
    
    {:noreply, socket}
  end
  
  def handle_event("simulate_long_action", _, socket) do
    socket = ActionHandler.start_loading(socket, "long-action")
    Process.send_after(self(), {:complete_action, "long-action", :custom}, 3000)
    {:noreply, socket}
  end
  
  def handle_event("show_confirm_dialog", _, socket) do
    {:noreply, assign(socket, :show_confirm_dialog, true)}
  end
  
  def handle_event("confirm_action", %{"dialog_id" => "standalone-confirm"}, socket) do
    {:noreply,
     socket
     |> assign(:show_confirm_dialog, false)
     |> assign(:action_result, %{action: :confirmed, dialog_id: "standalone-confirm"})
     |> put_flash(:info, "Action confirmed!")}
  end
  
  def handle_event("cancel_action", %{"dialog_id" => "standalone-confirm"}, socket) do
    {:noreply,
     socket
     |> assign(:show_confirm_dialog, false)
     |> assign(:action_result, %{action: :cancelled, dialog_id: "standalone-confirm"})
     |> put_flash(:info, "Action cancelled")}
  end
  
  def handle_info({:complete_action, action_id, action}, socket) do
    socket = ActionHandler.stop_loading(socket, action_id)
    
    result = case action do
      :create ->
        new_task = %{
          id: Ash.UUID.generate(),
          title: "New Task from Button",
          completed: false,
          priority: :medium
        }
        
        socket
        |> update(:tasks, &[new_task | &1])
        |> assign(:action_result, %{action: :create, data: new_task})
        |> put_flash(:info, "Task created successfully!")
        
      :toggle ->
        task_id = String.replace(action_id, "toggle-", "")
        
        socket
        |> update(:tasks, fn tasks ->
          Enum.map(tasks, fn task ->
            if task.id == task_id do
              %{task | completed: !task.completed}
            else
              task
            end
          end)
        end)
        |> assign(:action_result, %{action: :toggle, task_id: task_id})
        |> put_flash(:info, "Task updated!")
        
      :destroy ->
        task_id = String.replace(action_id, "delete-", "")
        
        socket
        |> update(:tasks, fn tasks ->
          Enum.reject(tasks, &(&1.id == task_id))
        end)
        |> assign(:action_result, %{action: :destroy, task_id: task_id})
        |> put_flash(:info, "Task deleted successfully!")
        
      :custom ->
        socket
        |> assign(:action_result, %{action: :custom, message: "Long action completed"})
        |> put_flash(:info, "Long action completed!")
    end
    
    {:noreply, result}
  end
  
  defp priority_variant(:high), do: :error
  defp priority_variant(:medium), do: :warning
  defp priority_variant(:low), do: :info
end