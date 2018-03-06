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

  def random_weighted(%CategoryIndex{} = ti) do
    r = ti |> question_count |> :rand.uniform |> (fn x -> x + 1 end).()

    ti |> by_popularity
      |> Enum.map_reduce(0, fn {cat,n},acc -> {{cat,n + acc},n+acc} end)
      |> elem(0) |> Enum.drop_while(fn {_cat,n} -> n <= r end) |> hd |> elem(0)
  end

  def category_questions(%CategoryIndex{} = ti, category) do
    ti.categories |> Map.get(category) |> Enum.map(&load_question/1)
  end

  def save(%CategoryIndex{} = idx) do
    idx.categories |> Poison.encode! |> (fn x -> File.write!("questions/category_index.idx", x) end).()
  end

  def load do
    %CategoryIndex{
      categories: "questions/category_index.idx" |> File.read! |> Poison.decode!
    }
  end

  def load_question([gamenum,round,qidx]) do
    Question.filename(gamenum,round,qidx) |> Question.load
  end
end

defmodule Question do
  defstruct category: nil,
            question: nil,
            answer: nil,
            gamenum: nil,
            round: nil,
            qidx: nil


  def unique_id(%Question{} = q) do
    {q.gamenum, q.round, q.qidx}
  end

  def filename(gamenum, round, qidx) do
     "#{gamenum}_#{round}_" <> case qidx do
      :fj -> "fj"
      [col,num] -> "#{col}_#{num}"
    end <> ".q"
  end

  def filename(%Question{} = q) do
    filename(q.gamenum, q.round, q.qidx)
  end

  def load_all do
    Path.wildcard("questions/*.q") |> Enum.map(&Path.basename/1) |> Enum.map(&load/1)
  end

  def save_all(questions) do
    case File.mkdir("questions") do
      val when val in [:ok, {:error, :eexist}] -> questions |> Enum.each(&save/1)
      val -> IO.puts("Could not create questions directory."); {:error, val}
    end
  end

  def load(fname) when is_bitstring(fname) do
    "questions/#{fname}" |> File.read! |> Poison.decode!(as: %Question{})
  end

  def save(%Question{} = q) do
    fname = q |> filename
    json = Poison.encode!(q)

    File.write("questions/#{fname}.q", json)
  end

  def ask(%Question{} = q) do
    IO.gets([q.category, "\n", q.question])
    IO.puts([q.answer, "\n"])
    nil
  end
end
