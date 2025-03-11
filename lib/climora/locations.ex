defmodule Climora.Locations do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Climora.Accounts.User
  alias Climora.Locations.Location
  alias Climora.Locations.UserFavoriteLocation
  alias Climora.Repo

  @doc """
  Returns an `%Ecto.Changeset{}` for changing location data.

  ## Examples

      iex> change_location(user)
      %Ecto.Changeset{data: %Location{}}

  """
  def change_location(%Location{} = location, attrs \\ %{}) do
    Location.changeset(location, attrs)
  end

  @doc """
  Gets a location by lat and lon.

  ## Examples

      iex> get_location_by_coordinates(%{"lat" => ..., })
      %Location{}

      iex> get_location_by_coordinates(%{"lat" => ..., })
      nil

  """
  def get_location_by_coordinates(%{"lat" => lat, "lon" => lon}) do
    Repo.get_by(Location, lat: lat, lon: lon)
  end

  @doc """
  Gets a user favorite location by location_id and user_id.

  ## Examples

      iex> get_favorite_location(location_id, user_id)
      %Location{}

      iex> get_favorite_location(location_id, user_id)
      nil

  """
  def get_favorite_location(location_id, user_id) do
    Repo.get_by(UserFavoriteLocation, location_id: location_id, user_id: user_id)
  end

  def list_user_favorite_cities(user_id) do
    query =
      from u in User,
        join: ufl in UserFavoriteLocation,
        on: ufl.user_id == u.id,
        join: l in Location,
        on: l.id == ufl.location_id,
        where: u.id == ^user_id and l.type == :city,
        select: l

    Repo.all(query)
  end

  @doc """
  Inserts a Location{} if the lat and lon doesn't exist, and then create a UserFavoriteLocation{}.
  If the location exists, it just build the UserFavoriteLocation{} relation

  ## Examples

      iex> create_user_favorite_location(user_id,  %{lat: ...})
      {:ok, %UserFavoriteLocation{}}

      iex> create_user_favorite_location(user_id,  %{lat: ...})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_favorite_location(user, attrs) do
    case get_location_by_coordinates(attrs) do
      nil ->
        insert_location_and_mark_it_as_favorite(attrs, user)

      location ->
        case get_favorite_location(location.id, user.id) do
          nil -> insert_user_favorite_location(location, user)
          _ -> {:ok, %{location: location}}
        end
    end
    |> case do
      {:ok, %{location: location}} -> {:ok, location}
      {:error, :location, changeset, _} -> {:error, changeset}
      {:error, :user_favorite_location, changeset, _} -> {:error, changeset}
    end
  end

  defp insert_location_and_mark_it_as_favorite(attrs, user) do
    location = change_location(%Location{}, attrs)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:location, location)
    |> Ecto.Multi.insert(:user_favorite_location, fn %{location: location} ->
      Ecto.build_assoc(location, :user_favorites, user: user)
    end)
    |> Repo.transaction()
  end

  defp insert_user_favorite_location(location, user) do
    Ecto.build_assoc(location, :user_favorites, user: user)
    |> Repo.insert()
  end
end
