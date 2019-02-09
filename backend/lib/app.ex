defmodule Jeopardy.Application do
  use Application

  def start(_type, _args) do
    opts = [
      db_host: Application.get_env(:jeopardy, :db_host),
      db_user: Application.get_env(:jeopardy, :db_user),
      db_pass: Application.get_env(:jeopardy, :db_pass),
    ] |> IO.inspect

    Supervisor.start_link([
      Jeopardy.QuestionServer,
      JeopardyWeb.Endpoint,
      {Jeopardy.DB.Supervisor, opts}
    ], strategy: :one_for_one, name: Jeopardy.Supervisor)
  end

#  def config_change(changed, _new, removed) do
#    Jeopardy.Endpoint.config_change(changed, removed)
#    :ok
#  end

end
