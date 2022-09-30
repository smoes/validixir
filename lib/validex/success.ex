defmodule Validex.Success do
  @moduledoc """
  Module containing data definition and functionality concering a Success.
  An Succes is a struct representing a successful validation.

  A Success consists of the following:

  * A candidate, representing the value that was validated.
  """

  alias __MODULE__

  @type t() :: %Success{}
  @enforce_keys [:candidate]
  defstruct [:candidate]

  @doc ~S"""
  Smart constructor of a success.
  """
  @spec make(any()) :: t()
  def make(candidate), do: %Success{candidate: candidate}

  @doc ~S"""
  Applies a function to the candidate of a success.

  ## Examples

      iex> Validex.Success.map(Validex.Success.make(0), fn a -> a + 1 end)
      %Validex.Success{candidate: 1}
  """
  @spec map(t(), (any() -> any())) :: t()
  def map(%Success{candidate: candidate}, f), do: f.(candidate) |> make()

  @doc ~S"""
  Returns true if a value is a success.

  ## Examples

      iex> f = Validex.Failure.make([])
      iex> Validex.Success.success?(f)
      false

      iex> s = Validex.Success.make(1)
      iex> Validex.Success.success?(s)
      true
  """
  @spec success?(any()) :: boolean()
  def success?(%Success{}), do: true
  def success?(_), do: false
end
