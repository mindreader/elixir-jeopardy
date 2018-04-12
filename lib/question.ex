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
      "fj" -> "fj"
      :fj -> "fj"
      [col,num] -> "#{col}_#{num}"
    end <> ".q"
  end

  def filename(%Question{} = q) do
    filename(q.gamenum, q.round, q.qidx)
  end

  def load_all do
    Path.wildcard("#{question_dir()}/*.q") |> Enum.map(&Path.basename/1) |> Enum.map(&load/1)
  end

  def question_dir do
    Application.fetch_env!(:jeopardy, :question_dir)
  end

  def save_all(questions) do
    case File.mkdir(question_dir()) do
      val when val in [:ok, {:error, :eexist}] -> questions |> Enum.each(&save/1)
      val -> IO.puts("Could not create questions directory."); {:error, val}
    end
  end

  def load(fname) when is_bitstring(fname) do
    q = "#{question_dir()}/#{fname}" |> File.read! |> Poison.decode!(as: %Question{})

    # some of the questions had their answers inside a single element list during
    # initial scraping (a bug since fixed).
    %Question { q | answer:
      case q.answer do
        [a] -> a
        a -> a
      end
    }
  end

  def save(%Question{} = q) do
    fname = q |> filename
    json = Poison.encode!(q)

    File.write("questions/#{fname}", json)
  end

  def ask(%Question{} = q) do
    IO.gets([q.category, "\n", q.question])
    IO.puts([q.answer, "\n"])
    nil
  end

  # Just the necessary stuff for the web.
  def slim(%Question{question: q, answer: a}) do
    %{question: q, answer: a}
  end

end
