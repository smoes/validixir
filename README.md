# Validixir

![Tests](https://github.com/smoes/validixir/actions/workflows/main.yaml/badge.svg)
[![Hex version badge](https://img.shields.io/hexpm/v/validixir.svg)](https://hex.pm/packages/validixir)

Validixir brings powerful and reusable applicative validation to Elixir.

The library was created based on the conviction, that exclusively valid domains objects should be producible, and thus exist.
To implement this requirement, we need an easy yet powerful mechanism of expressing validations. The concept of this library is mainly based on applicative validation from languages like Haskell, with some flavors coming from the dynamically typed nature of Elixir.

To see a complete example of validation with Validixir, check out the included [example-file](test/example.exs) and the corresponding [test-file](test/validixir_test.exs).

## Installation

The package can be installed by adding `validixir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:validixir, "~> 0.1.1"}
  ]
end
```

## Documentation
The documentation can be found on [HexDocs](https://hexdocs.pm/validixir).
