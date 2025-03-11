defmodule Climora.OpenWeatherClient do
  @moduledoc """
  Client for interacting with the OpenWeather API.
  """

  @weather_api_key Application.compile_env!(:climora, Climora.WeatherAPI)[:api_key]
  @geocoding_api "http://api.openweathermap.org/geo/1.0/direct"
  @current_weather_api_url "https://api.openweathermap.org/data/2.5/weather"
  @one_call_api "https://api.openweathermap.org/data/3.0/onecall"

  # Generic function to make the API request and return the raw response
  defp fetch_weather_data(url) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url) do
      {:ok, JSON.decode!(body)}
    else
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        IO.inspect("Failed to get weather data, status code: #{status_code}")
        {:error, []}

      {:error, reason} ->
        IO.inspect("Failed to get weather data, reason: #{reason}")
        {:error, []}
    end
  end

  @doc """
  Fetches the coordinates (lat, lon) of a city based on its name.
  """
  def get_city_coordinates(city) do
    url = "#{@geocoding_api}?q=#{URI.encode(city)}&limit=5&appid=#{@weather_api_key}"

    fetch_weather_data(url)
  end

  @doc """
  Fetches the hourly weather forecast for the next 24 hours for the given lat/lon.
  """
  def get_next_hours_weather(%{lat: lat, lon: lon}) do
    url =
      "#{@one_call_api}?lat=#{URI.encode(to_string(lat))}&lon=#{URI.encode(to_string(lon))}&exclude=current,minutely,daily,alerts&appid=#{@weather_api_key}&units=metric&lang=sp"

    fetch_weather_data(url)
  end

  @doc """
  Fetches the daily weather forecast for the next 7 days for the given lat/lon.
  """
  def get_next_days_weather(%{lat: lat, lon: lon}) do
    url =
      "#{@one_call_api}?lat=#{URI.encode(to_string(lat))}&lon=#{URI.encode(to_string(lon))}&exclude=current,minutely,hourly,alerts&appid=#{@weather_api_key}&units=metric&lang=sp"

    fetch_weather_data(url)
  end

  @doc """
  Fetches the current weather for a city based on lat/lon.
  """
  def get_current_city_weather(%{lat: lat, lon: lon}) do
    url =
      "#{@current_weather_api_url}?lat=#{URI.encode(to_string(lat))}&lon=#{URI.encode(to_string(lon))}&appid=#{@weather_api_key}&units=metric"

    fetch_weather_data(url)
  end
end
