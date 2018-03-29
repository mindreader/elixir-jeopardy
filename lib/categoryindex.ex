defmodule CategoryIndex do
  defstruct categories: %{}

  def index_categories do
    qs = Question.load_all

    %CategoryIndex {
      categories: qs |> Enum.reduce(%{}, fn (x,accum) ->
        qid = x |> Question.unique_id |> Tuple.to_list
        accum |> Map.update(x.category, [qid] , fn x -> [qid | x]
        end)
      end)
    } |> save
  end

  def categories(%CategoryIndex{} = ti) do
    ti.categories |> Map.keys
  end

  def question_count(%CategoryIndex{} = ti) do
    ti |> by_popularity |> Map.values |> Enum.sum
  end

  def by_popularity(%CategoryIndex{} = ti) do
    ti.categories |> Enum.map(fn {t,x} -> {t,x |> length} end) |> Map.new
  end

  def random(%CategoryIndex{} = ti) do
    ti |> categories |> Enum.random
  end

  def random_weighted(%CategoryIndex{} = ti, n) do
    r = ti |> question_count |> :rand.uniform |> (fn x -> x + 1 end).()

    ti |> by_popularity
      |> Enum.map_reduce(0, fn {cat,n},acc -> {{cat,n + acc},n+acc} end)
      |> elem(0) |> Enum.drop_while(fn {_cat,n} -> n <= r end) |> Enum.take(n) |> Enum.map(fn x -> x |> elem(0) end)
  end

  def category_questions(%CategoryIndex{} = ti, category) do
    (ti.categories |> Map.get(category) || []) |> Enum.map(&load_question/1)
  end

  def save(%CategoryIndex{} = idx) do
    idx.categories |> Poison.encode! |> (fn x -> File.write!("questions/category_index.idx", x) end).()
  end

  def load do
    txt = case "questions/category_index.idx" |> File.read do
      {:ok, txt} -> txt |> Poison.decode!
      _ -> File.mkdir("questions"); %{}
    end
    %CategoryIndex{
      categories: txt
    }
  end

  def load_question([gamenum,round,qidx]) do
    Question.filename(gamenum,round,qidx) |> Question.load
  end

end
