defmodule Bai2.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :password, :string
      add :ostatnie_udane_logowanie, :utc_datetime
      add :ostatnie_nieudane_logowanie, :utc_datetime
      add :liczba_nieudanych_logowan, :integer
      add :blokowanie_konta_wlaczone, :boolean
      add :ile_nieudanych_blokuje, :integer
      add :zablokowane, :boolean, default: false

      timestamps()
    end
  end
end