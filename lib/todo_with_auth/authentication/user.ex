defmodule TodoWithAuth.Authentication.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias TodoWithAuth.Authentication.User


  schema "users" do
    field :email, :string
    field :encrypted_password, :string
    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :encrypted_password])
    |> validate_required([:email, :encrypted_password])
  end
end
