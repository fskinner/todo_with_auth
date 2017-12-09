defmodule TodoWithAuthWeb.SessionView do
  use TodoWithAuthWeb, :view

  def render("token.json", %{token: token}) do
    %{token: token}
  end
end
