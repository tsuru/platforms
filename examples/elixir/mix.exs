defmodule App.Mixfile do
  use Mix.Project

  def project do
    [app: :app,
     version: "0.0.1",
     elixir: ">= 1.2.0",
     deps: deps]
  end

  # Configuration for the OTP application
  # Type `mix help compile.app` for more information
  def application do
    [ mod: { App, [] },
      applications: [:logger, :cowboy]]
  end

  # Dependencies can be Hex packages:
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:cowboy, "~> 1.0.0"}]
  end
end
