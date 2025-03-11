defmodule Climora.Locations.Location do
  use Ecto.Schema
  import Ecto.Changeset

  alias Climora.Locations.UserFavoriteLocation

  @types [:city, :region]

  schema "locations" do
    field :name, :string
    field :lat, :float
    field :lon, :float
    field :metadata, :map
    field :type, Ecto.Enum, values: @types

    has_many :user_favorites, UserFavoriteLocation
    has_many :users, through: [:user_favorites, :user]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(city, attrs) do
    city
    |> cast(attrs, [:name, :lat, :lon, :type, :metadata])
    |> validate_required([:name, :lat, :lon, :type])
  end
end
