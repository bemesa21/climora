defmodule ClimoraWeb.CityLive do
  use ClimoraWeb, :live_view

  @current_weather_api_url "https://api.openweathermap.org/data/2.5/weather"
  @weather_data_api_url "https://api.openweathermap.org/data/2.5/weather"

  @api_key ""

  def render(assigns) do
    ~H"""
    <.header>
      {@city.name} - {@city.metadata["state"]}

      <:actions>
        <.link navigate={~p"/"}>
          <.button class="rounded-lg bg-zinc-100 px-2 py-1 hover:bg-zinc-200/80 bg-gray-200 text-black">
            Go to your favorite cities
          </.button>
        </.link>
      </:actions>
    </.header>

    <div :if={!is_nil(@city_temperature)}>
      <h3 class="font-bold">Current weather</h3>
      <ul class="m-5">
        <p class="block mb-2 font-sans text-l antialiased font-semibold leading-snug tracking-normal text-blue-gray-900">
          Temperature:
          <p class="block font-sans text-base antialiased font-light leading-relaxed text-inherit">
            {@city_temperature["main"]["temp"]} °C
          </p>
        </p>
      </ul>
      <ul>
        <div class="flex">
          <div class="m-5">
            <p class="block bold mb-2 font-sans text-l antialiased font-semibold leading-snug tracking-normal text-blue-gray-900">
              Minimum Temperature:
              <p class="block font-sans text-base antialiased font-light leading-relaxed text-inherit">
                {@city_temperature["main"]["temp_min"]} °C
              </p>
            </p>
          </div>
          <div class="m-5">
            <p class="block bold mb-2 font-sans text-l antialiased font-semibold leading-snug tracking-normal text-blue-gray-900">
              Maximum Temperature:
              <p class="block font-sans text-base antialiased font-light leading-relaxed text-inherit">
                {@city_temperature["main"]["temp_max"]} °C
              </p>
            </p>
          </div>
        </div>
      </ul>
    </div>
    <div>
      <h3 class="font-bold">Temperature next 24 hours</h3>
    </div>
    """
  end

  def mount(params, _session, socket) do
    city = Climora.Locations.get_location_by_coordinates(params)
    data = get_current_city_weather(city)
    {:ok, assign(socket, city: city, city_temperature: data)}
  end

  def get_current_city_weather(%{lat: lat, lon: lon}) do
    url =
      "#{@current_weather_api_url}?lat=#{URI.encode(to_string(lat))}&lon=#{URI.encode(to_string(lon))}&appid=#{@api_key}&units=metric"
      |> IO.inspect()

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url) do
      JSON.decode!(body)
    else
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        IO.inspect("Failed to get a city #{status_code}")
        nil

      {:error, reason} ->
        IO.inspect("Failed to get a city #{reason}")
        nil
    end
  end
end
