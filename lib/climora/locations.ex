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

  @doc """
  Lists all the favorite cities of a specific user by joining the `User`, `UserFavoriteLocation`, and `Location` tables.
  The query filters for locations where the `type` is `:city`, meaning it only retrieves cities as favorite locations.

  ### Example:

      iex> list_user_favorite_cities(123)
      [
        %Location{id: 1, name: "New York", type: :city, lat: 40.7128, lon: -74.0060},
        %Location{id: 2, name: "Los Angeles", type: :city, lat: 34.0522, lon: -118.2437}
      ]

      iex> list_user_favorite_cities(999)
      []


  """

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
  Deletes the UserFavoriteLocation for a given `user_id`, `lat` and `lon`.

  ## Examples

      iex> delete_user_favorite_location(1, 19.432608, -99.133209)
      {:ok, %UserFavoriteLocation{}}

      iex> delete_user_favorite_location(1, 999.999, 999.999)
      {:error, "UserFavoriteLocation not found"}
  """
  def delete_user_favorite_location(user_id, lat, lon) do
    with %Location{} = location <- get_location_by_coordinates(%{"lat" => lat, "lon" => lon}),
         {:ok, user_fav_location} <- find_user_favorite_location(user_id, location.id) do
      Repo.delete(user_fav_location)
      {:ok, user_fav_location}
    else
      {:error, _reason} = error -> error
    end
  end

  @doc """
  Inserts a `Location{}` if it doesn't exist based on the provided `lat` and `lon`. Afterward, a `UserFavoriteLocation{}` is created, associating the given `user` with the found or newly inserted location.
  If the location already exists, the function only creates the relationship between the existing location and the user by creating or checking for an existing `UserFavoriteLocation{}`.


  ### Examples:

    iex> create_user_favorite_location(user_id, %{lat: 40.7128, lon: -74.0060})
    {:ok, %UserFavoriteLocation{}}

    iex> create_user_favorite_location(user_id, %{lat: 34.0522, lon: -118.2437})
    {:ok, %UserFavoriteLocation{}}

    iex> create_user_favorite_location(user_id, %{lat: 40.7128, lon: -74.0060})
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

  defp find_user_favorite_location(user_id, location_id) do
    case Repo.get_by(UserFavoriteLocation, user_id: user_id, location_id: location_id) do
      nil -> {:error, "UserFavoriteLocation not found"}
      user_fav_location -> {:ok, user_fav_location}
    end
  end
end
