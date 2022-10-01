defmodule Validatex do
  @moduledoc """
  Module containing all basic functionality needed for validation.
  """

  # TODO: Module doc
  # TODO: Tests showing the whole thing
  # TODO: README
  # TODO: Deploy in hex

  alias Validatex.Error, as: Error
  alias Validatex.Failure, as: Failure
  alias Validatex.Success, as: Success

  use Currying

  @type validation_result_t(inner_t) :: Failure.t() | Success.t(inner_t)

  @doc ~S"""
  Returns `true` if a value is either a [[Validatex.Success]] or a [[Validatex.Failure]],
  returns `false` else.

  ## Examples

      iex> Validatex.validation_result?(Validatex.Success.make(12))
      true

      iex> Validatex.validation_result?(Validatex.Failure.make([]))
      true

      iex> Validatex.validation_result?(%{})
      false
  """
  @spec validation_result?(any()) :: boolean()
  def validation_result?(thing) do
    case thing do
      %Failure{} -> true
      %Success{} -> true
      _ -> false
    end
  end

  @doc ~S"""
  Applies a function to the candidate of a success. If a failure is passed it is
  returned unchanged.

  ## Examples

      iex> success = Validatex.Success.make(0)
      iex> Validatex.map_success(success, fn a -> a + 1 end)
      %Validatex.Success{candidate: 1}

      iex> failure = Validatex.Failure.make([])
      iex> Validatex.map_success(failure, fn a -> a + 1 end)
      %Validatex.Failure{errors: []}
  """
  @spec map_success(
          validation_result_t(Success.some_inner_t()),
          (Success.some_inner_t() -> any())
        ) :: validation_result_t(any())
  def map_success(success = %Success{}, f), do: Success.map(success, f)
  def map_success(failure = %Failure{}, _), do: failure

  @doc ~S"""
  Applies a function to the errors of a failure. If a success is passed it is
  returned unchanged.

  ## Examples

      iex> success = Validatex.Success.make(0)
      iex> Validatex.map_failure(success, fn a -> a + 1 end)
      %Validatex.Success{candidate: 0}

      iex> failure = Validatex.Failure.make([Validatex.Error.make(1, :hello, :hello)])
      iex> Validatex.map_failure(failure, fn err -> %Validatex.Error{ err | candidate: 2} end)
      %Validatex.Failure{errors: [Validatex.Error.make(2, :hello, :hello)]}
  """
  @spec map_failure(validation_result_t(Success.some_inner_t()), (Error.t() -> Error.t())) ::
          validation_result_t(Success.some_inner_t())
  def map_failure(failure = %Failure{}, f), do: Failure.map(failure, f)
  def map_failure(success = %Success{}, _), do: success

  @doc ~S"""
  Takes a validation result and two functions that are applied as in map_success/2 and
  map_failure/2 respectivly.

  ## Examples

      iex> success = Validatex.Success.make(0)
      iex> Validatex.map(success, fn a -> a + 1 end, fn _ -> :does_nothing end)
      %Validatex.Success{candidate: 1}

      iex> failure = Validatex.Failure.make([Validatex.Error.make(1, :hello, :hello)])
      iex> Validatex.map(failure, fn _ -> :does_nothing end, fn err -> %Validatex.Error{ err | candidate: 2} end)
      %Validatex.Failure{errors: [Validatex.Error.make(2, :hello, :hello)]}
  """
  @spec map(
          validation_result_t(Success.some_inner_t()),
          (Success.some_inner_t() -> any()),
          (Error.t() -> Error.t())
        ) ::
          validation_result_t(any())
  def map(f = %Failure{}, _, f_failure), do: map_failure(f, f_failure)
  def map(s = %Success{}, f_success, _), do: map_success(s, f_success)

  @doc ~S"""
  Takes a value and lifts it in a validation result, returning a success with the value
  as its candidate.

  ## Examples

      iex> Validatex.pure(12)
      %Validatex.Success{candidate: 12}
  """
  @spec pure(Success.some_inner_t()) :: Success.t(Success.some_inner_t())
  def pure(value), do: Success.make(value)

  @doc ~S"""
  Augments a failure's contexts if a failure is passed, else returns the success.

  ## Examples

      iex> Validatex.pure(12) |> Validatex.augment_contexts(Hello)
      %Validatex.Success{candidate: 12}

      iex> error_1 = Validatex.Error.make(1, :message, Context)
      iex> error_2 = Validatex.Error.make(2, :message, AnotherContext)
      iex> failure = Validatex.Failure.make([error_1, error_2])
      iex> Validatex.augment_contexts(failure, AdditionalContext)
      %Validatex.Failure{
          errors: [
              %Validatex.Error{candidate: 1, message: :message, context: {AdditionalContext, Context}},
              %Validatex.Error{candidate: 2, message: :message, context: {AdditionalContext, AnotherContext}},
          ]
      }
  """
  @spec augment_contexts(validation_result_t(Success.some_inner_t()), any()) ::
          validation_result_t(Success.some_inner_t())
  def augment_contexts(s = %Success{}, _), do: s

  def augment_contexts(f = %Failure{}, additional_context),
    do: map_failure(f, fn error -> Error.augment_context(error, additional_context) end)

  @doc ~S"""
  Augments a failure's messages if a failure is passed, else returns the success.

  ## Examples

      iex> Validatex.pure(12) |> Validatex.augment_messages(Hello)
      %Validatex.Success{candidate: 12}

      iex> error_1 = Validatex.Error.make(1, :message, Context)
      iex> error_2 = Validatex.Error.make(2, :another_message, Context)
      iex> failure = Validatex.Failure.make([error_1, error_2])
      iex> Validatex.augment_messages(failure, :additional_message)
      %Validatex.Failure{
          errors: [
              %Validatex.Error{candidate: 1, message: {:additional_message, :message}, context: Context},
              %Validatex.Error{candidate: 2, message: {:additional_message, :another_message}, context: Context}
          ]
      }
  """
  @spec augment_messages(validation_result_t(Success.some_inner_t()), any()) ::
          validation_result_t(Success.some_inner_t())
  def augment_messages(s = %Success{}, _), do: s

  def augment_messages(f = %Failure{}, additional_message),
    do: map_failure(f, fn error -> Error.augment_message(error, additional_message) end)

  @doc ~S"""
  Overrides a failure's messages if a failure is passed, else returns the success.

  ## Examples

      iex> Validatex.pure(12) |> Validatex.override_messages(Hello)
      %Validatex.Success{candidate: 12}

      iex> error_1 = Validatex.Error.make(1, :message, Context)
      iex> error_2 = Validatex.Error.make(2, :another_message, Context)
      iex> failure = Validatex.Failure.make([error_1, error_2])
      iex> Validatex.override_messages(failure, :additional_message)
      %Validatex.Failure{
          errors: [
              %Validatex.Error{candidate: 1, message: :additional_message, context: Context},
              %Validatex.Error{candidate: 2, message: :additional_message, context: Context}
          ]
      }
  """
  @spec override_messages(validation_result_t(Success.some_inner_t()), any()) ::
          validation_result_t(Success.some_inner_t())
  def override_messages(s = %Success{}, _), do: s
  def override_messages(f = %Failure{}, message), do: Failure.override_error_messages(f, message)

  @doc ~S"""
  Overrides a failure's contexts if a failure is passed, else returns the success.

  ## Examples

      iex> Validatex.pure(12) |> Validatex.override_contexts(Hello)
      %Validatex.Success{candidate: 12}

      iex> error_1 = Validatex.Error.make(1, :message, Context)
      iex> error_2 = Validatex.Error.make(2, :another_message, Context)
      iex> failure = Validatex.Failure.make([error_1, error_2])
      iex> Validatex.override_contexts(failure, NewContext)
      %Validatex.Failure{
          errors: [
          %Validatex.Error{candidate: 1, message: :message, context: NewContext},
          %Validatex.Error{candidate: 2, message: :another_message, context: NewContext}
          ]
      }
  """
  @spec override_contexts(validation_result_t(Success.some_inner_t()), any()) ::
          validation_result_t(Success.some_inner_t())
  def override_contexts(s = %Success{}, _), do: s
  def override_contexts(f = %Failure{}, context), do: Failure.override_error_contexts(f, context)

  @doc ~S"""
  This function applies a function wrapped in a validation success to the
  candidate of a validation success. If both validation results are failures
  it returns them combined. If only the first one is a failure, this failure
  is returned unchanged.

  This function is key in implementing applicatives.

  ## Examples

      iex> s1 = Validatex.Success.make(fn a -> a + 1 end)
      iex> s2 = Validatex.Success.make(0)
      iex> Validatex.seq(s1, s2)
      %Validatex.Success{candidate: 1}

      iex> error = Validatex.Error.make(:hello, "not allowed", nil)
      iex> failure = Validatex.Failure.make([error])
      iex> success = Validatex.Success.make(1)
      iex> Validatex.seq(failure, success)
      %Validatex.Failure{errors: [error]}

      iex> error1 = Validatex.Error.make(:hello, "not allowed", nil)
      iex> error2 = Validatex.Error.make(:world, "not allowed", nil)
      iex> failure1 = Validatex.Failure.make([error1])
      iex> failure2 = Validatex.Failure.make([error2])
      iex> Validatex.seq(failure1, failure2)
      %Validatex.Failure{errors: [error1, error2]}
  """
  @spec seq(
          validation_result_t((Success.some_inner_t() -> any())),
          validation_result_t(Success.some_inner_t())
        ) :: validation_result_t(any())
  def seq(f1 = %Failure{}, f2 = %Failure{}), do: Failure.combine(f1, f2)
  def seq(f1 = %Failure{}, _), do: f1
  def seq(%Success{candidate: f}, validation_result), do: map_success(validation_result, f)

  @doc !"""
       Essentially a monadic bind.
       """
  @spec bind(
          validation_result_t(Success.some_inner_t()),
          (Success.some_inner_t() -> validation_result_t(any()))
        ) :: validation_result_t(any())
  defp bind(failure = %Failure{}, _), do: failure
  defp bind(%Success{candidate: candidate}, f), do: f.(candidate)

  @doc ~S"""
  Takes a `validation_result_t()` and a functions that takes the candidate
  in case of a success and returns a `validation_result_t()` again.
  This function is used to chain validations.

  ## Examples

      iex> Validatex.Success.make(0) |> Validatex.and_then(fn x -> Validatex.Success.make(x + 1) end)
      %Validatex.Success{candidate: 1}

      iex> Validatex.Failure.make([]) |> Validatex.and_then(fn x -> x + 1 end)
      %Validatex.Failure{errors: []}
  """
  @spec and_then(
          validation_result_t(Success.some_inner_t()),
          (Success.some_inner_t() -> validation_result_t(any()))
        ) :: validation_result_t(any())
  def and_then(validation_result, f), do: bind(validation_result, f)

  @doc ~S"""
  Takes a function that is called iff all validation results are Successes. The call
  parameters are then the candidates in the respective order. Returns a validation success then,
  with the candidate being the return value of this function.
  If there is at least one failure, errors get accumulated and a validation failure is returned.

  ## Examples

      iex> Validatex.validate(fn a, b -> {a, b} end, [Validatex.Success.make(1), Validatex.Success.make(2)])
      %Validatex.Success{candidate: {1,2}}

      iex> error1 = Validatex.Error.make(:hello, "not allowed", nil)
      iex> error2 = Validatex.Error.make(:world, "not allowed", nil)
      iex> failure1 = Validatex.Failure.make([error1])
      iex> failure2 = Validatex.Failure.make([error2])
      iex> Validatex.validate(fn a, b -> {a, b} end, [failure1, failure2])
      %Validatex.Failure{errors: [error1, error2]}
  """
  @spec validate(function(), [validation_result_t(any())]) :: validation_result_t(any())
  def validate(result_f, validations) do
    pure_curried = curry(result_f) |> pure()
    Enum.reduce(validations, pure_curried, fn a, b -> seq(b, a) end)
  end

  @doc ~S"""
  Takes a list of validation results and returns a validation success containing list
  of all candidates, if all validation results are successes. Else all failures are
  combined and a validation failure is returned.

  ## Examples

      iex> Validatex.sequence([Validatex.Success.make(1), Validatex.Success.make(2)])
      %Validatex.Success{candidate: [1,2]}

      iex> error1 = Validatex.Error.make(:hello, "not allowed", nil)
      iex> error2 = Validatex.Error.make(:world, "not allowed", nil)
      iex> failure1 = Validatex.Failure.make([error1])
      iex> failure2 = Validatex.Failure.make([error2])
      iex> Validatex.sequence([failure1, failure2])
      %Validatex.Failure{errors: [error1, error2]}
  """
  @spec sequence([validation_result_t(Success.some_inner_t())]) ::
          validation_result_t([Success.some_inner_t()])
  def sequence([]), do: pure([])
  def sequence([result]), do: result |> map_success(fn x -> [x] end)

  def sequence([x | xs]),
    do: validate(fn a, b -> [a | b] end, [x, sequence(xs)])

  @type validation_fun_t(result_t) :: (any() -> validation_result_t(result_t))

  @doc ~S"""
  Does the same as `Validatex.sequence/1` but applies a validation function
  to all candidates first.
  Takes an optional context to augment the results, including the index. Uses :seq if
  none is given.

  ## Examples

      iex> success_fn = fn c -> Validatex.Success.make(c) end
      iex> Validatex.sequence_of([1, 2], success_fn)
      %Validatex.Success{candidate: [1,2]}

      iex> failure_fn = fn c -> [Validatex.Error.make(c, "not allowed", nil)] |> Validatex.Failure.make() end
      iex> Validatex.sequence_of([:hello, :world], failure_fn)
      %Validatex.Failure{
          errors: [Validatex.Error.make(:hello, {{:index, 0}, "not allowed"}, nil),
                   Validatex.Error.make(:world, {{:index, 1}, "not allowed"}, nil)]}
  """
  @spec sequence_of([any()], validation_fun_t(Success.some_inner_t())) ::
          validation_result_t(Success.some_inner_t())
  def sequence_of(candidates, validation_f) do
    candidates
    |> Enum.with_index()
    |> Enum.map(fn {candidate, idx} ->
      validation_f.(candidate) |> augment_messages({:index, idx})
    end)
    |> sequence()
  end

  @doc ~S"""
  Applies a list of validation functions to a candidate.
  Returns a success containing the candidate if each validation function returns a success.
  Else returns a validation failure containing errors of each failed validation.

  Takes an optional context as in `Validatex.sequence_of/3`.

  ## Examples

      iex> success_fn_1 = fn c -> Validatex.Success.make(c) end
      iex> success_fn_2 = fn _ -> Validatex.Success.make(12) end
      iex> Validatex.validate_all([success_fn_1, success_fn_2], 1)
      %Validatex.Success{candidate: 1}

      iex> failure_fn = fn c -> [Validatex.Error.make(c, "not allowed", nil)] |> Validatex.Failure.make() end
      iex> success_fn = fn _ -> Validatex.Success.make(12) end
      iex> Validatex.validate_all([failure_fn, success_fn], :hello)
      %Validatex.Failure{errors: [Validatex.Error.make(:hello, {{:index, 0}, "not allowed"}, nil)]}
  """
  @type validate_all_return_t(inner_t) ::
          {:ok, validation_result_t(inner_t)} | {:error, :no_validators}
  @spec validate_all([validation_fun_t(Success.some_inner_t())], any()) ::
          validate_all_return_t(Success.some_inner_t())
  def validate_all([], _), do: {:error, :no_validators}

  def validate_all(validation_fs, candidate) do
    validated =
      validation_fs
      |> Enum.with_index()
      |> Enum.map(fn {validation_f, idx} ->
        validation_f.(candidate) |> augment_messages({:index, idx})
      end)
      |> sequence

    case validated do
      %Validatex.Success{} -> Validatex.Success.make(candidate)
      %Validatex.Failure{} -> validated
    end
  end
end
