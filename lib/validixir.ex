defmodule Validixir do
  @moduledoc """
  Module containing all basic functionality needed for validation.
  """

  alias Validixir.Error, as: Error
  alias Validixir.Failure, as: Failure
  alias Validixir.Success, as: Success

  use Currying

  @typedoc """
  A validation result is one of the following:

  * A failure
  * A success

  The type represents the possible results of a validation.
  The type takes a parameter that sets the candidate type in case of a success.
  """
  @type validation_result_t(inner_t) :: Failure.t() | Success.t(inner_t)

  @doc ~S"""
  Returns `true` if a value is either a `Validixir.Success` or a `Validixir.Failure`,
  returns `false` else.

  ## Examples

      iex> Validixir.validation_result?(Validixir.Success.make(12))
      true

      iex> Validixir.validation_result?(Validixir.Failure.make([]))
      true

      iex> Validixir.validation_result?(%{})
      false

      iex> {:error, internal_failure} = Validixir.Failure.make([])
      iex> Validixir.validation_result?(internal_failure)
  """
  @spec validation_result?(any()) :: boolean()
  def validation_result?(thing) do
    case thing do
      {:error, %Failure{}} -> true
      {:ok, _} -> true
      _ -> false
    end
  end

  @doc ~S"""
  Applies a function to the candidate of a success. If a failure is passed it is
  returned unchanged.

  ## Examples

      iex> success = Validixir.Success.make(0)
      iex> Validixir.map_success(success, fn a -> a + 1 end)
      {:ok, 1}

      iex> failure = Validixir.Failure.make([])
      iex> Validixir.map_success(failure, fn a -> a + 1 end)
      {:error, %Validixir.Failure{errors: [], __message_lookup: %{}}}
  """
  @spec map_success(
          validation_result_t(Success.some_inner_t()),
          (Success.some_inner_t() -> any())
        ) :: validation_result_t(any())
  def map_success({:ok, _} = success, f), do: Success.map(success, f)
  def map_success({:error, %Failure{}} = failure, _), do: failure

  @doc ~S"""
  Applies a function to each of the errors of a failure. If a success is passed it is
  returned unchanged.

  ## Examples

      iex> success = Validixir.Success.make(0)
      iex> Validixir.map_failure(success, fn a -> a + 1 end)
      {:ok, 0}

      iex> failure = Validixir.Failure.make([Validixir.Error.make(1, :hello, :hello)])
      iex> Validixir.map_failure(failure, fn err -> %Validixir.Error{ err | candidate: 2} end)
      {:error, %Validixir.Failure{errors: [Validixir.Error.make(2, :hello, :hello)], __message_lookup: %{hello: true}}}
  """
  @spec map_failure(validation_result_t(Success.some_inner_t()), (Error.t() -> Error.t())) ::
          validation_result_t(Success.some_inner_t())
  def map_failure({:error, %Failure{}} = failure, f), do: Failure.map(failure, f)
  def map_failure({:ok, _} = success, _), do: success

  @doc ~S"""
  Takes a validation result and two functions that are applied as in map_success/2 and
  map_failure/2 respectively.

  ## Examples

      iex> success = Validixir.Success.make(0)
      iex> Validixir.map(success, fn a -> a + 1 end, fn _ -> :does_nothing end)
      {:ok, 1}

      iex> failure = Validixir.Failure.make([Validixir.Error.make(1, :hello, :hello)])
      iex> Validixir.map(failure, fn _ -> :does_nothing end, fn err -> %Validixir.Error{ err | candidate: 2} end)
      {:error, %Validixir.Failure{errors: [Validixir.Error.make(2, :hello, :hello)], __message_lookup: %{hello: true}}}
  """
  @spec map(
          validation_result_t(Success.some_inner_t()),
          (Success.some_inner_t() -> any()),
          (Error.t() -> Error.t())
        ) ::
          validation_result_t(any())
  def map({:error, %Failure{}} = failure, _, f_failure), do: map_failure(failure, f_failure)
  def map({:ok, _} = success, f_success, _), do: map_success(success, f_success)

  @doc ~S"""
  Takes a value and lifts it in a validation result, returning a success with the value
  as its candidate.

  ## Examples

      iex> Validixir.pure(12)
      {:ok, 12}
  """
  @spec pure(Success.some_inner_t()) :: Success.t(Success.some_inner_t())
  def pure(value), do: Success.make(value)

  @doc ~S"""
  Same as `pure/1`.

  ## Examples

      iex> Validixir.success(12)
      {:ok, 12}
  """
  @spec success(Success.some_inner_t()) :: Success.t(Success.some_inner_t())
  def success(value), do: pure(value)

  @doc ~S"""
  Augments a failure's error contexts if a failure is passed, else returns the success.

  ## Examples

      iex> Validixir.pure(12) |> Validixir.augment_contexts(Hello)
      {:ok, 12}

      iex> error_1 = Validixir.Error.make(1, :message, Context)
      iex> error_2 = Validixir.Error.make(2, :message, AnotherContext)
      iex> failure = Validixir.Failure.make([error_1, error_2])
      iex> Validixir.augment_contexts(failure, AdditionalContext)
      {:error, %Validixir.Failure{
          errors: [
              %Validixir.Error{candidate: 1, message: :message, context: [ AdditionalContext, Context ]},
              %Validixir.Error{candidate: 2, message: :message, context: [ AdditionalContext, AnotherContext ]},
          ],
          __message_lookup: %{message: true}
      }}
  """
  @spec augment_contexts(validation_result_t(Success.some_inner_t()), any()) ::
          validation_result_t(Success.some_inner_t())
  def augment_contexts({:ok, _} = success, _), do: success

  def augment_contexts({:error, %Failure{}} = failure, additional_context),
    do: map_failure(failure, fn error -> Error.augment_context(error, additional_context) end)

  @doc ~S"""
  Augments a failure's error messages if a failure is passed, else returns the success.

  ## Examples

      iex> Validixir.pure(12) |> Validixir.augment_messages(Hello)
      {:ok, 12}

      iex> error_1 = Validixir.Error.make(1, :message, Context)
      iex> error_2 = Validixir.Error.make(2, :another_message, Context)
      iex> failure = Validixir.Failure.make([error_1, error_2])
      iex> Validixir.augment_messages(failure, :additional_message)
      {:error, %Validixir.Failure{
          errors: [
              %Validixir.Error{candidate: 1, message: [:additional_message, :message], context: Context},
              %Validixir.Error{candidate: 2, message: [:additional_message, :another_message], context: Context}
          ],
          __message_lookup: %{[:additional_message, :message] => true, [:additional_message, :another_message] => true, :additional_message => true, :message => true, :another_message => true}
      }}
  """
  @spec augment_messages(validation_result_t(Success.some_inner_t()), any()) ::
          validation_result_t(Success.some_inner_t())
  def augment_messages({:ok, _} = success, _), do: success

  def augment_messages({:error, %Failure{}} = failure, additional_message),
    do: map_failure(failure, fn error -> Error.augment_message(error, additional_message) end)

  @doc ~S"""
  Overrides a failure's error messages if a failure is passed, else returns the success.

  ## Examples

      iex> Validixir.pure(12) |> Validixir.override_messages(Hello)
      {:ok, 12}

      iex> error_1 = Validixir.Error.make(1, :message, Context)
      iex> error_2 = Validixir.Error.make(2, :another_message, Context)
      iex> failure = Validixir.Failure.make([error_1, error_2])
      iex> Validixir.override_messages(failure, :additional_message)
      {:error, %Validixir.Failure{
          errors: [
              %Validixir.Error{candidate: 1, message: :additional_message, context: Context},
              %Validixir.Error{candidate: 2, message: :additional_message, context: Context}
          ],
          __message_lookup: %{additional_message: true}
      }}
  """
  @spec override_messages(validation_result_t(Success.some_inner_t()), any()) ::
          validation_result_t(Success.some_inner_t())
  def override_messages({:ok, _} = success, _), do: success

  def override_messages({:error, %Failure{}} = failure, message),
    do: Failure.override_error_messages(failure, message)

  @doc ~S"""
  Overrides a failure's error contexts if a failure is passed, else returns the success.

  ## Examples

      iex> Validixir.pure(12) |> Validixir.override_contexts(Hello)
      {:ok, 12}

      iex> error_1 = Validixir.Error.make(1, :message, Context)
      iex> error_2 = Validixir.Error.make(2, :another_message, Context)
      iex> failure = Validixir.Failure.make([error_1, error_2])
      iex> Validixir.override_contexts(failure, NewContext)
      {:error, %Validixir.Failure{
          errors: [
            %Validixir.Error{candidate: 1, message: :message, context: NewContext},
            %Validixir.Error{candidate: 2, message: :another_message, context: NewContext}
          ],
          __message_lookup: %{another_message: true, message: true}
      }}
  """
  @spec override_contexts(validation_result_t(Success.some_inner_t()), any()) ::
          validation_result_t(Success.some_inner_t())
  def override_contexts({:ok, _} = success, _), do: success

  def override_contexts({:error, %Failure{}} = failure, context),
    do: Failure.override_error_contexts(failure, context)

  @doc ~S"""
  Applies a function wrapped in a validation success to the
  candidate of another validation success. If both validation results are failures
  it returns them combined. If only one is a failure, this failure is returned unchanged.

  This function is key in implementing applicatives.

  ## Examples

      iex> s1 = Validixir.Success.make(fn a -> a + 1 end)
      iex> s2 = Validixir.Success.make(0)
      iex> Validixir.seq(s1, s2)
      {:ok, 1}

      iex> error = Validixir.Error.make(:hello, "not allowed", nil)
      iex> failure = Validixir.Failure.make([error])
      iex> success = Validixir.Success.make(1)
      iex> Validixir.seq(failure, success)
      {:error, %Validixir.Failure{errors: [error], __message_lookup: %{"not allowed" => true}}}

      iex> error1 = Validixir.Error.make(:hello, "not allowed", nil)
      iex> error2 = Validixir.Error.make(:world, "not allowed", nil)
      iex> failure1 = Validixir.Failure.make([error1])
      iex> failure2 = Validixir.Failure.make([error2])
      iex> Validixir.seq(failure1, failure2)
      {:error, %Validixir.Failure{errors: [error1, error2], __message_lookup: %{"not allowed" => true}}}
  """
  @spec seq(
          validation_result_t((Success.some_inner_t() -> any())),
          validation_result_t(Success.some_inner_t())
        ) :: validation_result_t(any())
  def seq({:error, %Failure{}} = f1, {:error, %Failure{}} = f2), do: Failure.combine(f1, f2)
  def seq({:error, %Failure{}} = f1, _), do: f1
  def seq(_, {:error, %Failure{}} = f2), do: f2
  def seq({:ok, f}, validation_result), do: map_success(validation_result, f)

  @doc !"""
       Essentially a monadic bind.
       """
  @spec bind(
          validation_result_t(Success.some_inner_t()),
          (Success.some_inner_t() -> validation_result_t(any()))
        ) :: validation_result_t(any())
  defp bind({:error, %Failure{}} = failure, _), do: failure
  defp bind({:ok, candidate}, f), do: f.(candidate)

  @doc ~S"""
  Takes a validation result and a function.
  In case of a success the function is applied to the candidate and the result is returned.
  In case of a failure that failure is returned unchanged.

  This function is used to chain validations.

  ## Examples

      iex> Validixir.Success.make(0) |> Validixir.and_then(fn x -> Validixir.Success.make(x + 1) end)
      {:ok, 1}

      iex> Validixir.Failure.make([]) |> Validixir.and_then(fn x -> x + 1 end)
      {:error, %Validixir.Failure{errors: [], __message_lookup: %{}}}
  """
  @spec and_then(
          validation_result_t(Success.some_inner_t()),
          (Success.some_inner_t() -> validation_result_t(any()))
        ) :: validation_result_t(any())
  def and_then(validation_result, f), do: bind(validation_result, f)

  @doc ~S"""
  Takes a function that is called if all validation results are successes. The call
  parameters are then the candidates in the respective order. The return value of this function
  call is then wrapped as a success and returned.

  If there is at least one failure, errors get accumulated and a validation failure is returned.

  ## Examples

      iex> Validixir.validate(fn a, b -> {a, b} end, [Validixir.Success.make(1), Validixir.Success.make(2)])
      {:ok, {1,2}}

      iex> error1 = Validixir.Error.make(:hello, "not allowed", nil)
      iex> error2 = Validixir.Error.make(:world, "not allowed", nil)
      iex> failure1 = Validixir.Failure.make([error1])
      iex> failure2 = Validixir.Failure.make([error2])
      iex> Validixir.validate(fn a, b -> {a, b} end, [failure1, failure2])
      {:error, %Validixir.Failure{errors: [error1, error2], __message_lookup: %{"not allowed" => true}}}
  """
  @spec validate(function(), [validation_result_t(any())]) :: validation_result_t(any())
  def validate(result_f, validations) do
    pure_curried = curry(result_f) |> pure()
    Enum.reduce(validations, pure_curried, fn a, b -> seq(b, a) end)
  end

  @doc ~S"""
  Takes a list of validation results and returns a success that contains the list
  of all candidates, if all validation results are successes. Else all failures are
  combined and a validation failure is returned.

  ## Examples

      iex> Validixir.sequence([Validixir.Success.make(1), Validixir.Success.make(2)])
      {:ok, [1,2]}

      iex> error1 = Validixir.Error.make(:hello, "not allowed", nil)
      iex> error2 = Validixir.Error.make(:world, "not allowed", nil)
      iex> failure1 = Validixir.Failure.make([error1])
      iex> failure2 = Validixir.Failure.make([error2])
      iex> Validixir.sequence([failure1, failure2])
      {:error, %Validixir.Failure{errors: [error1, error2], __message_lookup: %{"not allowed" => true}}}
  """
  @spec sequence([validation_result_t(Success.some_inner_t())]) ::
          validation_result_t([Success.some_inner_t()])
  def sequence([]), do: pure([])
  def sequence([result]), do: result |> map_success(fn x -> [x] end)
  def sequence([x | xs]), do: validate(fn a, b -> [a | b] end, [x, sequence(xs)])

  @type validation_fun_t(result_t) :: (any() -> validation_result_t(result_t))

  @doc ~S"""
  Does the same as `Validixir.sequence/1` but applies a validation function
  to all candidates first.

  ## Examples

      iex> success_fn = fn c -> Validixir.Success.make(c) end
      iex> Validixir.sequence_of([1, 2], success_fn)
      {:ok, [1,2]}

      iex> failure_fn = fn c -> [Validixir.Error.make(c, "not allowed", nil)] |> Validixir.Failure.make() end
      iex> Validixir.sequence_of([:hello, :world], failure_fn)
      {:error, %Validixir.Failure{
          errors: [Validixir.Error.make(:hello, [{:index, 0}, "not allowed"], nil),
                   Validixir.Error.make(:world, [{:index, 1}, "not allowed"], nil)],
          __message_lookup: %{"not allowed" => true, [{:index, 0}, "not allowed"] => true, [{:index, 1}, "not allowed"] => true, {:index, 0} => true, {:index, 1} => true}}}
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
  Returns a success that contains the candidate iff each validation function returns a success.
  Else returns a validation failure containing errors of each failed validation.

  ## Examples

      iex> success_fn_1 = fn c -> Validixir.Success.make(c) end
      iex> success_fn_2 = fn _ -> Validixir.Success.make(12) end
      iex> Validixir.validate_all([success_fn_1, success_fn_2], 1)
      {:ok, 1}

      iex> failure_fn = fn c -> [Validixir.Error.make(c, "not allowed", nil)] |> Validixir.Failure.make() end
      iex> success_fn = fn _ -> Validixir.Success.make(12) end
      iex> Validixir.validate_all([failure_fn, success_fn], :hello)
      {:error, %Validixir.Failure{errors: [Validixir.Error.make(:hello, [ {:index, 0}, "not allowed" ], nil)], __message_lookup: %{"not allowed" => true, [{:index, 0}, "not allowed"] => true, {:index, 0} => true}}}
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
      {:ok, _} -> Validixir.Success.make(candidate)
      {:error, %Validixir.Failure{}} -> validated
    end
  end

  defdelegate failure_from_error(candidate, message, context),
    to: Validixir.Failure,
    as: :make_from_error
end
