defmodule TodoWithAuthWeb.UserViewTest do
    use TodoWithAuthWeb.ConnCase, async: true

    import TodoWithAuth.Factory

    # Bring render/3 and render_to_string/3 for testing custom views
    import Phoenix.View

    defp user_json(user) do
      %{id: user.id, email: user.email}
    end

    test "renders user.json" do
      user = insert(:user)
      rendered_user = render(TodoWithAuthWeb.UserView, "user.json", user: user)

      assert rendered_user == user_json(user)
    end
  
    test "renders index.json" do
      user = insert(:user)
      rendered_user = render(TodoWithAuthWeb.UserView, "index.json", %{users: [user]})

      assert rendered_user == %{data: [user_json(user)]}
    end

    test "renders show.json" do
      user = insert(:user)
      rendered_user = render(TodoWithAuthWeb.UserView, "show.json", %{user: user})

      assert rendered_user == %{data: user_json(user)}
    end
  end
  