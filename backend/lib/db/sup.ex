defmodule Jeopardy.DB.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do
    children = [
      {Postgrex,
        name: Jeopardy.DB,
        hostname: "db",
        username: opts |> Keyword.get(:dbuser),
        password: opts |> Keyword.get(:dbpass),
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
