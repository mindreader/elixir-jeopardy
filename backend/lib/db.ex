defmodule Jeopardy.DB do

  def test do
    Postgrex.query(Jeopardy.DB, "select * from questions", [])
  end
#  def save_question(%Question{} = q) do
#    Postgrex.query(Jeopardy.DB, "select * from questions")
#  end
#
#  def load_question do
#    %Question{}
#  end
end
