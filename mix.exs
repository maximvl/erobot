defmodule Erobot.Mixfile do
  use Mix.Project

  def project do
    [app: :erobot,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :romeo, :httpoison],
     mod: {Erobot, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:romeo, "~> 0.4.0"},
     {:exml, github: "esl/exml"},
     {:httpoison, "~> 0.8.1"},
     {:floki, "~> 0.7.1"},
     {:anaphora, "~> 0.1.1"}]
  end
end
