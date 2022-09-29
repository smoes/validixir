defmodule Validex.Success do
  @moduledoc """
  """

  alias __MODULE__

  @type t() :: %Success{}
  @enforce_keys [:candidate]
  defstruct [:candidate]

  @spec make(any()) :: t()
  def make(candidate), do: %Success{candidate: candidate}

  @spec map(t(), (any() -> any())) :: t()
  def map(%Success{candidate: candidate}, f), do: f.(candidate) |> make()

  @spec success?(any()) :: boolean()
  def success?(%Success{}), do: true
  def success?(_), do: false
end
