defmodule Pigpiox.Mixfile do
  use Mix.Project

  def project do
    [
      app: :pigpiox,
      version: "0.1.2",
      elixir: "~> 1.5",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      name: "Pigpiox",
      source_url: "https://github.com/tokafish/pigpiox",
      docs: [
        main: "Pigpiox",
        extras: ["README.md"]
      ],
      package: package(),
      description: description()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Pigpiox.Application, []}
    ]
  end

  defp description do
    """
    Use pigpiod on the Raspberry Pi.
    """
  end

  defp package do
    %{files: ["lib", "test", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Tommy Fisher"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/tokafish/pigpiox"}}
  end

  defp deps do
    [
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
    ]
  end
end
