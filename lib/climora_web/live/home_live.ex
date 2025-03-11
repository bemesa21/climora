defmodule ClimoraWeb.HomeLive do
  use ClimoraWeb, :live_view
  alias Climora.Locations
  @client Application.compile_env(:climora, Climora.OpenWeatherClient)

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
    {:noreply, set_city_coordinates(socket, city)}
  end

  def handle_event("set_favorite", params, socket) do
    socket =
      case Locations.create_user_favorite_location(socket.assigns.current_user, params) do
        {:ok, _location} -> socket
        {:error, _error} -> put_flash(socket, :error, "something went wrong")
      end

    {:noreply, socket}
  end

  def handle_event(
        "unlike",
        %{
          "dom_id" => dom_id,
          "lat" => lat,
          "lon" => lon
        },
        socket
      ) do
    {:ok, _city} =
      Locations.delete_user_favorite_location(socket.assigns.current_user.id, lat, lon)

    {:noreply, stream_delete_by_dom_id(socket, :favorite_cities, dom_id)}
  end

  def set_city_coordinates(socket, city) do
    case @client.get_city_coordinates(city) do
      {:ok, response} ->
        stream(socket, :resulting_cities, format_city_info(response), reset: true)

      {:error, []} ->
        socket
        |> assign(error: "Failed to fetch city data")
        |> stream(:resulting_cities, [], reset: true)
    end
  end

  defp format_city_info(cities_data) do
    cities_data
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
