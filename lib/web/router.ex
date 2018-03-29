defmodule JeopardyWeb.Router do
  use JeopardyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
#    plug :token_authentication
#    plug :dispatch
  end

  scope "/api", JeopardyWeb do
    pipe_through :api
    get "/categories/random", API, :random_weighted_categories
    get "/questions/bycategory/:category", API, :questions_by_category
  end

end

defmodule JeopardyWeb.ErrorView do
  use JeopardyWeb, :controller
  def render(_, conn) do
    conn |> send_resp(404, "unknown route")
  end
end
