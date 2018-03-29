defmodule Jeopardy.QuestionServer do
  use GenServer

  def start_link(_args) do
    IO.puts("loading categories")
    ts = CategoryIndex.load
    IO.puts("finished loading")

    GenServer.start_link(__MODULE__, ts, name: __MODULE__ )
  end

  def init(ts) do
    {:ok, ts}
  end

  def handle_call(:get_state, _from, ts) do
    {:reply, ts, ts}
  end


  def handle_call(:count, _from, ts) do
    {:reply, ts |> CategoryIndex.question_count, ts}
  end

  def handle_call(:categories, _from, ts) do
    {:reply, ts |> CategoryIndex.categories, ts}
  end
  
  def handle_call(:categories_by_popularity, _from, ts) do
    {:reply, ts |> CategoryIndex.by_popularity, ts}
  end

  def handle_call(:get_random_category, _from, ts) do
    {:reply, ts |> CategoryIndex.random, ts}
  end

  def handle_call({:get_random_weighted_category, n}, _from, ts) do
    {:reply, ts |> CategoryIndex.random_weighted(n), ts}
  end

  def handle_call(:get_random_weighted_category_and_questions, _from, ts) do
    cat = ts |> CategoryIndex.random_weighted
    {:reply, %{category: cat, questions: CategoryIndex.category_questions(ts, cat)}, ts}
  end
end

defmodule Jeopardy do

  def get_state do
    GenServer.call(Jeopardy.QuestionServer, :get_state)
  end
  def count do
    GenServer.call(Jeopardy.QuestionServer, :count)
  end

  def categories do
    GenServer.call(Jeopardy.QuestionServer, :categories)
  end

  def categories_by_popularity do
    GenServer.call(Jeopardy.QuestionServer, :categories_by_popularity)
  end

  def get_random_category do
    GenServer.call(Jeopardy.QuestionServer, :get_random_category)
  end

  def get_random_weighted_category do
    get_random_weighted_categories(1) |> hd
  end
  def get_random_weighted_categories(n) do
    GenServer.call(Jeopardy.QuestionServer, {:get_random_weighted_category, n})
  end

  def get_random_weighted_category_and_questions do
    GenServer.call(Jeopardy.QuestionServer, :get_random_weighted_category_and_questions)
  end

  def get_random_weighted_category_and_questions_slim do
    GenServer.call(Jeopardy.QuestionServer, :get_random_weighted_category_and_questions)
  end


  def ask_random_weighted_category do
    GenServer.call(Jeopardy.QuestionServer, :get_random_weighted_category_and_questions).questions
      |> Enum.each(&Question.ask/1)
  end

end
