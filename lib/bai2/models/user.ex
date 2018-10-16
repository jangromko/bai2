defmodule Bai2.User do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Bai2.Repo

  schema "users" do
    field :username, :string
    field :password, :string
    field :ostatnie_udane_logowanie, :utc_datetime
    field :ostatnie_nieudane_logowanie, :utc_datetime
    field :liczba_nieudanych_logowan, :integer
    field :blokowanie_konta_wlaczone, :boolean
    field :ile_nieudanych_blokuje, :integer
    field :zablokowane, :boolean

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :password, :ostatnie_udane_logowanie, :ostatnie_nieudane_logowanie, :liczba_nieudanych_logowan,
                    :blokowanie_konta_wlaczone, :ile_nieudanych_blokuje, :zablokowane])
    |> validate_required([:username, :password])
    |> unique_constraint(:username)
  end

  def login(username, password) do
    query = from user in __MODULE__,
              where: user.username == ^username
              and user.password == ^password
              and user.zablokowane == false
    Repo.one(query)
  end
end
