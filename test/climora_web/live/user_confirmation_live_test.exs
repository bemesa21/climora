defmodule ClimoraWeb.UserConfirmationLiveTest do
  use ClimoraWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Climora.AccountsFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "Confirm user" do
    test "renders confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/confirm/some-token")
      assert html =~ "Confirm Account"
    end
  end
end
