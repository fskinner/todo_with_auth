defmodule TodoWithAuthWeb.SessionViewTest do
  use TodoWithAuthWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders token.json" do
    rendered_token = render(TodoWithAuthWeb.SessionView, "token.json", %{token: "zmEAhFLKYRQ9RFpJ93r4sAaEkxgoVMxoM+zR9unORnC5MAO68Hem1vtyy/Qs2vPp"})

    assert rendered_token == %{token: "zmEAhFLKYRQ9RFpJ93r4sAaEkxgoVMxoM+zR9unORnC5MAO68Hem1vtyy/Qs2vPp"}
  end
end