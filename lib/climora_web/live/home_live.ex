defmodule ClimoraWeb.HomeLive do
  use ClimoraWeb, :live_view

  @api_url "http://api.openweathermap.org/geo/1.0/direct"
  @api_key ""

  def render(assigns) do
    ~H"""
    <.header>
      Weather
    </.header>

    <.simple_form for={@cities_search} phx-update="ignore" phx-submit="search_city">
      <div>
        <div class="flex flex-col p-2 py-6 m-h-screen">
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
    """
  end

  def mount(_params, _session, socket) do
    socket = assign(socket, :hola, :hye)

    form = to_form(%{"city_name" => ""}, as: "cities_search")
    {:ok, assign(socket, :cities_search, form)}
  end

  def handle_event("search_city", %{"cities_search" => %{"city_name" => city}}, socket) do
    get_city_coordinates(city)

    {:noreply, socket}
  end

  def get_city_coordinates(city) do
    url = "#{@api_url}?q=#{URI.encode(city)}&limit=2&appid=#{@api_key}"

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url) do
      response = Jason.decode!(body) |> IO.inspect()
      {:ok, response}
    else
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        IO.inspect("Failed to get a city #{status_code}")

      {:error, reason} ->
        IO.inspect("Failed to get a city #{reason}")
    end
  end
end
