defmodule Validex.Error do
  alias __MODULE__

  @type t :: %Error{}
  @enforce_keys [:candidate, :message]
  defstruct [:candidate, :message, :label]

  @spec make(any(), any(), any()) :: t()
  def make(candidate, message, label),
    do: %Error{candidate: candidate, message: message, label: label}

  @spec with_label(t(), any()) :: t()
  def with_label(error, label), do: %Error{error | label: label}

  @spec with_message(t(), any()) :: t()
  def with_message(error, message), do: %Error{error | message: message}

  @spec augment_message(t(), any()) :: t()
  def augment_message(error = %Error{message: message}, additional_message),
    do: with_message(error, {additional_message, message})

  @spec augment_label(t(), any()) :: t()
  def augment_label(error = %Error{label: label}, additional_label),
    do: with_label(error, {additional_label, label})
end
