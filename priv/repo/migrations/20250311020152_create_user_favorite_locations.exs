defmodule Climora.Repo.Migrations.CreateUserFavoriteLocations do
  use Ecto.Migration

  def up do
    create table(:user_favorite_locations) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :location_id, references(:locations, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_favorite_locations, [:user_id, :location_id])
  end

  def down do
    drop index(:user_favorite_locations, [:user_id, :location_id])

    drop table(:user_favorite_locations)
  end
end
