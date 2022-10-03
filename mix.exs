defmodule Validixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :validixir,
      version: "1.0.0",
      elixir: "~> 1.13",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:currying, "~> 1.0.3"}
    ]
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "validixir",
      # These are the default files included in the package
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/smoes/validixir"},
      source_url: "https://github.com/smoes/validixir",
      description: "Validixir brings powerful and reusable applicative-like validation to Elixir."
    ]
  end
end
