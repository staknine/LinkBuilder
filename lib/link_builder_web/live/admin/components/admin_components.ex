defmodule LinkBuilderWeb.Live.Admin.Components.AdminComponents do
  defmacro __using__(_opts) do
    quote do
      import LinkBuilderWeb.Live.Admin.Components.ModalComponent
    end
  end
end
