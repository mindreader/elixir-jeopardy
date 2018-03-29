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

# TODO I'd love to have an openapi specification for this
# https://github.com/mbuhot/open_api_spex
defmodule JeopardyWeb.API do
  use JeopardyWeb, :controller

  @category_num_def "5"
  @category_num_max "10"

  def random_weighted_categories(conn, params) do

    # TODO investigate simpler argument validation.  Preferably something
    # that doesn't require ecto.
    num = (params["num"] || @category_num_def) |>
      String.to_integer |> min(@category_num_max)

    conn |> success(%{
      categories: Jeopardy.get_random_weighted_categories(num)
    })
  end

  def questions_by_category(conn, params) do

    case Jeopardy.get_category_and_questions(params["category"]) do
      %{questions: []} -> conn |> failure(404, "No such category")
      res ->
        conn |> success(%{
          category: res.category,
          questions: res.questions |> Enum.map(&Question.slim/1),
        })
    end
  end

  def success(conn, m) do
    conn |> json(m |> Map.put(:success, true))
  end

  def failure(conn, code, message) when is_integer(code) do
    conn |> put_status(code) |>
      json(%{success: false, message: message})
  end
end
