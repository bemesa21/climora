defmodule Climora.MockOpenWeatherClient do
  @moduledoc """
  Mock Client for testing without calling real OpenWeather API.
  """

  def get_city_coordinates("Mexico") do
    {:ok,
     [
       %{
         "country" => "MX",
         "lat" => 19.4326296,
         "local_names" => %{
           "km" => "ក្រុងម៉ិកស៊ិក",
           "tr" => "Meksika",
           "os" => "Мехико",
           "vo" => "Ciudad de México",
           "bg" => "Мексико",
           "lt" => "Meksikas"
         },
         "lon" => -99.1331785,
         "name" => "Mexico City"
       },
       %{
         "country" => "US",
         "lat" => 39.1697626,
         "lon" => -91.8829484,
         "name" => "Mexico",
         "state" => "Missouri"
       },
       %{
         "country" => "US",
         "lat" => 43.459514,
         "local_names" => %{"en" => "Town of Mexico"},
         "lon" => -76.228818,
         "name" => "Town of Mexico",
         "state" => "New York"
       },
       %{
         "country" => "PH",
         "lat" => 15.0643509,
         "lon" => 120.720544,
         "name" => "Mexico",
         "state" => "Pampanga"
       },
       %{
         "country" => "US",
         "lat" => 44.56112,
         "lon" => -70.545959,
         "name" => "Mexico",
         "state" => "Maine"
       }
     ]}
  end

  def get_city_coordinates(_some_city) do
    {:error, []}
  end
end
