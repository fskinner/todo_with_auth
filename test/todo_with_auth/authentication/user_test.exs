defmodule TodoWithAuth.UserTest do
  use TodoWithAuth.DataCase

  alias TodoWithAuth.Authentication.User

  @valid_attrs %{email: "bar@baz.com", password: "123456"}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset, email too short " do
    changeset =
      User.changeset(
        %User{},
        Map.put(@valid_attrs, :email, "")
      )

    refute changeset.valid?
  end

  test "changeset, email invalid format" do
    changeset =
      User.changeset(
        %User{},
        Map.put(@valid_attrs, :email, "foo.com")
      )

    refute changeset.valid?
  end

  test "changeset, encrypted_password not empty" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.changes.encrypted_password
    assert changeset.valid?
  end

  test "changeset, password too short" do
    changeset =
      User.changeset(
        %User{},
        Map.put(@valid_attrs, :password, "12345")
      )

    refute changeset.valid?
  end
end
