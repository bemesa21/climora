defmodule ClimoraWeb.CityLive do
  use ClimoraWeb, :live_view

  @current_weather_api_url "https://api.openweathermap.org/data/2.5/weather"
  @weather_data_api_url "https://api.openweathermap.org/data/3.0/onecall"

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

    <div :if={!is_nil(@city_temperature)} class="my-4">
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
    data = get_current_city_weather(city)

    next_hours_weather =
      get_next_hours_weather(city)

    next_days_weather = get_next_days_weather(city)

    {:ok,
     assign(socket,
       city: city,
       city_temperature: data,
       next_hours_weather: next_hours_weather,
       next_days_weather: next_days_weather
     )}
  end

  def get_next_hours_weather(%{lat: lat, lon: lon}) do
    url =
      "#{@weather_data_api_url}?lat=#{URI.encode(to_string(lat))}&lon=#{URI.encode(to_string(lon))}&exclude=current,minutely,daily,alerts&appid=#{@api_key}&units=metric&lang=sp"

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url) do
      response = JSON.decode!(body)

      response["hourly"]
      |> Enum.map(fn x ->
        {date, time} = to_local_date(x["dt"])

        %{
          temp: x["temp"],
          time: time,
          date: date
        }
      end)
    else
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        IO.inspect("Failed to get a city #{status_code}")
        nil

      {:error, reason} ->
        IO.inspect("Failed to get a city #{reason}")
        nil
    end
  end

  def get_next_days_weather(%{lat: lat, lon: lon}) do
    url =
      "#{@weather_data_api_url}?lat=#{URI.encode(to_string(lat))}&lon=#{URI.encode(to_string(lon))}&exclude=current,minutely,hourly,alerts&appid=#{@api_key}&units=metric&lang=sp"

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url) do
      response = JSON.decode!(body)

      response["daily"]
      |> IO.inspect()
      |> Enum.map(fn x ->
        {date, _time} = to_local_date(x["dt"])

        %{
          min_temp: x["temp"]["min"],
          max_temp: x["temp"]["max"],
          date: date
        }
      end)
    else
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        IO.inspect("Failed to get a city #{status_code}")
        nil

      {:error, reason} ->
        IO.inspect("Failed to get a city #{reason}")
        nil
    end
  end

  def get_current_city_weather(%{lat: lat, lon: lon}) do
    url =
      "#{@current_weather_api_url}?lat=#{URI.encode(to_string(lat))}&lon=#{URI.encode(to_string(lon))}&appid=#{@api_key}&units=metric"

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
