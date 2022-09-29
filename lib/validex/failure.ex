defmodule Validex.Failure do
  alias __MODULE__
  alias Validex.Error, as: Error

  @type t :: %Failure{errors: [Error.t()]}
  @enforce_keys [:errors]
  defstruct [:errors]

  @spec make([any()]) :: t()
  def make(errors), do: %Failure{errors: errors}

  @spec map(t(), (Error.t() -> Error.t())) :: t()
  def map(%Failure{errors: errors}, f), do: Enum.map(errors, f) |> make()

  @spec override_error_labels(t(), any()) :: t()
  def override_error_labels(failure = %Failure{}, new_label),
    do: map(failure, fn error -> Error.with_label(error, new_label) end)

  @spec override_error_messages(t(), any()) :: t()
  def override_error_messages(failure = %Failure{}, new_message),
    do: map(failure, fn error -> Error.with_message(error, new_message) end)

  @spec combine(t(), t()) :: t()
  def combine(f1 = %Failure{errors: e1}, %Failure{errors: e2}),
    do: %Failure{f1 | errors: Enum.concat(e1, e2)}

  @spec failure?(any()) :: boolean()
  def failure?(%Failure{}), do: true
  def failure?(_), do: false
end
