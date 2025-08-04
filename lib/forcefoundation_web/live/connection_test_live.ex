defmodule ForcefoundationWeb.ConnectionTestLive do
  use ForcefoundationWeb, :live_view
  import ForcefoundationWeb.Widgets.ConnectionTestWidget
  
  # Mock domain for testing
  defmodule TestDomain do
    @users [
      %{id: "1", name: "Alice", email: "alice@example.com"},
      %{id: "2", name: "Bob", email: "bob@example.com"},
      %{id: "3", name: "Charlie", email: "charlie@example.com"}
    ]
    
    def list do
      @users
    end
    
    def get(id) do
      Enum.find(@users, fn u -> u.id == id end)
    end
    
    def create_user(params) do
      {:ok, Map.merge(%{id: "4"}, params)}
    end
  end
  
  def mount(_params, _session, socket) do
    # Create a sample changeset for form testing
    changeset = %{
      data: %{name: "", email: ""},
      errors: [],
      valid?: false
    }
    
    {:ok, assign(socket, changeset: changeset)}
  end
  
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-8">
      <h1 class="text-3xl font-bold mb-8">Connection Resolution System Test</h1>
      
      <div class="space-y-8">
        <!-- Test 1: Static/Dumb Mode -->
        <section>
          <h2 class="text-xl font-semibold mb-4">1. Static Mode (Dumb Widget)</h2>
          <.connection_test_widget 
            data_source={:static}
            debug_mode={true}
          />
        </section>
        
        <!-- Test 2: Interface Connection -->
        <section>
          <h2 class="text-xl font-semibold mb-4">2. Interface Connection</h2>
          <.connection_test_widget 
            data_source={{:interface, TestDomain}}
            debug_mode={true}
          />
        </section>
        
        <!-- Test 3: Resource Connection -->
        <section>
          <h2 class="text-xl font-semibold mb-4">3. Resource Connection</h2>
          <.connection_test_widget 
            data_source={{:resource, TestDomain, "2"}}
            debug_mode={true}
          />
        </section>
        
        <!-- Test 4: Stream Connection -->
        <section>
          <h2 class="text-xl font-semibold mb-4">4. Stream Connection</h2>
          <.connection_test_widget 
            data_source={{:stream, "test:updates"}}
            debug_mode={true}
          />
          <button class="btn btn-primary mt-2" phx-click="broadcast_test">
            Broadcast Test Message
          </button>
        </section>
        
        <!-- Test 5: Form Connection -->
        <section>
          <h2 class="text-xl font-semibold mb-4">5. Form Connection</h2>
          <.connection_test_widget 
            data_source={{:form, @changeset}}
            debug_mode={true}
          />
        </section>
        
        <!-- Test 6: Action Connection -->
        <section>
          <h2 class="text-xl font-semibold mb-4">6. Action Connection</h2>
          <.connection_test_widget 
            data_source={{:action, TestDomain, :create_user, %{name: "Test User", email: "test@example.com"}}}
            debug_mode={true}
          />
        </section>
        
        <!-- Test 7: Subscribe with Filter -->
        <section>
          <h2 class="text-xl font-semibold mb-4">7. Subscribe with Filter</h2>
          <.connection_test_widget 
            data_source={{:subscribe, "test:events", fn msg -> msg.type == :important end}}
            debug_mode={true}
          />
          <div class="mt-2 space-x-2">
            <button class="btn btn-secondary" phx-click="broadcast_important">
              Broadcast Important
            </button>
            <button class="btn btn-secondary" phx-click="broadcast_normal">
              Broadcast Normal
            </button>
          </div>
        </section>
        
        <!-- Test 8: Invalid Connection -->
        <section>
          <h2 class="text-xl font-semibold mb-4">8. Invalid Connection (Error State)</h2>
          <.connection_test_widget 
            data_source={{:invalid, "test"}}
            debug_mode={true}
          />
        </section>
      </div>
    </div>
    """
  end
  
  def handle_event("broadcast_test", _params, socket) do
    Phoenix.PubSub.broadcast(
      Forcefoundation.PubSub,
      "test:updates",
      {:pubsub, "test:updates", %{message: "Stream update at #{DateTime.utc_now()}"}}
    )
    {:noreply, socket}
  end
  
  def handle_event("broadcast_important", _params, socket) do
    Phoenix.PubSub.broadcast(
      Forcefoundation.PubSub,
      "test:events",
      {:pubsub, "test:events", %{type: :important, message: "Important event!"}}
    )
    {:noreply, socket}
  end
  
  def handle_event("broadcast_normal", _params, socket) do
    Phoenix.PubSub.broadcast(
      Forcefoundation.PubSub,
      "test:events",
      {:pubsub, "test:events", %{type: :normal, message: "Normal event (should be filtered)"}}
    )
    {:noreply, socket}
  end
end