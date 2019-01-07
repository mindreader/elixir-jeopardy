defmodule Jeopardy.Scraper do

  def jseason(pagenum) do
    "http://www.j-archive.com/showseason.php?season=#{pagenum}"
  end
  def jpage(pagenum) do
    "http://www.j-archive.com/showgame.php?game_id=#{pagenum}"
  end

  def fetchseason(num) do
    IO.puts("fetching season #{num}")
    case jseason(num) |> HTTPotion.get do
      %HTTPotion.Response{body: html} ->
        html |> Floki.find("div#content td a[href*=showgame") |> Enum.map(fn {"a", [{"href", link}], _} ->
          Regex.named_captures(~r/game_id=(?<gameid>[0-9]+)$/, link)["gameid"] |> String.to_integer
        end)
        _ -> nil
    end |> Enum.map(&fetchgame/1) |> Enum.concat
  end

  def fetchgame(num) when is_integer(num) do
    :timer.sleep(:timer.seconds(1))
    IO.puts("fetching game #{num}")
    case jpage(num) |> HTTPotion.get do
      %HTTPotion.Response{body: html} ->
        1..3 |> Enum.map(fn round -> {round,questions(html, round)} end)
      _ -> nil
    end |> Enum.map(fn {round, qs} ->
      qs |> Enum.map(fn %Question{} = q ->
        %Question{ q | gamenum: num, round: round }
      end)
    end) |> Enum.concat
  end

  def fetchgamehtml(num) when is_integer(num) do
    case jpage(num) |> HTTPotion.get do
      %HTTPotion.Response{body: html} -> html
      _ -> nil
    end
  end

  def categories(html, round) do
    html |> Floki.find("div##{roundid(round)} td.category_name") |> Enum.map(fn x -> delinkify([x])
#      # TODO inner text extraction function?
#      {_el,_attrs,[{"a", _, [{_, _, [cat]}]}]} -> cat
#      {_el,_attrs,[{"a", _, [cat]}]} -> cat
#      {_el,_attrs,[cat]} -> cat
    end)
      |> Enum.zip(1..6) |> Enum.map(fn {x,y} -> {y,x} end) |> Map.new |> (fn x -> x |> Map.put(:final_jeopardy, x[1]) end).()
  end

  def roundid(num) do
    case num do
      1 -> "jeopardy_round";
      2 -> "double_jeopardy_round"
      3 -> "final_jeopardy_round"
    end
  end

  def questions(html, round) do

    cats = categories(html, round)
    answers = answers(html, round) |>  Map.new

    # html |> Floki.find("div##{roundid(round)} td.clue_text") |> Enum.map(fn {_el, attrs, [clue]} -> { attrs |> Map.new |> (fn x -> x["id"] end).() } end)
    html |> Floki.find("div##{roundid(round)} td.clue_text")
      |> Enum.map(fn {_el, attrs, clue} -> {attrs |> Map.new |> (fn x -> x["id"] end).(), clue} end)
      |> Enum.map(fn {id, clue} ->
        {extractClueNums(id), extractClue(clue)}
      end) |> Enum.map(fn
        {{col, num}, %Question{} = q } ->
          %Question { q |
            category: cats[col],
            answer: answers[{col,num}],
            qidx: [col,num]
           # value: numRoundToValue(num,round)
          }
        {:final_jeopardy, %Question{} = q } ->
          %Question { q |
            category: cats[:final_jeopardy],
            answer: answers[:final_jeopardy],
            qidx: :fj
            # value: :infinity
          }
      end)
  end

  def answers(html, round) do
    snippets = html |> Floki.find("div##{roundid(round)} div[onmouseover^=toggle")
    snippets |> Enum.map(fn snip ->
      extractAnswer(snip)
    end)
  end

  def numRoundToValue(num, round) when is_integer(num) and is_integer(round) do
    num * 100 * round
  end

  def extractClueNums(id) do
    case Regex.named_captures(~r/clue_D?J_(?<category>[0-9])_(?<question>[0-9])/, id) do
      nil -> :final_jeopardy
      info -> {info["category"] |> String.to_integer, info["question"] |> String.to_integer}
    end
  end

  def extractClue(clue) when is_list(clue) do
    %Question { question: delinkify(clue) }
  end

  def extractAnswer(x) do
    txt = x |> elem(1) |> Map.new |> (fn x -> x["onmouseover"] end).()
    answer = Regex.run(~r/toggle\('[^']+', '[^']+', '(.*)'\)$/,txt) |> tl |> hd
      |> String.replace("\\", "") |> Floki.find("em.correct_response")
      |> hd |> (fn x -> delinkify([x]) end).()

    case Regex.named_captures(~r/clue_D?J_(?<category>[0-9])_(?<question>[0-9])/, txt) do
      nil -> {:final_jeopardy, answer}
      info -> {{info["category"] |> String.to_integer, info["question"] |> String.to_integer}, answer}
    end
  end

  def delinkify(list) when is_list(list) do
    case list do
      [] -> ""
      [x | xs] when is_list(x) -> delinkify(x) <> delinkify(xs)
      [x | xs] when is_bitstring(x) -> x <> delinkify(xs)
      [{_,_, ls} | xs] when is_list(ls) -> delinkify(ls) <> delinkify(xs)
      [{"br", [], []} | xs] -> delinkify(xs)
    end
  end

end
