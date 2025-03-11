defmodule ClimoraWeb.HomeLive do
  use ClimoraWeb, :live_view
  alias Climora.Locations

  @api_url "http://api.openweathermap.org/geo/1.0/direct"
  @api_key ""

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        :page_title,
        "Hey! #{socket.assigns.current_user.email}, here are your favorite cities!"
      )
      |> assign(:cities_search, to_form(%{"city_name" => ""}, as: "cities_search"))
      |> stream(:resulting_cities, [])
      |> stream(:favorite_cities, [])

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> stream(:resulting_cities, [], reset: true)
    |> stream(
      :favorite_cities,
      Locations.list_user_favorite_cities(socket.assigns.current_user.id),
      reset: true
    )
  end

  defp apply_action(socket, :edit, _params) do
    socket
    |> stream(:resulting_cities, [], reset: true)
  end

  def handle_event("search_city", %{"cities_search" => %{"city_name" => city}}, socket) do
    {_status, cities} = get_city_coordinates(city)
    {:noreply, stream(socket, :resulting_cities, cities)}
  end

  def handle_event("set_favorite", params, socket) do
    socket =
      case Locations.create_user_favorite_location(socket.assigns.current_user, params) do
        {:ok, _location} -> socket
        {:error, _error} -> put_flash(socket, :error, "something went wrong")
      end

    {:noreply, socket}
  end

  def get_city_coordinates(city) do
    url = "#{@api_url}?q=#{URI.encode(city)}&limit=5&appid=#{@api_key}"

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url) do
      {:ok, get_cities_info(body)}
    else
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        IO.inspect("Failed to get a city #{status_code}")
        {:error, []}

      {:error, reason} ->
        IO.inspect("Failed to get a city #{reason}")
        {:error, []}
    end
  end

  defp get_cities_info(body) do
    body
    |> Jason.decode!()
    |> Enum.with_index()
    |> Enum.map(fn {city, idx} ->
      %{
        id: "city_#{idx}",
        lat: city["lat"],
        lon: city["lon"],
        name: city["name"],
        type: "city",
        metadata: %{
          state: city["state"],
          country: city["country"]
        }
      }
    end)
  end
end
