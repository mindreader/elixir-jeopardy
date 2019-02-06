defmodule JeopardyWeb.APIView do
  use JeopardyWeb, :view

  def render("random_weighted_categories.json", %{categories: cats}) do
    %{success: true, categories: cats}
  end

  def render("failure.json", %{message: m}) do
    %{success: false, message: m}
  end
end
