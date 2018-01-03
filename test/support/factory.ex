defmodule TodoWithAuth.Factory do
  use ExMachina.Ecto, repo: TodoWithAuth.Repo

  def user_factory do
    %TodoWithAuth.Authentication.User{
      email: "random@mail.com",
      encrypted_password: "LhrP26FFGnMNLdDDtMKiLdw62Wt"
    }
  end

  def todo_factory do
    %TodoWithAuth.Todos.Todo{
      complete: true,
      description: "my random task",
      user: build(:user), # associations are inserted when you call `insert`
    }
  end
end