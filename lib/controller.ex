defmodule Erobot.Controller do
  defmodule Connection do
    defstruct pid: nil, monitor: nil, options: nil
  end

  require Logger
  use GenServer

  alias Erobot.Worker
  

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

  def connect(opts) do
    GenServer.call(__MODULE__, {:connect, opts})
  end

  def disconnect(pid) do
    GenServer.cast(__MODULE__, {:disconnect, pid})
  end

  def disconnect do
    GenServer.cast(__MODULE__, :disconnect)
  end

  def connected() do
    GenServer.call(__MODULE__, :connected)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{:connections => %{}}}
  end

  def handle_call({:connect, opts}, _from, state) do
    {:ok, pid} = Worker.start(opts)
    monitor = Process.monitor(pid)
    state2 = put_in(state[:connections][pid],
                    %Connection{pid: pid,
                                monitor: monitor,
                                options: opts})
    {:reply, {:ok, pid}, state2}
  end

  def handle_call(:connected, _from, state) do
    {:reply, state[:connections], state}
  end
  
  def handle_cast({:disconnect, pid}, state) do
    :ok = Worker.stop(pid)
    state2 = put_in(state[:connections],
                    Map.delete(state[:connections], pid))
    {:noreply, state2}
  end

  def handle_cast(:disconnect, state) do
    for {pid, _} <- state[:connections], do: Worker.stop(pid)
    state2 = put_in(state[:connections], %{})
    {:noreply, state2}
  end

  def handle_cast({_tag, _ref, _type, pid, info}, state) do
    opts = state[:connections][pid][:options]
    Logger.warn "#{pid} (#{opts}) terminated: #{info}"
    state2 = put_in(state[:connections],
                    Map.delete(state[:connections], pid))
    {:noreply, state2}
  end

end
