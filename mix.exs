defmodule Cosmox.MixProject do
  use Mix.Project

  def project do
    [
      app: :cosmox,
      version: "0.1.4",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "Cosmox",
      description: description(),
      package: package(),
      source_url: "https://github.com/MaxDac/cosmox",
      homepage_url: "https://github.com/MaxDac/cosmox",
      docs: [
        main: "Cosmox",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [
        :logger
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.3"},
      {:nestru, "~> 0.2.1"},
      {:finch, "~> 0.13.0"},
      {:timex, "~> 3.7"},
      {:dialyxir, "~> 1.2", only: :dev, runtime: false},
      {:credo, "~> 1.6", only: :dev, runtime: false},
      {:ex_doc, "~> 0.28.5", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Client for Azure CosmosDB REST API for Elixir."
  end

  defp package do
    [
      name: "cosmox",
      files: ~w(lib docs README* mix.exs mix.lock),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/MaxDac/cosmox"}
    ]
  end
end
