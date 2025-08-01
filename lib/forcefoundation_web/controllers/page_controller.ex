defmodule ForcefoundationWeb.PageController do
  use ForcefoundationWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
