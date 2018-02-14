defmodule Question do
  defstruct category: nil,
            question: nil,
            answer: nil,
            gamenum: nil,
            round: nil,
            qidx: nil

  def load_all do
    Path.wildcard("questions/*.q") |> Enum.map(&Path.basename/1) |> Enum.map(&Path.rootname/1) |> Enum.map(&load/1)
  end

  def save_all(questions) do
    case File.mkdir("questions") do
      val when val in [:ok, {:error, :eexist}] -> questions |> Enum.each(&save/1)
      val -> IO.puts("Could not create questions directory."); {:error, val}
    end
  end

  def load(fname) do
    "questions/#{fname}.q" |> File.read! |> Poison.decode!(as: %Question{})
  end

  def save(%Question{} = q) do
    fname = "#{q.gamenum}_#{q.round}_" <> case q.qidx do
      :fj -> "fj"
      [col,num] -> "#{col}_#{num}"
    end

    json = Poison.encode!(q)
    File.write("questions/#{fname}.q", json)
  end

  def categories(qs) do
    qs |>  Enum.reduce(MapSet.new, fn q, accum ->
      accum |> MapSet.put(q.category)
    end)
  end

  def categories_by_popularity(xs) do
    xs |> Enum.reduce(%{}, fn (x,accum) ->
      accum |> Map.update(x.category, 1, fn x -> x + 1 end)
    end)
   # |> Enum.to_list |> Enum.sort_by(fn {_cat,n} -> n end)
   # |> Enum.reverse
  end

  def by_category(xs, category) do
    xs |> Enum.filter(fn x -> x.category == category end)
  end


  def get_random_category(qs) do
    qs |> categories |> Enum.random
  end

  def get_random_weighted_category(qs) do
    r = qs |> Enum.count |> :rand.uniform |> (fn x -> x + 1 end).()

    qs |> categories_by_popularity
      |> Enum.map_reduce(0, fn {cat,n},acc -> {{cat,n + acc},n+acc} end)
      |> elem(0) |> Enum.drop_while(fn {_cat,n} -> n <= r end) |> hd |> elem(0)
  end

  def ask(%Question{} = q) do
    IO.gets([q.category, "\n", q.question])
    IO.puts([q.answer, "\n"])
    nil
  end

  def random(xs) do
    xs |> Enum.random
  end
end
