defmodule TodoWithAuth.UserFactory do
  use ExMachina.Ecto, repo: TodoWithAuth.Repo

  def user_factory do
    %TodoWithAuth.Authentication.User{
      email: "random@mail.com",
      encrypted_password: "LhrP26FFGnMNLdDDtMKiLdw62Wt"
    }
  end
end