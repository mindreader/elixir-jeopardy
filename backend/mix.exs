defmodule Jeopardy.Mixfile do
  use Mix.Project

  def project do
    [app: :jeopardy,
     version: "0.2.0",
     elixir: "~> 1.7.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]


  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [
      extra_applications: [:logger],
      mod: {Jeopardy.Application, []},
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"}, # only for live reloading
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:httpotion, "~> 3.0"},
      {:postgrex, "~> 0.14"},
      {:floki, "~> 0.19.0"},
#      {:poison, "~> 3.0"},
      {:cors_plug, "~> 1.5"},
      {:plug_cowboy, "~> 2.0"},
      {:distillery, "~> 2.0"}
    ]
  end
end
