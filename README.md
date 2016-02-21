# Erobot

XMPP bot in Elixir

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add erobot to your list of dependencies in `mix.exs`:

        def deps do
          [{:erobot, "~> 0.0.1"}]
        end

  2. Ensure erobot is started before your application:

        def application do
          [applications: [:erobot]]
        end

## Standalon run for hacking

Compile with ```mix```, then run with ```eix -s mix```

Connect to room with ```Erobot.Controller.connect options```
Send message with

```Erobot.Controller.connected |> Map.keys |> hd |> Erobot.Worker.message "yo!"```
