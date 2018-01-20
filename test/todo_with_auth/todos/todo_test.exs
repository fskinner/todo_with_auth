defmodule TodoWithAuth.TodoTest do
  use TodoWithAuth.DataCase

  alias TodoWithAuth.Todos.Todo

  @valid_attrs %{complete: true, description: "ok", user_id: 1}

  test "changeset with valid attributes" do
    changeset = Todo.changeset(%Todo{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset, description empty" do
    changeset =
      Todo.changeset(
        %Todo{},
        Map.put(@valid_attrs, :description, "")
      )

    refute changeset.valid?
  end

  test "changeset, description nil" do
    changeset =
      Todo.changeset(
        %Todo{},
        Map.put(@valid_attrs, :description, nil)
      )

    refute changeset.valid?
  end

  test "changeset, description too short" do
    changeset =
      Todo.changeset(
        %Todo{},
        Map.put(@valid_attrs, :description, "a")
      )

    refute changeset.valid?
  end

  test "changeset, complete empty" do
    changeset =
      Todo.changeset(
        %Todo{},
        Map.put(@valid_attrs, :complete, nil)
      )

    refute changeset.valid?
  end

  test "changeset, user_id empty" do
    changeset =
      Todo.changeset(
        %Todo{},
        Map.put(@valid_attrs, :user_id, nil)
      )

    refute changeset.valid?
  end
end
