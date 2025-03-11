defmodule ClimoraWeb.CityLive do
  use ClimoraWeb, :live_view

  alias Climora.OpenWeatherClient

  def render(assigns) do
    ~H"""
    <.header>
      <span class="text-xl font-bold text-gray-800">{@city.name} - {@city.metadata["state"]}</span>

      <:actions>
        <.link navigate={~p"/"}>
          <button class="rounded-lg bg-zinc-100 px-2 py-1 hover:bg-zinc-200/80 bg-gray-200 text-black">
            Go to your favorite cities
          </button>
        </.link>
      </:actions>
    </.header>

    <div :if={!is_nil(@current_weather)} class="my-4 p-4 bg-white rounded-lg shadow-md">
      <h3 class="font-bold text-xl text-gray-800 mb-4">Current weather</h3>
      
    <!-- Temperature Section -->
      <ul class="mb-4">
        <li class="flex items-center">
          <span class="font-semibold text-lg text-gray-900 mr-2">Temperature:</span>
          <span class="text-lg font-light">{@current_weather["main"]["temp"]} °C</span>
        </li>
      </ul>
      
    <!-- Min and Max Temperature Section -->
      <div class="flex space-x-6">
        <div class="w-1/2">
          <p class="px-4 font-semibold text-lg text-gray-900 mb-2">Minimum Temperature</p>
          <p class="px-4 text-base font-light">{@current_weather["main"]["temp_min"]} °C</p>
        </div>
        <div class="w-1/2">
          <p class="px-4 font-semibold text-lg text-gray-900 mb-2">Maximum Temperature</p>
          <p class="px-4 text-base font-light">{@current_weather["main"]["temp_max"]} °C</p>
        </div>
      </div>
    </div>

    <div :if={!is_nil(@next_hours_weather)} class="my-4 p-4 bg-white rounded-lg shadow-md">
      <h3 class="font-bold text-xl text-gray-800 mb-4">Temperature next 24 hours</h3>

      <.table id="weather" rows={@next_hours_weather} class="min-w-full table-auto">
        <:col :let={temp} label="Date" class="px-4 py-2 text-left">{temp.date}</:col>
        <:col :let={temp} label="Time" class="px-4 py-2 text-center">{temp.time}</:col>
        <:col :let={temp} label="Temperature" class="px-4 py-2 text-center">{temp.temp} °C</:col>
      </.table>
    </div>

    <div :if={!is_nil(@next_days_weather)} class="my-4 p-4 bg-white rounded-lg shadow-md">
      <h3 class="font-bold text-xl text-gray-800 mb-4">Min and max temperatures next 7 days</h3>

      <.table id="weather_per_day" rows={@next_days_weather} class="min-w-full table-auto">
        <:col :let={temp} label="Date" class="px-4 py-2 text-left">{temp.date}</:col>
        <:col :let={temp} label="Min temperature" class="px-4 py-2 text-center">
          {temp.min_temp} °C
        </:col>
        <:col :let={temp} label="Max temperature" class="px-4 py-2 text-center">
          {temp.max_temp} °C
        </:col>
      </.table>
    </div>
    """
  end

  def mount(params, _session, socket) do
    city = Climora.Locations.get_location_by_coordinates(params)

    socket =
      set_current_city_weather(socket, city)
      |> set_next_days_weather(city)
      |> set_next_hours_weather(city)
      |> assign(:city, city)

    {:ok, socket}
  end

  def set_next_hours_weather(socket, params) do
    case OpenWeatherClient.get_next_hours_weather(params) do
      {:ok, data} ->
        formated_data =
          data["hourly"]
          |> Enum.map(fn x ->
            {date, time} = to_local_date(x["dt"])

            %{
              temp: x["temp"],
              time: time,
              date: date
            }
          end)

        assign(socket, :next_hours_weather, formated_data)

      {:error, _reason} ->
        socket
        |> assign(error: "Failed to fetch hourly weather forecast")
        |> assign(:next_hours_weather, nil)
    end
  end

  def set_next_days_weather(socket, params) do
    case OpenWeatherClient.get_next_days_weather(params) do
      {:ok, data} ->
        formated_data =
          data["daily"]
          |> Enum.map(fn x ->
            {date, _time} = to_local_date(x["dt"])

            %{
              min_temp: x["temp"]["min"],
              max_temp: x["temp"]["max"],
              date: date
            }
          end)

        assign(socket, :next_days_weather, formated_data)

      {:error, _reason} ->
        socket
        |> assign(error: "Failed to fetch daily weather forecast")
        |> assign(:next_days_weather, nil)
    end
  end

  def set_current_city_weather(socket, params) do
    case OpenWeatherClient.get_current_city_weather(params) do
      {:ok, data} ->
        assign(socket, :current_weather, data)

      {:error, _reason} ->
        socket
        |> assign(error: "Failed to fetch city data")
        |> assign(:current_weather, nil)
    end
  end

  defp to_local_date(unix_timestamp) do
    unix_timestamp
    |> DateTime.from_unix!(:second)
    |> DateTime.shift_zone("America/Mexico_City")
    |> then(fn {:ok, date} -> date end)
    |> format_date_time()
  end

  defp format_date_time(datetime) do
    date_time_str = DateTime.to_string(datetime)

    [date, time_with_zone, _, _timezone] = String.split(date_time_str, " ")
    [time, _zone] = String.split(time_with_zone, "-")

    {date, time}
  end
end
