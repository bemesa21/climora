defmodule Climora.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def up do
    create table(:locations) do
      add :name, :string
      add :lat, :float
      add :lon, :float
      add :metadata, :map
      add :type, :string

      timestamps(type: :utc_datetime)
    end
  end

  def down do
    drop table(:locations)
  end
end
