# TODO I'd love to have an openapi specification for this
# https://github.com/mbuhot/open_api_spex

require Logger

defmodule JeopardyWeb.API do
  use JeopardyWeb, :controller

  @category_num_def "5"
  @category_num_max "10"

  def random_weighted_categories(conn, params) when is_map(params) do
    num = (params["num"] || @category_num_def)
      |> String.to_integer |> min(@category_num_max)

    conn |> random_weighted_categories(num)
  end

  def random_weighted_categories(conn, num) when is_integer(num) do
    conn |> render(:random_weighted_categories, %{
      categories: Jeopardy.get_random_weighted_categories(num)
    })
  end

  def questions_by_category(conn, params) when is_list(params) do
    case params["category"] do
      nil -> conn |> failure(400, "category required.")
      str ->
        if str |> String.length() > 200 do
        conn |> failure(400, "category too long")
        else
      conn |> questions_by_category(str)
        end
    end
  end
  def questions_by_category(conn, category) when is_bitstring(category) do

    case Jeopardy.get_category_and_questions(category) do
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
    conn |> put_status(code) |> render(:failure, %{
      message: message
    })
  end
end
