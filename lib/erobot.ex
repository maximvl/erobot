defmodule Erobot do
  use Application

  def start(_type, _args) do
    Erobot.Supervisor.start_link
  end

  def r do
    env = Atom.to_string Mix.env
    deps_dir = "_build/#{env}/lib"
    new_deps = deps_dir |> File.ls  |> elem(1) |>
      Enum.map(&([deps_dir, &1, "ebin"] |> Path.join |> Path.expand |> String.to_char_list)) |>
      Enum.filter(&(not &1 in :code.get_path))
    for d <- new_deps, do: Code.append_path d
  end
end

defmodule Erobot.Message do
  defstruct to: "", from: "", body: "", params: %{}, source: nil
end

defmodule Erobot.Supervisor do
  use Supervisor
  alias Erobot.Controller

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [worker(Controller, [Controller])]
    supervise(children, strategy: :one_for_one)
  end
end
