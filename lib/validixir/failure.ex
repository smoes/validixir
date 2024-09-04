defmodule Validixir.Failure do
  @moduledoc """
  Module containing data definition and functionality concerning a Failure.
  A Failure is a error tuple that contains a Failure struct representing a failed validation.

  A Failure struct consists of the following:

  * A list of Errors, displaying multiple causes for the validation to fail.
  * A message lookup that is a map with all messages as keys. This lookup is
    used internally and should not be used directly.
  """

  alias __MODULE__
  alias Validixir.Error, as: Error

  @type failure_t :: %Failure{errors: [Error.t()], __message_lookup: map()}
  @type t :: {:error, failure_t}
  @enforce_keys [:errors, :__message_lookup]
  defstruct [:errors, :__message_lookup]

  {:error}

  @doc ~S"""
  Smart constructor of a failure.
  """
  @spec make(any()) :: t()
  def make(errors) do
    errors = List.wrap(errors)
    message_lookup = prepare___message_lookup(errors)
    {:error, %Failure{errors: errors, __message_lookup: message_lookup}}
  end

  @doc ~S"""
  Constructs a failure with one error based on error parameters.

  ## Examples

      iex> Validixir.Failure.make_from_error(12, :twelve_not_allowed, SomeContext)
      {:error, %Validixir.Failure{errors: [%Validixir.Error{candidate: 12, message: :twelve_not_allowed, context: SomeContext}], __message_lookup: %{twelve_not_allowed: true}}}
  """
  @spec make_from_error(any(), any(), any()) :: t()
  def make_from_error(candidate, message, context),
    do: [Error.make(candidate, message, context)] |> make()

  @doc ~S"""
  Applies a function to each error in a failure's errors.

  ## Examples

      iex> f = Validixir.Failure.make_from_error(1, :message, :context)
      iex> Validixir.Failure.map(f, fn %Validixir.Error{candidate: c} -> Validixir.Error.make(c + 1, :message_new, :context) end)
      {:error, %Validixir.Failure{errors: [%Validixir.Error{candidate: 2, message: :message_new, context: :context}], __message_lookup: %{message_new: true}}}
  """
  @spec map(t(), (Error.t() -> Error.t())) :: t()
  def map({:error, %Failure{errors: errors}}, f), do: Enum.map(errors, f) |> make()

  @doc ~S"""
  Overrides the context of all errors of a failure.

  ## Examples

      iex> error_1 = Validixir.Error.make(1, :not_allowed, SomeContext)
      iex> error_2 = Validixir.Error.make(2, :not_allowed, SomeOtherContext)
      iex> f = Validixir.Failure.make([error_1, error_2])
      iex> Validixir.Failure.override_error_contexts(f, NewFailureContext)
      {:error, %Validixir.Failure{errors: [
          %Validixir.Error{candidate: 1, message: :not_allowed, context: NewFailureContext},
          %Validixir.Error{candidate: 2, message: :not_allowed, context: NewFailureContext}
          ],
        __message_lookup: %{not_allowed: true}
      }}
  """
  @spec override_error_contexts(t(), any()) :: t()
  def override_error_contexts({:error, %Failure{}} = failure, new_context),
    do: map(failure, fn error -> Error.with_context(error, new_context) end)

  @doc ~S"""
  Overrides the message of all errors of a failure.

  ## Examples

      iex> error_1 = Validixir.Error.make(1, :not_allowed, SomeContext)
      iex> error_2 = Validixir.Error.make(2, :also_not_allowed, SomeContext)
      iex> f = Validixir.Failure.make([error_1, error_2])
      iex> Validixir.Failure.override_error_messages(f, :nonono)
      {:error, %Validixir.Failure{errors: [
            %Validixir.Error{candidate: 1, message: :nonono, context: SomeContext},
            %Validixir.Error{candidate: 2, message: :nonono, context: SomeContext}
          ],
          __message_lookup: %{nonono: true}
      }}
  """
  @spec override_error_messages(t(), any()) :: t()
  def override_error_messages({:error, %Failure{}} = failure, new_message),
    do: map(failure, fn error -> Error.with_message(error, new_message) end)

  @doc ~S"""
  Combines two errors. That is, appending their error lists.

  ## Examples

      iex> error_1 = Validixir.Error.make(1, :not_allowed, SomeContext)
      iex> error_2 = Validixir.Error.make(2, :also_not_allowed, SomeContext)
      iex> failure_1 = Validixir.Failure.make([error_1])
      iex> failure_2 = Validixir.Failure.make([error_2])
      iex> Validixir.Failure.combine(failure_1, failure_2)
      {:error, %Validixir.Failure{errors: [
            %Validixir.Error{candidate: 1, message: :not_allowed, context: SomeContext},
            %Validixir.Error{candidate: 2, message: :also_not_allowed, context: SomeContext}
          ],
          __message_lookup: %{not_allowed: true, also_not_allowed: true}
      }}
  """
  @spec combine(t(), t()) :: t()
  def combine({:error, %Failure{errors: e1}}, {:error, %Failure{errors: e2}}),
    do: make(Enum.concat(e1, e2))

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
  def failure?({:error, %Failure{}}), do: true
  def failure?(_), do: false

  defp prepare___message_lookup(errors) do
    messages = Enum.map(errors, fn error -> error.message end)
    flat_messages = List.flatten(messages)
    all = (messages ++ flat_messages) |> Enum.uniq()

    Enum.map(all, fn message -> {message, true} end)
    |> Map.new()
  end
end
