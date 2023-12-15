defmodule ElixirNsqTestApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_nsq_test_app,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :plug_cowboy, :elixir_nsq],
      mod: {ElixirNsqTestApp.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.4"},
      {:elixir_nsq, github: "benonymus/elixir_nsq", branch: "tweak_child_specs"}
    ]
  end
end
