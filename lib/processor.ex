defmodule Erobot.Processor do
  require Logger

  alias Erobot.Message
  alias Erobot.Util
  alias Erobot.Worker
  
  import Anaphora

  defmodule State do
    defstruct msg: nil
  end

  @source "https://github.com/maximvl/erobot"

  def strip(state) do
    {:cont, put_in(state.msg.body, String.strip(state.msg.body))}
  end

  def link(state) do
    acond do
      Regex.run ~r{http[s]?://[^\s]+}, state.msg.body ->
        it |> Util.get_title |> reply(state.msg.source)
        {:halt, state}
      Regex.run ~r{www.[^\s]+}, state.msg.body ->
        "https://#{it}" |> Util.get_title |> reply(state.msg.source)
        {:halt, state}
      true ->
        {:cont, state}        
    end
  end

  def traktorist(state) do
    cond do
      Regex.match? ~r{(300|тристо|триста)}ui, state.msg.body ->
        reply("#{state.msg.from.resource} отсоси у тракториста",
              state.msg.source)
        {:halt, state}
      true ->
        {:cont, state}
    end
  end

  def commands(state) do
    cond do
      Regex.match? ~r{!handlers}, state.msg.body ->
        h = :io_lib.format("~p", [handlers])
        reply("#{h}", state.msg.source)
        {:halt, state}
      Regex.match? ~r{!source}, state.msg.body ->
        reply(@source, state.msg.source)
        {:halt, state}
      true ->
        {:cont, state}
    end
  end

  def process(%Message{}=msg) do
    spawn(Erobot.Processor, :do_process, [%{msg: msg}])
  end

  def do_process(state) do
    Enum.reduce_while handlers, state, &(apply(__MODULE__, &1, [&2]))
  end

  def handlers do
    [:strip, :link, :traktorist, :commands]
  end
  

  def reply(msg, :test) do
    Logger.warn "#{msg}, :test"
  end

  def reply(msg, to) do
    Worker.message to, msg
    # Logger.warn "#{msg}, #{to}"
  end

  # defmacro interference do
  #   quote do: var!(a) = 1
  # end

  # def test do
  #   a = 5
  #   interference
  #   a
  # end

end
