defmodule ForcefoundationWeb.FormTestLive do
  use ForcefoundationWeb, :live_view
  use ForcefoundationWeb.Widgets
  alias ForcefoundationWeb.Widgets.FormHelpers
  
  # Mock User schema for testing
  defmodule User do
    use Ecto.Schema
    import Ecto.Changeset
    
    schema "users" do
      field :name, :string
      field :email, :string
      field :age, :integer
      field :bio, :string
      field :newsletter, :boolean, default: false
      field :country, :string
      field :plan, :string
      field :website, :string
      field :phone, :string
      field :notes, :string
    end
    
    def changeset(user, attrs \\ %{}) do
      user
      |> cast(attrs, [:name, :email, :age, :bio, :newsletter, :country, :plan, :website, :phone, :notes])
      |> validate_required([:name, :email])
      |> validate_format(:email, ~r/@/)
      |> validate_number(:age, greater_than: 0, less_than_or_equal_to: 150)
    end
  end
  
  def mount(_params, _session, socket) do
    form = FormHelpers.create_form(User, :create)
    
    {:ok,
     socket
     |> assign(:form, form)
     |> assign(:variant, :default)
     |> assign(:show_errors, true)
     |> assign(:result, nil)}
  end
  
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-8 max-w-2xl">
      <.heading_widget level={1} text="Form Widget Test" class="mb-8" />
      
      <!-- Controls -->
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={4} class="mb-6">
        <.heading_widget level={3} text="Form Options" class="mb-4" />
        
        <div class="flex gap-4 items-center">
          <div class="form-control">
            <label class="label">
              <span class="label-text">Variant</span>
            </label>
            <div class="btn-group">
              <button 
                class={["btn btn-sm", @variant == :default && "btn-active"]}
                phx-click="set_variant"
                phx-value-variant="default"
              >
                Default
              </button>
              <button 
                class={["btn btn-sm", @variant == :inline && "btn-active"]}
                phx-click="set_variant"
                phx-value-variant="inline"
              >
                Inline
              </button>
              <button 
                class={["btn btn-sm", @variant == :floating && "btn-active"]}
                phx-click="set_variant"
                phx-value-variant="floating"
              >
                Floating
              </button>
            </div>
          </div>
          
          <div class="form-control">
            <label class="label cursor-pointer">
              <span class="label-text mr-2">Show Errors</span>
              <input 
                type="checkbox" 
                class="toggle toggle-primary"
                checked={@show_errors}
                phx-click="toggle_errors"
              />
            </label>
          </div>
        </div>
      </.section_widget>
      
      <!-- Main Form -->
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6}>
        <.form_widget
          for={@form}
          on_submit="save"
          on_change="validate"
          variant={@variant}
          errors={@show_errors}
          debug_mode={true}
        >
          <!-- Content placeholder until we have input widgets -->
          <:header>
            <.heading_widget level={2} text="User Registration" />
            <p class="text-gray-600">Please fill out all required fields</p>
          </:header>
          
          <!-- Text Input -->
          <.input_widget
            field={@form[:name]}
            label="Name"
            placeholder="Enter your name"
            required={true}
            hint="Your full name"
          />
          
          <!-- Email Input with Icon -->
          <.input_widget
            field={@form[:email]}
            type="email"
            label="Email"
            placeholder="email@example.com"
            required={true}
            variant={:bordered}
            size={:md}
          >
            <:start_addon>
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
              </svg>
            </:start_addon>
          </.input_widget>
          
          <!-- Number Input -->
          <.input_widget
            field={@form[:age]}
            type="number"
            label="Age"
            placeholder="Your age"
            min="1"
            max="150"
          />
          
          <!-- URL Input with Addon -->
          <.input_widget
            field={@form[:website]}
            type="url"
            label="Website"
            placeholder="yoursite.com"
          >
            <:start_addon>https://</:start_addon>
          </.input_widget>
          
          <!-- Phone Input -->
          <.input_widget
            field={@form[:phone]}
            type="tel"
            label="Phone"
            placeholder="(555) 123-4567"
            hint="Optional"
          />
          
          <!-- Select Dropdown -->
          <.select_widget
            field={@form[:country]}
            label="Country"
            options={[
              {"United States", "US"},
              {"Canada", "CA"},
              {"Mexico", "MX"},
              {"United Kingdom", "UK"},
              {"Germany", "DE"},
              {"France", "FR"},
              {"Japan", "JP"},
              {"Australia", "AU"}
            ]}
            prompt="Choose a country"
          />
          
          <!-- Radio Group -->
          <.radio_widget
            field={@form[:plan]}
            label="Choose your plan"
            options={[
              {"Free", "free"},
              {"Pro ($9/mo)", "pro"},
              {"Enterprise", "enterprise"}
            ]}
            required={true}
          />
          
          <!-- Textarea -->
          <.textarea_widget
            field={@form[:bio]}
            label="Bio"
            placeholder="Tell us about yourself..."
            rows={4}
            hint="Max 500 characters"
            maxlength={500}
            show_count={true}
          />
          
          <!-- Additional Notes with different variant -->
          <.textarea_widget
            field={@form[:notes]}
            label="Additional Notes"
            placeholder="Any other information..."
            rows={3}
            variant={:ghost}
            resize={:vertical}
          />
          
          <!-- Checkbox -->
          <.checkbox_widget
            field={@form[:newsletter]}
            label="Subscribe to newsletter"
            variant={:primary}
          />
          
          <:actions>
            <button type="submit" class="btn btn-primary" phx-disable-with="Saving...">
              Register
            </button>
            <button type="button" class="btn btn-ghost" phx-click="reset">
              Reset
            </button>
          </:actions>
          
          <:footer>
            <p class="text-sm text-gray-500">
              By registering, you agree to our terms and conditions.
            </p>
          </:footer>
        </.form_widget>
      </.section_widget>
      
      <!-- Result display -->
      <%= if @result do %>
        <.section_widget background={:white} rounded={:lg} shadow={:md} padding={4} class="mt-6">
          <div class="alert alert-success">
            <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <div>
              <h3 class="font-bold">Form submitted successfully!</h3>
              <pre class="mt-2 text-sm"><%= inspect(@result, pretty: true) %></pre>
            </div>
          </div>
        </.section_widget>
      <% end %>
      
      <!-- Inline form example -->
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6} class="mt-6">
        <.heading_widget level={2} text="Inline Form Example" class="mb-4" />
        <.form_widget
          for={Phoenix.Component.to_form(%{query: "", category: ""}, as: :search)}
          on_submit="search"
          variant={:inline}
        >
          <!-- Search form content -->
          <.input_widget
            field={Phoenix.Component.to_form(%{query: ""}, as: :search)[:query]}
            placeholder="Search..."
            variant={:bordered}
            class="flex-1"
          />
          
          <.select_widget
            field={Phoenix.Component.to_form(%{category: ""}, as: :search)[:category]}
            options={[
              {"Users", "users"},
              {"Posts", "posts"},
              {"Comments", "comments"}
            ]}
            prompt="All Categories"
            variant={:bordered}
          />
          
          <:actions>
            <button type="submit" class="btn btn-primary">
              Search
            </button>
          </:actions>
        </.form_widget>
      </.section_widget>
      
      <!-- Widget States Demo -->
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6} class="mt-6">
        <.heading_widget level={2} text="Widget States Demo" class="mb-4" />
        
        <div class="space-y-4">
          <.heading_widget level={3} text="Input States" class="mb-2" />
          
          <!-- Disabled Input -->
          <.input_widget
            field={Phoenix.Component.to_form(%{disabled: "This is disabled"}, as: :demo)[:disabled]}
            label="Disabled Input"
            disabled={true}
          />
          
          <!-- Input with Error -->
          <.input_widget
            field={Phoenix.Component.to_form(%{error: ""}, as: :demo)[:error]}
            label="Input with Error"
            error="This field is required"
          />
          
          <!-- Different Sizes -->
          <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <.input_widget
              field={Phoenix.Component.to_form(%{xs: ""}, as: :demo)[:xs]}
              label="Extra Small"
              size={:xs}
              placeholder="xs"
            />
            <.input_widget
              field={Phoenix.Component.to_form(%{sm: ""}, as: :demo)[:sm]}
              label="Small"
              size={:sm}
              placeholder="sm"
            />
            <.input_widget
              field={Phoenix.Component.to_form(%{md: ""}, as: :demo)[:md]}
              label="Medium"
              size={:md}
              placeholder="md"
            />
            <.input_widget
              field={Phoenix.Component.to_form(%{lg: ""}, as: :demo)[:lg]}
              label="Large"
              size={:lg}
              placeholder="lg"
            />
          </div>
          
          <!-- Checkbox Variants -->
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <.checkbox_widget
              field={Phoenix.Component.to_form(%{cb_primary: false}, as: :demo)[:cb_primary]}
              label="Primary"
              variant={:primary}
            />
            <.checkbox_widget
              field={Phoenix.Component.to_form(%{cb_secondary: false}, as: :demo)[:cb_secondary]}
              label="Secondary"
              variant={:secondary}
            />
            <.checkbox_widget
              field={Phoenix.Component.to_form(%{cb_accent: false}, as: :demo)[:cb_accent]}
              label="Accent"
              variant={:accent}
            />
            <.checkbox_widget
              field={Phoenix.Component.to_form(%{cb_success: false}, as: :demo)[:cb_success]}
              label="Success"
              variant={:success}
            />
          </div>
          
          <!-- Radio Layout -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <.radio_widget
              field={Phoenix.Component.to_form(%{layout_v: "opt1"}, as: :demo)[:layout_v]}
              label="Vertical Layout"
              options={[
                {"Option 1", "opt1"},
                {"Option 2", "opt2"},
                {"Option 3", "opt3"}
              ]}
              layout={:vertical}
            />
            <.radio_widget
              field={Phoenix.Component.to_form(%{layout_h: "opt1"}, as: :demo)[:layout_h]}
              label="Horizontal Layout"
              options={[
                {"Option A", "optA"},
                {"Option B", "optB"},
                {"Option C", "optC"}
              ]}
              layout={:horizontal}
            />
          </div>
        </div>
      </.section_widget>
    </div>
    """
  end
  
  def handle_event("validate", %{"user" => params}, socket) do
    form = FormHelpers.update_form(socket.assigns.form, params)
    {:noreply, assign(socket, :form, form)}
  end
  
  def handle_event("save", %{"user" => _params}, socket) do
    case FormHelpers.submit_form(socket.assigns.form) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(:result, user)
         |> put_flash(:info, "User registered successfully!")}
      
      {:error, form} ->
        {:noreply,
         socket
         |> assign(:form, form)
         |> assign(:show_errors, true)}
    end
  end
  
  def handle_event("reset", _, socket) do
    form = FormHelpers.create_form(User, :create)
    
    {:noreply,
     socket
     |> assign(:form, form)
     |> assign(:result, nil)
     |> assign(:show_errors, false)}
  end
  
  def handle_event("set_variant", %{"variant" => variant}, socket) do
    {:noreply, assign(socket, :variant, String.to_atom(variant))}
  end
  
  def handle_event("toggle_errors", _, socket) do
    {:noreply, update(socket, :show_errors, &(!&1))}
  end
  
  def handle_event("search", params, socket) do
    IO.inspect(params, label: "Search params")
    {:noreply, put_flash(socket, :info, "Search submitted")}
  end
end