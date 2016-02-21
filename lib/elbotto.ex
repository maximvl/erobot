defmodule Erobot do
  use Application

  def start(_type, _args) do
    Erobot.Supervisor.start_link
  end
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
