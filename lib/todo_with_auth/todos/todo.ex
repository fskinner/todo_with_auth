defmodule TodoWithAuth.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  alias TodoWithAuth.Todos.Todo
  alias TodoWithAuth.Authentication.User

  schema "todos" do
    field(:complete, :boolean, default: false)
    field(:description, :string)

    belongs_to(:user, User)

    timestamps()
  end

  @doc false
  def changeset(%Todo{} = todo, attrs) do
    todo
    |> cast(attrs, [:description, :complete, :user_id])
    |> validate_required([:description, :complete, :user_id])
    |> validate_length(:description, min: 2)
    |> assoc_constraint(:user)

    # |> foreign_key_constraint(:user_id)
  end
end
