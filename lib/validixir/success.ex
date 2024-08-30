defmodule Validixir.Success do
  @moduledoc """
  Module containing data definition and functionality concering a Success.
  A Success is a :ok tuple representing a successful validation of a candidate.

  {:ok, candidate}
  """

  @type some_inner_t :: any()
  @type t(inner_t) :: {:ok, inner_t}

  @doc ~S"""
  Smart constructor of a success.
  """
  @spec make(some_inner_t()) :: t(some_inner_t())
  def make(candidate), do: {:ok, candidate}

  @doc ~S"""
  Applies a function to the candidate of a success.

  ## Examples

      iex> Validixir.Success.map(Validixir.Success.make(0), fn a -> a + 1 end)
      {:ok, 1}
  """
  @spec map(t(some_inner_t()), (some_inner_t() -> any())) :: t(any())
  def map({:ok, candidate}, f), do: f.(candidate) |> make()

  @doc ~S"""
  Returns true if a value is a success.

  ## Examples

      iex> f = Validixir.Failure.make([])
      iex> Validixir.Success.success?(f)
      false

      iex> s = Validixir.Success.make(1)
      iex> Validixir.Success.success?(s)
      true
  """
  @spec success?(any()) :: boolean()
  def success?({:ok, _}), do: true
  def success?(_), do: false
end
