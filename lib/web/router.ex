defmodule JeopardyWeb.Router do
  use JeopardyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
#    plug :token_authentication
#    plug :dispatch
  end

  scope "/api", JeopardyWeb do
    pipe_through :api
    get "/categories", BackendController, :categories
    get "/categories/random", BackendController, :random_category
    get "/categories/random_weighted", BackendController, :random_category_weighted
    get "/questions/:id", BackendController, :question
    get "/questions/bycategory/:category", BackendController, :question
  end

end

defmodule JeopardyWeb.ErrorView do
  use JeopardyWeb, :controller
  def render(_, conn) do
    conn |> send_resp(404, "unknown route")
  end
end

defmodule JeopardyWeb.BackendController do
  use JeopardyWeb, :controller

  def categories(conn, _params) do
    conn |> success(%{
      categories: Jeopardy.categories
    })
  end

  def success(conn, m) do
    conn |> json(m |> Map.put(:success, true))
  end
end
