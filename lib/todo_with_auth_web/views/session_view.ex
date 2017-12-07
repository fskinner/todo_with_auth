defmodule TodoWithAuthWeb.SessionView do
  use TodoWithAuthWeb, :view
  alias TodoWithAuthWeb.SessionView

  def render("token.json", %{token: token}) do
    %{token: token}
  end
end
