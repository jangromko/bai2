defmodule Bai2.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :password, :string
      add :ostatnie_udane_logowanie, :utc_datetime
      add :ostatnie_nieudane_logowanie, :utc_datetime
      add :liczba_nieudanych_logowan, :integer, default: 0
      add :blokowanie_konta_wlaczone, :boolean, default: false
      add :ile_nieudanych_blokuje, :integer, default: 5
      add :zablokowane, :boolean, default: false
      add :nie_istnieje, :boolean, default: false

      timestamps()
    end

    create index(:users, [:username], unique: true)
  end
end
