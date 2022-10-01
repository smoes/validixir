defmodule Validixir.Failure do
  @moduledoc """
  Module containing data definition and functionality concering a Failure.
  An Failure is a struct representing a failed validation.

  An Failure consists of the following:

  * A list of Errors, displaying multiple causes for the validation to fail.
  """

  alias __MODULE__
  alias Validixir.Error, as: Error

  @type t :: %Failure{errors: [Error.t()]}
  @enforce_keys [:errors]
  defstruct [:errors]

  @doc ~S"""
  Smart constructor of a failure.
  """
  @spec make([any()]) :: t()
  def make(errors), do: %Failure{errors: errors}

  @doc ~S"""
  Applies a function to each error in a failure's errors.

  ## Examples

      iex> f = Validixir.Failure.make([1, 2, 3])
      iex> Validixir.Failure.map(f, fn a -> a + 1 end)
      %Validixir.Failure{errors: [2,3,4]}
  """
  @spec map(t(), (Error.t() -> Error.t())) :: t()
  def map(%Failure{errors: errors}, f), do: Enum.map(errors, f) |> make()

  @doc ~S"""
  Overrides the context of all errors of a failure.

  ## Examples

      iex> error_1 = Validixir.Error.make(1, :not_allowed, SomeContext)
      iex> error_2 = Validixir.Error.make(2, :not_allowed, SomeOtherContext)
      iex> f = Validixir.Failure.make([error_1, error_2])
      iex> Validixir.Failure.override_error_contexts(f, NewFailureContext)
      %Validixir.Failure{errors: [
          %Validixir.Error{candidate: 1, message: :not_allowed, context: NewFailureContext},
          %Validixir.Error{candidate: 2, message: :not_allowed, context: NewFailureContext}
          ]
      }
  """
  @spec override_error_contexts(t(), any()) :: t()
  def override_error_contexts(failure = %Failure{}, new_context),
    do: map(failure, fn error -> Error.with_context(error, new_context) end)

  @doc ~S"""
  Overrides the message of all errors of a failure.

  ## Examples

      iex> error_1 = Validixir.Error.make(1, :not_allowed, SomeContext)
      iex> error_2 = Validixir.Error.make(2, :also_not_allowed, SomeContext)
      iex> f = Validixir.Failure.make([error_1, error_2])
      iex> Validixir.Failure.override_error_messages(f, :nonono)
      %Validixir.Failure{errors: [
          %Validixir.Error{candidate: 1, message: :nonono, context: SomeContext},
          %Validixir.Error{candidate: 2, message: :nonono, context: SomeContext}
          ]
      }
  """
  @spec override_error_messages(t(), any()) :: t()
  def override_error_messages(failure = %Failure{}, new_message),
    do: map(failure, fn error -> Error.with_message(error, new_message) end)

  @doc ~S"""
  Combines two errors. That is, appending their error list.

  ## Examples

      iex> error_1 = Validixir.Error.make(1, :not_allowed, SomeContext)
      iex> error_2 = Validixir.Error.make(2, :also_not_allowed, SomeContext)
      iex> failure_1 = Validixir.Failure.make([error_1])
      iex> failure_2 = Validixir.Failure.make([error_2])
      iex> Validixir.Failure.combine(failure_1, failure_2)
      %Validixir.Failure{errors: [
          %Validixir.Error{candidate: 1, message: :not_allowed, context: SomeContext},
          %Validixir.Error{candidate: 2, message: :also_not_allowed, context: SomeContext}
          ]
      }
  """
  @spec combine(t(), t()) :: t()
  def combine(f1 = %Failure{errors: e1}, %Failure{errors: e2}),
    do: %Failure{f1 | errors: Enum.concat(e1, e2)}

  @doc ~S"""
  Returns true if a value is a failure.

  ## Examples

      iex> f = Validixir.Failure.make([])
      iex> Validixir.Failure.failure?(f)
      true

      iex> s = Validixir.Success.make(1)
      iex> Validixir.Failure.failure?(s)
      false
  """
  @spec failure?(any()) :: boolean()
  def failure?(%Failure{}), do: true
  def failure?(_), do: false
end
