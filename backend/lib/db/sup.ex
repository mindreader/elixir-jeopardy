defmodule Jeopardy.DB.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do
    children = [
      {Postgrex,
        name: Jeopardy.DB,
        hostname: opts |> Keyword.get(:db_host) || raise("db_host required"),
        username: opts |> Keyword.get(:db_user) || raise("db_user required"),
        password: opts |> Keyword.get(:db_pass) || raise("db_pass required"),
        database: "jeopardy"
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end
end
