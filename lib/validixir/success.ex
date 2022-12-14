defmodule Validixir.Success do
  @moduledoc """
  Module containing data definition and functionality concering a Success.
  An Succes is a struct representing a successful validation.

  A Success consists of the following:

  * A candidate, representing the value that was validated.
  """

  alias __MODULE__

  @type some_inner_t :: any()
  @type t(inner_t) :: %Success{candidate: inner_t}
  @enforce_keys [:candidate]
  defstruct [:candidate]

  @doc ~S"""
  Smart constructor of a success.
  """
  @spec make(some_inner_t()) :: t(some_inner_t())
  def make(candidate), do: %Success{candidate: candidate}

  @doc ~S"""
  Applies a function to the candidate of a success.

  ## Examples

      iex> Validixir.Success.map(Validixir.Success.make(0), fn a -> a + 1 end)
      %Validixir.Success{candidate: 1}
  """
  @spec map(t(some_inner_t()), (some_inner_t() -> any())) :: t(any())
  def map(%Success{candidate: candidate}, f), do: f.(candidate) |> make()

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
  def success?(%Success{}), do: true
  def success?(_), do: false
end
