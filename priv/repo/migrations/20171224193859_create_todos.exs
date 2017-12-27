defmodule TodoWithAuth.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :description, :string, null: false
      add :complete, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end

    create index(:todos, [:user_id])
  end
end
