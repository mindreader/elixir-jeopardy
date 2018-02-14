defmodule Jeopardy.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(nil) do
    children = [
      worker(Jeopardy.QuestionServer, [])
    ]
    opts = [strategy: :one_for_one]
    supervise(children, opts)

  end
end

defmodule Jeopardy.QuestionServer do
  use GenServer

  def start_link do
    IO.puts("loading questions")
    qs = Question.load_all
    IO.puts("finished loading")

    GenServer.start_link(__MODULE__, qs, name: __MODULE__ )
  end

  def init(qs) do
    {:ok, qs}
  end



  def handle_call(:count, _from, qs) do
    {:reply, qs |> Enum.count, qs}
  end

  def handle_call(:categories, _from, qs) do
    {:reply, qs |> Question.categories, qs}
  end
  
  def handle_call(:categories_by_popularity, _from, qs) do
    {:reply, qs |> Question.categories_by_popularity, qs}
  end

  def handle_call(:get_random_category, _from, qs) do
    {:reply, qs |> Question.get_random_category, qs}
  end

  def handle_call(:get_random_weighted_category, _from, qs) do
    {:reply, qs |> Question.get_random_weighted_category, qs}
  end

  def handle_call(:ask_random_weighted_category, _from, qs) do
    cat = qs |> Question.get_random_weighted_category
    {:reply, qs |> Question.by_category(cat), qs}
  end
end

defmodule Jeopardy do
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
    GenServer.call(Jeopardy.QuestionServer, :get_random_weighted_category)
  end

  def ask_random_weighted_category do
    GenServer.call(Jeopardy.QuestionServer, :ask_random_weighted_category)
      |> Enum.each(&Question.ask/1)
  end
end
