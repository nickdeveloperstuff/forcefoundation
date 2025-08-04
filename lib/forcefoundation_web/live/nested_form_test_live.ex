defmodule ForcefoundationWeb.NestedFormTestLive do
  use ForcefoundationWeb, :live_view
  use ForcefoundationWeb.Widgets
  
  # Mock schemas for testing nested forms
  defmodule LineItem do
    use Ecto.Schema
    import Ecto.Changeset
    
    embedded_schema do
      field :product_name, :string
      field :quantity, :integer, default: 1
      field :price, :decimal
    end
    
    def changeset(line_item, attrs \\ %{}) do
      line_item
      |> cast(attrs, [:product_name, :quantity, :price])
      |> validate_required([:product_name, :quantity, :price])
      |> validate_number(:quantity, greater_than: 0)
      |> validate_number(:price, greater_than_or_equal_to: 0)
    end
  end
  
  defmodule Order do
    use Ecto.Schema
    import Ecto.Changeset
    
    schema "orders" do
      field :customer_name, :string
      field :order_date, :date
      field :notes, :string
      embeds_many :line_items, LineItem, on_replace: :delete
    end
    
    def changeset(order, attrs \\ %{}) do
      order
      |> cast(attrs, [:customer_name, :order_date, :notes])
      |> cast_embed(:line_items)
      |> validate_required([:customer_name, :order_date])
    end
  end
  
  def mount(_params, _session, socket) do
    order = %Order{
      order_date: Date.utc_today(),
      line_items: [
        %LineItem{product_name: "Widget A", quantity: 2, price: Decimal.new("19.99")},
        %LineItem{product_name: "Widget B", quantity: 1, price: Decimal.new("39.99")}
      ]
    }
    
    form = order |> Order.changeset(%{}) |> Phoenix.Component.to_form()
    
    {:ok,
     socket
     |> assign(:form, form)
     |> assign(:tags, ["important", "customer", "rush"])
     |> assign(:emails, ["primary@example.com", "secondary@example.com"])
     |> assign(:phones, [])}
  end
  
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-8 max-w-4xl">
      <.heading_widget level={1} text="Nested Form Widgets Test" class="mb-8" />
      
      <!-- Order Form with Nested Line Items -->
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6} class="mb-8">
        <.form_widget
          for={@form}
          on_submit="save_order"
          on_change="validate_order"
          debug_mode={true}
        >
          <:header>
            <.heading_widget level={2} text="Create Order" />
          </:header>
          
          <!-- Basic Fields in Fieldset -->
          <.fieldset_widget legend="Order Information" variant={:bordered}>
            <.input_widget
              field={@form[:customer_name]}
              label="Customer Name"
              required={true}
            />
            
            <.input_widget
              field={@form[:order_date]}
              type="date"
              label="Order Date"
              required={true}
            />
            
            <.textarea_widget
              field={@form[:notes]}
              label="Order Notes"
              rows={3}
              placeholder="Special instructions..."
            />
          </.fieldset_widget>
          
          <!-- Nested Form for Line Items -->
          <.fieldset_widget legend="Line Items" variant={:separated} class="mt-6">
            <.nested_form_widget
              form={@form}
              field={:line_items}
              add_label="Add Line Item"
              min_items={1}
              sortable={true}
            >
              <:builder :let={%{form: f, index: _index}}>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <.input_widget
                    field={f[:product_name]}
                    label="Product"
                    placeholder="Product name"
                    required={true}
                  />
                  
                  <.input_widget
                    field={f[:quantity]}
                    type="number"
                    label="Quantity"
                    min="1"
                    required={true}
                  />
                  
                  <.input_widget
                    field={f[:price]}
                    type="number"
                    label="Unit Price"
                    step="0.01"
                    min="0"
                    required={true}
                  >
                    <:start_addon>$</:start_addon>
                  </.input_widget>
                </div>
              </:builder>
              
              <:empty>
                <div class="text-center py-8 text-gray-500">
                  <p>No line items added yet.</p>
                  <button type="button" phx-click="add_line_items" class="btn btn-primary btn-sm mt-2">
                    Add First Item
                  </button>
                </div>
              </:empty>
            </.nested_form_widget>
          </.fieldset_widget>
          
          <:actions>
            <button type="submit" class="btn btn-primary">
              Create Order
            </button>
            <button type="button" class="btn btn-ghost" phx-click="reset_order">
              Reset
            </button>
          </:actions>
        </.form_widget>
      </.section_widget>
      
      <!-- Repeater Widgets Examples -->
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6} class="mb-8">
        <.heading_widget level={2} text="Repeater Widget Examples" class="mb-6" />
        
        <!-- Tags Repeater -->
        <.fieldset_widget legend="Tags" description="Manage tags with a simple repeater">
          <.repeater_widget
            field={:tags}
            values={@tags}
            add_label="Add Tag"
            placeholder="Enter tag..."
            min_items={1}
            sortable={true}
          />
        </.fieldset_widget>
        
        <!-- Email Addresses with Custom Template -->
        <.fieldset_widget legend="Email Addresses" class="mt-6">
          <.repeater_widget
            field={:emails}
            values={@emails}
            add_label="Add Email"
            max_items={5}
          >
            <:template :let={%{value: value, index: index, field_name: field_name}}>
              <input
                type="email"
                name={field_name}
                value={value}
                placeholder="email@example.com"
                class="input input-bordered w-full"
                phx-blur="update_repeater_emails"
                phx-value-index={index}
              />
            </:template>
          </.repeater_widget>
        </.fieldset_widget>
        
        <!-- Phone Numbers -->
        <.fieldset_widget legend="Phone Numbers" class="mt-6" collapsible collapsed>
          <.repeater_widget
            field={:phones}
            values={@phones}
            add_label="Add Phone"
            input_type="tel"
            placeholder="(555) 123-4567"
          />
        </.fieldset_widget>
      </.section_widget>
      
      <!-- Complex Nested Form Example -->
      <.section_widget background={:white} rounded={:lg} shadow={:md} padding={6}>
        <.heading_widget level={2} text="Collapsible Fieldsets" class="mb-6" />
        
        <.fieldset_widget legend="Personal Information" collapsible>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <.input_widget
              field={Phoenix.Component.to_form(%{first_name: ""}, as: :person)[:first_name]}
              label="First Name"
            />
            <.input_widget
              field={Phoenix.Component.to_form(%{last_name: ""}, as: :person)[:last_name]}
              label="Last Name"
            />
          </div>
        </.fieldset_widget>
        
        <.fieldset_widget legend="Contact Information" collapsible collapsed class="mt-4">
          <.input_widget
            field={Phoenix.Component.to_form(%{phone: ""}, as: :contact)[:phone]}
            type="tel"
            label="Phone"
          />
          <.input_widget
            field={Phoenix.Component.to_form(%{email: ""}, as: :contact)[:email]}
            type="email"
            label="Email"
          />
        </.fieldset_widget>
        
        <.fieldset_widget legend="Address" collapsible collapsed class="mt-4">
          <.input_widget
            field={Phoenix.Component.to_form(%{street: ""}, as: :address)[:street]}
            label="Street Address"
          />
          <div class="grid grid-cols-2 md:grid-cols-3 gap-4">
            <.input_widget
              field={Phoenix.Component.to_form(%{city: ""}, as: :address)[:city]}
              label="City"
            />
            <.input_widget
              field={Phoenix.Component.to_form(%{state: ""}, as: :address)[:state]}
              label="State"
            />
            <.input_widget
              field={Phoenix.Component.to_form(%{zip: ""}, as: :address)[:zip]}
              label="ZIP Code"
            />
          </div>
        </.fieldset_widget>
      </.section_widget>
    </div>
    """
  end
  
  def handle_event("validate_order", %{"order" => params}, socket) do
    changeset = 
      socket.assigns.form.data
      |> Order.changeset(params)
      |> Map.put(:action, :validate)
    
    {:noreply, assign(socket, :form, Phoenix.Component.to_form(changeset))}
  end
  
  def handle_event("save_order", %{"order" => params}, socket) do
    changeset = socket.assigns.form.data |> Order.changeset(params)
    
    case Ecto.Changeset.apply_action(changeset, :insert) do
      {:ok, _order} ->
        {:noreply,
         socket
         |> put_flash(:info, "Order created successfully!")
         |> push_navigate(to: ~p"/test/nested-forms")}
      
      {:error, changeset} ->
        {:noreply, assign(socket, :form, Phoenix.Component.to_form(changeset))}
    end
  end
  
  def handle_event("reset_order", _, socket) do
    order = %Order{order_date: Date.utc_today(), line_items: []}
    form = order |> Order.changeset(%{}) |> Phoenix.Component.to_form()
    {:noreply, assign(socket, :form, form)}
  end
  
  def handle_event("add_line_items", _, socket) do
    existing_items = Map.get(socket.assigns.form.params, "line_items", %{})
    new_index = map_size(existing_items)
    
    new_item = %{
      "#{new_index}" => %{
        "product_name" => "",
        "quantity" => "1",
        "price" => ""
      }
    }
    
    params = Map.put(socket.assigns.form.params, "line_items", Map.merge(existing_items, new_item))
    handle_event("validate_order", %{"order" => params}, socket)
  end
  
  def handle_event("remove_line_items", %{"index" => index}, socket) do
    items = Map.get(socket.assigns.form.params, "line_items", %{})
    new_items = Map.delete(items, index)
    params = Map.put(socket.assigns.form.params, "line_items", new_items)
    handle_event("validate_order", %{"order" => params}, socket)
  end
  
  # Repeater event handlers
  def handle_event("add_repeater_tags", %{"value" => value}, socket) do
    if value != "" do
      {:noreply, update(socket, :tags, &(&1 ++ [value]))}
    else
      {:noreply, socket}
    end
  end
  
  def handle_event("remove_repeater_tags", %{"index" => index}, socket) do
    index = String.to_integer(index)
    {:noreply, update(socket, :tags, &List.delete_at(&1, index))}
  end
  
  def handle_event("add_repeater_emails", %{"value" => value}, socket) do
    if value != "" do
      {:noreply, update(socket, :emails, &(&1 ++ [value]))}
    else
      {:noreply, socket}
    end
  end
  
  def handle_event("remove_repeater_emails", %{"index" => index}, socket) do
    index = String.to_integer(index)
    {:noreply, update(socket, :emails, &List.delete_at(&1, index))}
  end
  
  def handle_event("add_repeater_phones", %{"value" => value}, socket) do
    if value != "" do
      {:noreply, update(socket, :phones, &(&1 ++ [value]))}
    else
      {:noreply, socket}
    end
  end
  
  def handle_event("remove_repeater_phones", %{"index" => index}, socket) do
    index = String.to_integer(index)
    {:noreply, update(socket, :phones, &List.delete_at(&1, index))}
  end
  
  def handle_event("reorder_tags", %{"order" => order}, socket) do
    # Reorder tags based on new order
    new_tags = Enum.map(order, fn idx -> 
      Enum.at(socket.assigns.tags, String.to_integer(idx))
    end)
    {:noreply, assign(socket, :tags, new_tags)}
  end
end