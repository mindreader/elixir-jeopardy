
defmodule JeopardyWeb.Quiz do
  use JeopardyWeb, :controller

  plug :put_view, JeopardyWeb.PageView

  def categories(conn, _params) do
    conn |> render("quiz.html")
  end
end
