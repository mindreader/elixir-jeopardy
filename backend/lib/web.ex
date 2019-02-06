defmodule JeopardyWeb do
  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: JeopardyWeb

      import Plug.Conn
      import JeopardyWeb.Router.Helpers
    end
  end

  def view do

    quote do
      use Phoenix.View, root: "lib/web/templates",
                        namespace: __MODULE__

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]

      import JeopardyWeb.Router.Helpers
      # import JeopardyWeb.ErrorHelpers
      # import JeopardyWeb.Gettext
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
