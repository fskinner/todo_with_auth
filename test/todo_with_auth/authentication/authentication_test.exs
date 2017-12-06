defmodule TodoWithAuth.AuthenticationTest do
  use TodoWithAuth.DataCase

  alias TodoWithAuth.Authentication

  describe "users" do
    alias TodoWithAuth.Authentication.User

    @valid_attrs %{email: "email@mail.com", password: "some password"}
    @update_attrs %{email: "updated@mail.com", password: "some updated password"}
    @invalid_attrs %{email: nil, password: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Authentication.create_user()

      user
    end

    defp compare_user_fields user do
      assert user.id == Authentication.get_user!(user.id).id
      assert user.email == Authentication.get_user!(user.id).email
      assert user.encrypted_password == Authentication.get_user!(user.id).encrypted_password
      assert user.inserted_at == Authentication.get_user!(user.id).inserted_at
      assert user.updated_at == Authentication.get_user!(user.id).updated_at
    end

    test "list_users/0 returns all users" do
      user_fixture()

      Authentication.list_users()
      |> List.first
      |> compare_user_fields
    end

    test "get_user!/1 returns the user with given id" do
      user_fixture()
      |> compare_user_fields
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Authentication.create_user(@valid_attrs)
      assert user.email == "email@mail.com"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Authentication.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Authentication.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "updated@mail.com"
      
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Authentication.update_user(user, @invalid_attrs)
      
      user
      |> compare_user_fields
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Authentication.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Authentication.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Authentication.change_user(user)
    end
  end
end
