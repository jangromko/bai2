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
    field :nie_istnieje, :boolean

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
    fun = fn ->
      %__MODULE__{
        username: username,
        ostatnie_nieudane_logowanie: DateTime.utc_now(),
        liczba_nieudanych_logowan: 0,
        nie_istnieje: true,
        ile_nieudanych_blokuje: Enum.random(1..7),
        blokowanie_konta_wlaczone: Enum.random([true, false])
      }
        |> Repo.insert(on_conflict: :nothing)

      query = from user in __MODULE__,
                where: user.username == ^username,
                lock: "FOR UPDATE"

      user = Repo.one(query)

      czas = DateTime.diff(DateTime.utc_now(), user.ostatnie_nieudane_logowanie || DateTime.utc_now()) >= user.liczba_nieudanych_logowan*15

      cond do
        user.password == password and not user.zablokowane
        and not user.nie_istnieje and czas ->
          {:ok, user.liczba_nieudanych_logowan, user
          |> Ecto.Changeset.change(%{liczba_nieudanych_logowan: 0, ostatnie_udane_logowanie: DateTime.utc_now()})
          |> Repo.update!() }

        not czas -> {:blokada,  user.liczba_nieudanych_logowan*15 - DateTime.diff(DateTime.utc_now(), user.ostatnie_nieudane_logowanie) }

        true ->
          nieudane = user.liczba_nieudanych_logowan + 1

          zablokuj = user.blokowanie_konta_wlaczone and nieudane >= user.ile_nieudanych_blokuje

          user
            |> Ecto.Changeset.change(%{zablokowane: zablokuj, liczba_nieudanych_logowan: nieudane, ostatnie_nieudane_logowanie: DateTime.utc_now()})
            |> Repo.update!()

          if zablokuj do
            :blokada
          end
      end
    end

    case Repo.transaction(fun) do
      {_, v} -> v
    end
  end


  def info(username) do
    u = Repo.get_by!(__MODULE__, username: username)

    %{id: u.id,
      username: u.username,
      udane: u.ostatnie_udane_logowanie,
      nieudane: u.ostatnie_nieudane_logowanie,
      blokowanie: u.blokowanie_konta_wlaczone,
      ile_blokuje: u.ile_nieudanych_blokuje}
  end
end
