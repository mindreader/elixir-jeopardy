defmodule Jeopardy.Application do
  use Application

  def start(_type, _args) do
    Supervisor.start_link([
      Jeopardy.QuestionServer,
      JeopardyWeb.Endpoint,
      {Jeopardy.DB.Supervisor, [dbuser: "jeopardy", dbpass: "dbpassword"]} # TODO from config!
    ], strategy: :one_for_one, name: Jeopardy.Supervisor)
  end

#  def config_change(changed, _new, removed) do
#    Jeopardy.Endpoint.config_change(changed, removed)
#    :ok
#  end

end
