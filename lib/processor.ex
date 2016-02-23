defmodule Erobot.Macros do
  defmacro defhandler(name, do: block) do
    {name, _, _} = name
    quote do
      def unquote(name)(var!(state)), do: unquote(block)
    end
  end
end

defmodule Erobot.Processor do
  require Logger

  alias Erobot.Message
  alias Erobot.Util
  alias Erobot.Worker
  
  import Erobot.Macros

  defmodule State do
    defstruct msg: nil
  end

  defhandler strip do
    {:cont, put_in(state.msg.body, String.strip(state.msg.body))}
  end

  defhandler link do
    cond do
      Regex.match? ~r{http[s]?://}, state.msg.body ->
        state.msg.body |> Util.get_title |> reply(state.msg.source)
        {:halt, state}
      Regex.match? ~r{www.}, state.msg.body ->
        state.msg.body |> Util.get_title |> reply(state.msg.source)
        {:halt, state}
      true ->
        {:cont, state}        
    end
  end

  def process(%Message{}=msg) do
    spawn(Erobot.Processor, :do_process, [%{msg: msg}])
  end

  def do_process(state) do
    Enum.reduce_while handlers, state, &(&1.(&2))
  end

  def handlers do
    [&strip/1, &link/1]
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
