defmodule Validatex.Validations do
  @moduledoc """
  This module contains premade validations for basic elixir types and often used
  functionality.
  """

  alias Validatex, as: Core
  alias Validatex.Success, as: Success
  alias Validatex.Failure, as: Failure
  alias Validatex.Error, as: Error

  @spec failure_from_error(any(), any()) :: Failure.t()
  defp failure_from_error(candidate, message),
    do: [Error.make(candidate, message, Validatex.Validations)] |> Failure.make()

  @doc ~S"""
  Always returns a validation success. 

  ## Examples

      iex> Validatex.Validations.succeed(12)
      %Validatex.Success{candidate: 12}

  """
  @spec succeed(Success.some_inner_t()) :: Success.t(Success.some_inner_t())
  def succeed(candidate), do: Core.pure(candidate)

  @doc ~S"""
  Returns a validation success if the candidate is an atom, returns a failure else.

  ## Examples

      iex> Validatex.Validations.atom(:hello)
      %Validatex.Success{candidate: :hello}

      iex> Validatex.Validations.atom(12)
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: 12, message: :not_an_atom, context: Validatex.Validations}
      ]}

  """
  @spec atom(any()) :: Core.validation_result_t(any())
  def atom(val) when is_atom(val), do: Core.pure(val)
  def atom(val), do: failure_from_error(val, :not_an_atom)

  @doc ~S"""
  Returns a validation success if the candidate is a bitstring, returns a failure else.

  ## Examples

      iex> Validatex.Validations.bitstring("foo")
      %Validatex.Success{candidate: "foo"}

      iex> Validatex.Validations.bitstring(<<1::3>>)
      %Validatex.Success{candidate: <<1::3>>}

      iex> Validatex.Validations.bitstring(12)
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: 12, message: :not_a_bitstring, context: Validatex.Validations}
      ]}

  """
  @spec bitstring(any()) :: Core.validation_result_t(any())
  def bitstring(val) when is_bitstring(val), do: Core.pure(val)
  def bitstring(val), do: failure_from_error(val, :not_a_bitstring)

  @doc ~S"""
  Returns a validation success if the candidate is a binary, returns a failure else.

  ## Examples

      iex> Validatex.Validations.binary("foo")
      %Validatex.Success{candidate: "foo"}

      iex> Validatex.Validations.binary(<<1::3>>)
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: <<1::3>>, message: :not_a_binary, context: Validatex.Validations}
      ]}

  """
  @spec binary(any()) :: Core.validation_result_t(any())
  def binary(val) when is_binary(val), do: Core.pure(val)
  def binary(val), do: failure_from_error(val, :not_a_binary)

  @doc ~S"""
  Returns a validation success if the candidate is a boolean, returns a failure else.

  ## Examples

      iex> Validatex.Validations.boolean(true)
      %Validatex.Success{candidate: true}

      iex> Validatex.Validations.boolean(nil)
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: nil, message: :not_a_boolean, context: Validatex.Validations}
      ]}

  """
  @spec boolean(any()) :: Core.validation_result_t(any())
  def boolean(val) when is_boolean(val), do: Core.pure(val)
  def boolean(val), do: failure_from_error(val, :not_a_boolean)

  @doc ~S"""
  Returns a validation success if the candidate is an exception, returns a failure else.

  ## Examples

      iex> Validatex.Validations.exception(%RuntimeError{})
      %Validatex.Success{candidate: %RuntimeError{}}

      iex> Validatex.Validations.exception(%{})
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: %{}, message: :not_an_exception, context: Validatex.Validations}
      ]}

  """
  @spec exception(any()) :: Core.validation_result_t(any())
  def exception(val) when is_exception(val), do: Core.pure(val)
  def exception(val), do: failure_from_error(val, :not_an_exception)

  @doc ~S"""
  Returns a validation success if the candidate is a float, returns a failure else.

  ## Examples

      iex> Validatex.Validations.float(12.2)
      %Validatex.Success{candidate: 12.2}

      iex> Validatex.Validations.float(12)
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: 12, message: :not_a_float, context: Validatex.Validations}
      ]}

  """
  @spec float(any()) :: Core.validation_result_t(any())
  def float(val) when is_float(val), do: Core.pure(val)
  def float(val), do: failure_from_error(val, :not_a_float)

  @doc ~S"""
  Returns a validation success if the candidate is a function, returns a failure else.

  ## Examples

      iex> Validatex.Validations.function(&Validatex.pure/1)
      %Validatex.Success{candidate: &Validatex.pure/1}

      iex> Validatex.Validations.function(12)
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: 12, message: :not_a_function, context: Validatex.Validations}
      ]}

  """
  @spec function(any()) :: Core.validation_result_t(any())
  def function(val) when is_function(val), do: Core.pure(val)
  def function(val), do: failure_from_error(val, :not_a_function)

  @doc ~S"""
  Returns a validation success if the candidate is an integer, returns a failure else.

  ## Examples

      iex> Validatex.Validations.integer(12)
      %Validatex.Success{candidate: 12}

      iex> Validatex.Validations.integer(12.2)
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: 12.2, message: :not_an_integer, context: Validatex.Validations}
      ]}

  """
  @spec integer(any()) :: Core.validation_result_t(any())
  def integer(val) when is_integer(val), do: Core.pure(val)
  def integer(val), do: failure_from_error(val, :not_an_integer)

  @doc ~S"""
  Returns a validation success if the candidate is a positive integer, returns a failure else.

  ## Examples

      iex> Validatex.Validations.pos_integer(12)
      %Validatex.Success{candidate: 12}

      iex> Validatex.Validations.pos_integer(0)
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: 0, message: :not_a_positive_integer, context: Validatex.Validations}
      ]}

      iex> Validatex.Validations.pos_integer(-2)
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: -2, message: :not_a_positive_integer, context: Validatex.Validations}
      ]}
  """
  @spec pos_integer(any()) :: Core.validation_result_t(any())
  def pos_integer(val) when is_integer(val) and val > 0, do: Core.pure(val)
  def pos_integer(val), do: failure_from_error(val, :not_a_positive_integer)

  @doc ~S"""
  Returns a validation success if the candidate is a negative integer, returns a failure else.

  ## Examples

      iex> Validatex.Validations.neg_integer(-12)
      %Validatex.Success{candidate: -12}

      iex> Validatex.Validations.neg_integer(0)
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: 0, message: :not_a_negative_integer, context: Validatex.Validations}
      ]}

      iex> Validatex.Validations.neg_integer(2)
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: 2, message: :not_a_negative_integer, context: Validatex.Validations}
      ]}
  """
  @spec neg_integer(any()) :: Core.validation_result_t(any())
  def neg_integer(val) when is_integer(val) and val < 0, do: Core.pure(val)
  def neg_integer(val), do: failure_from_error(val, :not_a_negative_integer)

  @doc ~S"""
  Returns a validation success if the candidate is a list, returns a failure else.

  ## Examples

      iex> Validatex.Validations.list([1, 2, 3])
      %Validatex.Success{candidate: [1,2,3]}

      iex> Validatex.Validations.list([])
      %Validatex.Success{candidate: []}

      iex> Validatex.Validations.list(%{})
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: %{}, message: :not_a_list, context: Validatex.Validations}
      ]}
  """
  @spec list(any()) :: Core.validation_result_t(any())
  def list(val) when is_list(val), do: Core.pure(val)
  def list(val), do: failure_from_error(val, :not_a_list)

  @doc ~S"""
  Returns a validation success if the candidate is an empty list, returns a failure else.

  ## Examples

      iex> Validatex.Validations.empty_list([])
      %Validatex.Success{candidate: []}

      iex> Validatex.Validations.empty_list([1,2,3])
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: [1,2,3], message: :not_an_empty_list, context: Validatex.Validations}
      ]}

      iex> Validatex.Validations.empty_list(%{})
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: %{}, message: :not_an_empty_list, context: Validatex.Validations}
      ]}
  """
  @spec empty_list(any()) :: Core.validation_result_t(any())
  def empty_list(val) when is_list(val) and length(val) == 0, do: Core.pure(val)
  def empty_list(val), do: failure_from_error(val, :not_an_empty_list)

  @doc ~S"""
  Returns a validation success if the candidate is an non-empty list, returns a failure else.

  ## Examples

      iex> Validatex.Validations.non_empty_list([1,2,3])
      %Validatex.Success{candidate: [1,2,3]}

      iex> Validatex.Validations.non_empty_list([])
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: [], message: :not_a_non_empty_list, context: Validatex.Validations}
      ]}

      iex> Validatex.Validations.non_empty_list(%{})
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: %{}, message: :not_a_non_empty_list, context: Validatex.Validations}
      ]}
  """
  @spec non_empty_list(any()) :: Core.validation_result_t(any())
  def non_empty_list(val) when is_list(val) and length(val) > 0, do: Core.pure(val)
  def non_empty_list(val), do: failure_from_error(val, :not_a_non_empty_list)

  @doc ~S"""
  Returns a validation success if the candidate is a map, returns a failure else.

  ## Examples

      iex> Validatex.Validations.map(%{})
      %Validatex.Success{candidate: %{}}

      iex> Validatex.Validations.map(%Validatex.Success{candidate: 12})
      %Validatex.Success{candidate: %Validatex.Success{candidate: 12}}

      iex> Validatex.Validations.map([])
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: [], message: :not_a_map, context: Validatex.Validations}
      ]}
  """
  @spec map(any()) :: Core.validation_result_t(any())
  def map(val) when is_map(val), do: Core.pure(val)
  def map(val), do: failure_from_error(val, :not_a_map)

  @doc ~S"""
  Returns a validation success if the given map contains the given key, returns a failure else.

  ## Examples

      iex> Validatex.Validations.map_key(%{hello: :world}, :hello)
      %Validatex.Success{candidate: {%{hello: :world}, :hello}}

      iex> Validatex.Validations.map_key(%{}, :hello)
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: {%{}, :hello}, message: :not_a_key_of_map, context: Validatex.Validations}
      ]}
  """
  @spec map_key(map(), any()) :: Core.validation_result_t(any())
  def map_key(m, k) when is_map_key(m, k), do: Core.pure({m, k})
  def map_key(m, k), do: failure_from_error({m, k}, :not_a_key_of_map)

  @doc ~S"""
  Returns a validation success if the candidate is nil, returns a failure else.
  Since all other names are special words in elixir, we chose `nil?` as the function name.

  ## Examples

      iex> Validatex.Validations.nil?(nil)
      %Validatex.Success{candidate: nil}

      iex> Validatex.Validations.nil?(12)
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: 12, message: :not_nil, context: Validatex.Validations}
      ]}
  """
  @spec nil?(any()) :: Core.validation_result_t(any())
  def nil?(val) when is_nil(val), do: Core.pure(val)
  def nil?(val), do: failure_from_error(val, :not_nil)

  @doc ~S"""
  Returns a validation success if the candidate is not nil, returns a failure else.

  ## Examples

      iex> Validatex.Validations.not_nil(12)
      %Validatex.Success{candidate: 12}

      iex> Validatex.Validations.not_nil(nil)
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: nil, message: :is_nil, context: Validatex.Validations}
      ]}
  """
  @spec not_nil(any()) :: Core.validation_result_t(any())
  def not_nil(val) when is_nil(val), do: failure_from_error(val, :is_nil)
  def not_nil(val), do: Core.pure(val)

  @doc ~S"""
  Returns a validation success if the candidate is a number, returns a failure else.

  ## Examples

      iex> Validatex.Validations.number(12.2)
      %Validatex.Success{candidate: 12.2}

      iex> Validatex.Validations.number(12)
      %Validatex.Success{candidate: 12}

      iex> Validatex.Validations.number(nil)
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: nil, message: :not_a_number, context: Validatex.Validations}
      ]}
  """
  @spec number(any()) :: Core.validation_result_t(any())
  def number(val) when is_number(val), do: Core.pure(val)
  def number(val), do: failure_from_error(val, :not_a_number)

  @doc ~S"""
  Returns a validation success if the candidate is a pid, returns a failure else.

  ## Examples

      iex> Validatex.Validations.pid(self())
      %Validatex.Success{candidate: self()}

      iex> Validatex.Validations.pid(12)
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: 12, message: :not_a_pid, context: Validatex.Validations}
      ]}
  """
  @spec pid(any()) :: Core.validation_result_t(any())
  def pid(val) when is_pid(val), do: Core.pure(val)
  def pid(val), do: failure_from_error(val, :not_a_pid)

  @doc ~S"""
  Returns a validation success if the candidate is a port, returns a failure else.
  """
  @spec port(any()) :: Core.validation_result_t(any())
  def port(val) when is_port(val), do: Core.pure(val)
  def port(val), do: failure_from_error(val, :not_a_port)

  @doc ~S"""
  Returns a validation success if the candidate is a struct, returns a failure else.

  ## Examples

      iex> Validatex.Validations.struct(Validatex.Success.make("abc"))
      %Validatex.Success{candidate: Validatex.Success.make("abc")}

      iex> Validatex.Validations.struct(%{})
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: %{}, message: :not_a_struct, context: Validatex.Validations}
      ]}
  """
  @spec struct(any()) :: Core.validation_result_t(any())
  def struct(val) when is_struct(val), do: Core.pure(val)
  def struct(val), do: failure_from_error(val, :not_a_struct)

  @doc ~S"""
  Returns a validation success if the candidate is a reference, returns a failure else.

  ## Examples

      iex> ref = make_ref()
      iex> Validatex.Validations.reference(ref)
      %Validatex.Success{candidate: ref}

      iex> Validatex.Validations.reference(12)
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: 12, message: :not_a_reference, context: Validatex.Validations}
      ]}
  """
  @spec reference(any()) :: Core.validation_result_t(any())
  def reference(val) when is_reference(val), do: Core.pure(val)
  def reference(val), do: failure_from_error(val, :not_a_reference)

  @doc ~S"""
  Returns a validation success if the candidate is a tuple, returns a failure else.

  ## Examples

      iex> Validatex.Validations.tuple({1,2,3})
      %Validatex.Success{candidate: {1,2,3}}

      iex> Validatex.Validations.tuple([1,2,3])
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: [1,2,3], message: :not_a_tuple, context: Validatex.Validations}
      ]}
  """
  @spec tuple(any()) :: Core.validation_result_t(any())
  def tuple(val) when is_tuple(val), do: Core.pure(val)
  def tuple(val), do: failure_from_error(val, :not_a_tuple)

  @doc ~S"""
  Returns a validation success if the enum contains the elem, returns a failure else.

  ## Examples

      iex> Validatex.Validations.member([1,2,3], 1)
      %Validatex.Success{candidate: {[1,2,3], 1}}

      iex> Validatex.Validations.member([], 1)
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: {[], 1}, message: :not_a_member, context: Validatex.Validations}
      ]}

      iex> Validatex.Validations.member([1,2,3], 12)
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: {[1,2,3], 12}, message: :not_a_member, context: Validatex.Validations}
      ]}
  """
  @spec member(Enum.t(), any()) :: Core.validation_result_t(any())
  def member(enum, elem) do
    if Enum.member?(enum, elem) do
      Core.pure({enum, elem})
    else
      failure_from_error({enum, elem}, :not_a_member)
    end
  end

  @doc ~S"""
  Returns a validation success if the enum does not contain the elem, returns a failure else.

  ## Examples

      iex> Validatex.Validations.not_a_member([1,2,3], 4)
      %Validatex.Success{candidate: {[1,2,3], 4}}

      iex> Validatex.Validations.not_a_member([], 1)
      %Validatex.Success{candidate: {[], 1}}

      iex> Validatex.Validations.not_a_member([1,2,3], 1)
      %Validatex.Failure{errors: [
          %Validatex.Error{candidate: {[1,2,3], 1}, message: :is_a_member, context: Validatex.Validations}
      ]}
  """
  @spec not_a_member(Enum.t(), any()) :: Core.validation_result_t(any())
  def not_a_member(enum, elem) do
    if Enum.member?(enum, elem) do
      failure_from_error({enum, elem}, :is_a_member)
    else
      Core.pure({enum, elem})
    end
  end
end
