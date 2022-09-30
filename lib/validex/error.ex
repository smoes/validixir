defmodule Validex.Error do
  alias __MODULE__

  @type t :: %Error{}
  @enforce_keys [:candidate, :message]
  defstruct [:candidate, :message, :context]

  @doc ~S"""
  Smart constructor of an error.
  """
  @spec make(any(), any(), any()) :: t()
  def make(candidate, message, context),
    do: %Error{candidate: candidate, message: message, context: context}

  @doc ~S"""
  Overrides the context of an error

  ## Examples

      iex> Validex.Error.with_context(Validex.Error.make(12, :message, Context), NewContext)
      %Validex.Error{candidate: 12, message: :message, context: NewContext}
  """
  @spec with_context(t(), any()) :: t()
  def with_context(error, context), do: %Error{error | context: context}

  @doc ~S"""
  Overrides the message of an error

  ## Examples

      iex> Validex.Error.with_message(Validex.Error.make(12, :message, Context), :new_message)
      %Validex.Error{candidate: 12, message: :new_message, context: Context}
  """
  @spec with_message(t(), any()) :: t()
  def with_message(error, message), do: %Error{error | message: message}

  @doc ~S"""
  Augments the message of an error

  ## Examples

      iex> Validex.Error.augment_message(Validex.Error.make(12, :message, Context), :new_message)
      %Validex.Error{candidate: 12, message: {:new_message, :message}, context: Context}
  """
  @spec augment_message(t(), any()) :: t()
  def augment_message(error = %Error{message: message}, additional_message),
    do: with_message(error, {additional_message, message})

  @doc ~S"""
  Augments the context of an error

  ## Examples

      iex> Validex.Error.augment_context(Validex.Error.make(12, :message, Context), NewContext)
      %Validex.Error{candidate: 12, message: :message, context: {NewContext, Context}}
  """
  @spec augment_context(t(), any()) :: t()
  def augment_context(error = %Error{context: context}, additional_context),
    do: with_context(error, {additional_context, context})
end
