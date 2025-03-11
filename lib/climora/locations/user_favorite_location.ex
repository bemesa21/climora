defmodule Climora.Locations.UserFavoriteLocation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_favorite_locations" do
    belongs_to :user, Climora.Accounts.User
    belongs_to :location, Climora.Locations.Location

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_favorite_location, attrs) do
    user_favorite_location
    |> cast(attrs, [])
    |> validate_required([])
    |> unique_constraint(:user_id, name: :user_favorite_locations_user_id_location_id_index)
  end
end
