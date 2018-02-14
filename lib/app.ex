defmodule App.Jeopardy do
  use Application
  def start(_type, _args) do
    Jeopardy.Supervisor.start_link
  end
end
