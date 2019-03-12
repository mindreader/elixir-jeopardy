defmodule JeopardyWeb.Router do
  use JeopardyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end


  scope "/api", JeopardyWeb do
    pipe_through :api
    get "/categories/random", API, :random_weighted_categories
    get "/questions/bycategory/:category", API, :questions_by_category
  end
end

defmodule JeopardyWeb.ErrorView do

  def render("404.json",_) do
    %{success: false, message: "route not found"}
  end

  def render("404.html",_) do
    "route not found"
  end
  def render(_,_) do
    "internal server error"
  end
end
#defmodule JeopardyWeb.IndexRoute do
#  use Plug.Router
#
#  plug Plug.Static, at: "/", from: "priv/static"
#  plug :match
#  plug :dispatch
#
#  # This allows
#
#
#  # TODO I would strongly prefer to send this through the same
#  # block of static code in lib/web/endpoint.ex,
#  # but this will be fine for now.
#  get "/" do
#    send_file(conn, 200, Application.app_dir(:jeopardy, "priv/static/index.html")) |> halt
#  end
#
#  match _ do
#    conn
#  end
#end
