defmodule Erobot.Worker do
  use GenServer
  require Logger

  alias Romeo.Connection
  alias Romeo.Stanza
  alias Erobot.Message
  alias Erobot.Processor

  def start(opts) do
    GenServer.start(__MODULE__, opts, [])
  end

  def stop(pid) do
    try do
      GenServer.call(pid, :stop)
    catch
      :exit, _ -> Process.exit(pid, :forsed)
    end
    :ok
  end

  def message(pid, msg) do
    GenServer.cast(pid, {:message, msg})
  end

  # Callbacks

  def init(opts) do
    myjid = "#{opts[:room]}/#{opts[:nickname]}"
    {:ok, pid} = Connection.start_link opts
    {:ok, %{opts: opts, pid: pid, myjid: myjid}}
  end

  def handle_call(:stop, _from, state) do
    Connection.close state[:pid]
    {:stop, :normal, :ok, state}
  end

  def handle_cast({:message, msg}, state) do
    Connection.send(state[:pid],
                    Stanza.groupchat(state[:opts][:room], msg))
    {:noreply, state}
  end

  def handle_info(:connection_ready, state) do
    Connection.send(state[:pid],
                    Stanza.join(state[:opts][:room],
                                state[:opts][:nickname]))
    {:noreply, state}
  end

  def handle_info({:stanza, %Stanza.Presence{}}, state) do
    {:noreply, state}
  end

  def handle_info({:stanza, %Stanza.IQ{}}, state) do
    {:noreply, state}
  end

  def handle_info({:stanza, %Stanza.Message{from: myjid}},
                  %{myjid: myjid}=state) do
    {:noreply, state}
  end

  def handle_info({:stanza, %Stanza.Message{}=msg}, state) do
    Processor.process %Message{from: msg.from, body: msg.body,
                               source: self}
    {:noreply, state}
  end

  def handle_info(data, state) do
    Logger.error :io_lib.format("~p", [data])
    {:noreply, state}
  end
end
