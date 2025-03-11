defmodule ClimoraWeb.HomeLive do
  alias Climora.Locations
  use ClimoraWeb, :live_view

  @api_url "http://api.openweathermap.org/geo/1.0/direct"
  @api_key ""

  def render(assigns) do
    ~H"""
    <.header>
      {@page_title}
      <:actions>
        <.link patch={~p"/favorite_cities"}>
          <.button class="rounded-lg bg-zinc-100 px-2 py-1 hover:bg-zinc-200/80 bg-gray-200 text-black">
            Add cities
          </.button>
        </.link>
      </:actions>
    </.header>

    <div class="flex justify-center items-center min-h-screen">
      <div
        class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4 w-full max-w-[1200px] mx-auto"
        phx-update="stream"
        id="favorite_cities_grid"
      >
        <!-- Card -->
        <div
          :for={{id, city} <- @streams.favorite_cities}
          class="relative flex flex-col text-gray-700 bg-white shadow-md bg-clip-border rounded-xl"
          id={id}
        >
          <div class="p-6">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 24 24"
              fill="currentColor"
              class="w-12 h-12 mb-4 text-gray-900"
            >
              <path
                fill-rule="evenodd"
                d="M9.315 7.584C12.195 3.883 16.695 1.5 21.75 1.5a.75.75 0 01.75.75c0 5.056-2.383 9.555-6.084 12.436A6.75 6.75 0 019.75 22.5a.75.75 0 01-.75-.75v-4.131A15.838 15.838 0 016.382 15H2.25a.75.75 0 01-.75-.75 6.75 6.75 0 017.815-6.666zM15 6.75a2.25 2.25 0 100 4.5 2.25 2.25 0 000-4.5z"
                clip-rule="evenodd"
              >
              </path>
            </svg>
            <h5 class="block mb-2 font-sans text-xl antialiased font-semibold leading-snug tracking-normal text-blue-gray-900">
              {city.name}
            </h5>
            <p class="block font-sans text-base antialiased font-light leading-relaxed text-inherit">
              {city.metadata["state"]}-{city.metadata["country"]}
            </p>
          </div>
          <div class="p-6 pt-0">
            <.link patch={"~p#{city.lat}/#{city.lon}"}>
              <.button class="flex items-center gap-2 px-4 py-2 font-sans text-xs font-bold text-center text-gray-900 uppercase align-middle transition-all rounded-lg select-none disabled:opacity-50 disabled:shadow-none disabled:pointer-events-none hover:bg-gray-900/10 active:bg-gray-900/20 bg-transparent">
                Learn More
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="2"
                  stroke="currentColor"
                  class="w-4 h-4"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M17.25 8.25L21 12m0 0l-3.75 3.75M21 12H3"
                  >
                  </path>
                </svg>
              </.button>
            </.link>
          </div>
        </div>
      </div>
    </div>

    <!--Cities selector -->
    <.modal :if={@live_action == :edit} id="city_search_modal" show on_cancel={JS.patch(~p"/")}>
      <.header>
        Choose your favorite cities!
      </.header>

      <.simple_form for={@cities_search} phx-update="ignore" phx-submit="search_city">
        <div>
          <div class="flex flex-col p-2  m-h-screen">
            <div class="bg-white items-center justify-between w-full flex rounded-full shadow-lg p-2 mb-5 sticky">
              <.input
                class="font-bold uppercase rounded-full w-full py-4 pl-4 text-gray-700 bg-gray-100 leading-tight focus:outline-none focus:shadow-outline lg:text-sm text-xs"
                field={@cities_search[:city_name]}
                type="text"
              />
              <.button class="bg-gray-600 !p-2 hover:bg-blue-400 cursor-pointer mx-2 rounded-full">
                <svg
                  class="w-6 h-6 text-white"
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                >
                  <path
                    fill-rule="evenodd"
                    d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"
                    clip-rule="evenodd"
                  />
                </svg>
              </.button>
            </div>
          </div>
        </div>
      </.simple_form>
      <div phx-update="stream" id="city_list" class="group">
        <div
          :for={{id, city} <- @streams.resulting_cities}
          class="bg-white top-100 z-40 w-full peer"
          id={id}
        >
          <div class="cursor-pointer w-full border-gray-100 rounded-t border-b">
            <div class="flex w-full items-center p-2 pl-2 border-transparent border-l-2 relative hover:border-teal-100">
              <div class="w-full items-center flex">
                <div class="mx-2 -mt-1 w-full ">
                  {city.name}
                  <div class="text-xs truncate w-full normal-case font-normal -mt-1 text-gray-500">
                    {city.metadata.state} - {city.metadata.country}
                  </div>
                </div>
                <button
                  id={"#{id}_solid"}
                  type="button"
                  class="w-10 flex-none hidden"
                  phx-click={JS.show(to: "##{id}_no_solid") |> JS.hide()}
                >
                  <.icon name="hero-heart-solid" class="w-7 h-7  bg-red-400 border-red " />
                </button>
                <button
                  id={"#{id}_no_solid"}
                  type="button"
                  class="w-10 flex-none"
                  phx-click={
                    JS.show(to: "##{id}_solid") |> JS.hide() |> JS.push("set_favorite", value: city)
                  }
                >
                  <.icon name="hero-heart" class="w-7 h-7 bg-red-400 hover:bg-red-400" />
                </button>
              </div>
            </div>
          </div>
        </div>
        <div :if={@live_action == :edit} class="block group-has-[div.peer]:hidden  h-64"></div>
      </div>
    </.modal>
    <!--Cities selector -->

    """
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:cities_search, to_form(%{"city_name" => ""}, as: "cities_search"))
      |> stream(:resulting_cities, [])

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(
      :page_title,
      "Hey! #{socket.assigns.current_user.email}, here are your favorite cities!"
    )
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
