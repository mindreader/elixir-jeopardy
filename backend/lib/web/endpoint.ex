defmodule JeopardyWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :jeopardy

  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.

  # create react app places its static files in non standard directories

  # serve "/" as if it were "index.html"
  # plug JeopardyWeb.IndexRoute

  plug Plug.Static,
    at: "/", from: {:jeopardy, "priv/static"}, gzip: false,
    only: ~w(index.html service-worker.js favicon.ico robots.txt)

  plug Plug.Static,
    at: "/static", from: {:jeopardy, "priv/static/static"}, gzip: false,
    only: ~w(css js media)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end


  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason

  plug Plug.MethodOverride
  plug Plug.Head

  plug CORSPlug

  plug JeopardyWeb.Router

  def init(_key, config) do
    if config[:load_from_system_env] do
      port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      {:ok, config}
    end
  end
end
