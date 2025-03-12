defmodule Climora.HomeyLiveTest do
  use ClimoraWeb.ConnCase
  import Phoenix.LiveViewTest
  import Climora.AccountsFixtures

  describe "Add and display new favorite city" do
    test "adds a new city when interacting with the add modal", %{conn: conn} do
      conn = log_in_user(conn, user_fixture())
      # Step 1: Show an empty list message when there's no favorite cities
      {:ok, view, _html} = live(conn, "/")

      assert has_element?(view, "p", "You don't have any favorite cities yet.")

      # Step 2: Click the add_new_city_button
      view
      |> element("#add_new_city")
      |> render_click()

      assert has_element?(view, "#city_search_modal")

      ## Step : Search for a city by typing in the input
      form = form(view, "#search_cities_form", cities_search: %{city_name: "Mexico"})
      render_submit(form)

      # 5 elements were rendered in response
      for name <- ["Missouri - US", "- MX", "New York - US", "Pampanga - PH", "Maine - US"] do
        assert has_element?(view, "div", name)
      end

      # Step 5: Click the heart button to favorite the city
      view
      |> element("#resulting_cities-Mexico1_no_solid")
      |> render_click()

      # the solid heart appear, and the other dissapear
      refute has_element?(view, "#resulting_cities-Mexico1_no_solid.hidden")
      assert has_element?(view, "#resulting_cities-Mexico1_solid.hidden")

      # Step 6: simulate the modal was closed
      render_patch(view, ~p"/")

      # Verify that the new city appears in the list of favorite cities
      assert has_element?(view, "p", "Missouri - US")
      refute has_element?(view, "p", "Maine - US")
    end
  end
end
