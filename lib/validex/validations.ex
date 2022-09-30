defmodule Validex.Validations do
  @moduledoc """
  This module contains premade validations for basic elixir types and often used
  functionality.
  """

  alias Validex, as: Core
  alias Validex.Success, as: Success
  alias Validex.Failure, as: Failure
  alias Validex.Error, as: Error

  @spec failure_from_error(any(), any()) :: Failure.t()
  defp failure_from_error(candidate, message),
    do: [Error.make(candidate, message, Validex.Validations)] |> Failure.make()

  @doc ~S"""
  Always returns a validation success. 

  ## Examples

      iex> Validex.Validations.succeed(12)
      %Validex.Success{candidate: 12}

  """
  @spec succeed(any()) :: Success.t()
  def succeed(candidate), do: Core.pure(candidate)

  @doc ~S"""
  Returns a validation success if the candidate is an atom, returns a failure else.

  ## Examples

      iex> Validex.Validations.atom(:hello)
      %Validex.Success{candidate: :hello}

      iex> Validex.Validations.atom(12)
      %Validex.Failure{errors: [
          %Validex.Error{candidate: 12, message: :not_an_atom, context: Validex.Validations}
      ]}

  """
  @spec atom(any()) :: Core.validation_result_t()
  def atom(val) when is_atom(val), do: Core.pure(val)
  def atom(val), do: failure_from_error(val, :not_an_atom)

  @doc ~S"""
  Returns a validation success if the candidate is a bitstring, returns a failure else.

  ## Examples

      iex> Validex.Validations.bitstring("foo")
      %Validex.Success{candidate: "foo"}

      iex> Validex.Validations.bitstring(<<1::3>>)
      %Validex.Success{candidate: <<1::3>>}

      iex> Validex.Validations.bitstring(12)
      %Validex.Failure{errors: [
          %Validex.Error{candidate: 12, message: :not_a_bitstring, context: Validex.Validations}
      ]}

  """
  @spec bitstring(any()) :: Core.validation_result_t()
  def bitstring(val) when is_bitstring(val), do: Core.pure(val)
  def bitstring(val), do: failure_from_error(val, :not_a_bitstring)

  @doc ~S"""
  Returns a validation success if the candidate is a binary, returns a failure else.

  ## Examples

      iex> Validex.Validations.binary("foo")
      %Validex.Success{candidate: "foo"}

      iex> Validex.Validations.binary(<<1::3>>)
      %Validex.Failure{errors: [
          %Validex.Error{candidate: <<1::3>>, message: :not_a_binary, context: Validex.Validations}
      ]}

  """
  @spec binary(any()) :: Core.validation_result_t()
  def binary(val) when is_binary(val), do: Core.pure(val)
  def binary(val), do: failure_from_error(val, :not_a_binary)

  @doc ~S"""
  Returns a validation success if the candidate is a boolean, returns a failure else.

  ## Examples

      iex> Validex.Validations.boolean(true)
      %Validex.Success{candidate: true}

      iex> Validex.Validations.boolean(nil)
      %Validex.Failure{errors: [
          %Validex.Error{candidate: nil, message: :not_a_boolean, context: Validex.Validations}
      ]}

  """
  @spec boolean(any()) :: Core.validation_result_t()
  def boolean(val) when is_boolean(val), do: Core.pure(val)
  def boolean(val), do: failure_from_error(val, :not_a_boolean)

  @doc ~S"""
  Returns a validation success if the candidate is an exception, returns a failure else.

  ## Examples

      iex> Validex.Validations.exception(%RuntimeError{})
      %Validex.Success{candidate: %RuntimeError{}}

      iex> Validex.Validations.exception(%{})
      %Validex.Failure{errors: [
          %Validex.Error{candidate: %{}, message: :not_an_exception, context: Validex.Validations}
      ]}

  """
  @spec exception(any()) :: Core.validation_result_t()
  def exception(val) when is_exception(val), do: Core.pure(val)
  def exception(val), do: failure_from_error(val, :not_an_exception)

  @doc ~S"""
  Returns a validation success if the candidate is a float, returns a failure else.

  ## Examples

      iex> Validex.Validations.float(12.2)
      %Validex.Success{candidate: 12.2}

      iex> Validex.Validations.float(12)
      %Validex.Failure{errors: [
          %Validex.Error{candidate: 12, message: :not_a_float, context: Validex.Validations}
      ]}

  """
  @spec float(any()) :: Core.validation_result_t()
  def float(val) when is_float(val), do: Core.pure(val)
  def float(val), do: failure_from_error(val, :not_a_float)

  @doc ~S"""
  Returns a validation success if the candidate is a function, returns a failure else.

  ## Examples

      iex> Validex.Validations.function(&Validex.pure/1)
      %Validex.Success{candidate: &Validex.pure/1}

      iex> Validex.Validations.function(12)
      %Validex.Failure{errors: [
          %Validex.Error{candidate: 12, message: :not_a_function, context: Validex.Validations}
      ]}

  """
  @spec function(any()) :: Core.validation_result_t()
  def function(val) when is_function(val), do: Core.pure(val)
  def function(val), do: failure_from_error(val, :not_a_function)

  @doc ~S"""
  Returns a validation success if the candidate is an integer, returns a failure else.

  ## Examples

      iex> Validex.Validations.integer(12)
      %Validex.Success{candidate: 12}

      iex> Validex.Validations.integer(12.2)
      %Validex.Failure{errors: [
          %Validex.Error{candidate: 12.2, message: :not_an_integer, context: Validex.Validations}
      ]}

  """
  @spec integer(any()) :: Core.validation_result_t()
  def integer(val) when is_integer(val), do: Core.pure(val)
  def integer(val), do: failure_from_error(val, :not_an_integer)

  @doc ~S"""
  Returns a validation success if the candidate is a positive integer, returns a failure else.

  ## Examples

      iex> Validex.Validations.pos_integer(12)
      %Validex.Success{candidate: 12}

      iex> Validex.Validations.pos_integer(0)
      %Validex.Failure{errors: [
          %Validex.Error{candidate: 0, message: :not_a_positive_integer, context: Validex.Validations}
      ]}

      iex> Validex.Validations.pos_integer(-2)
      %Validex.Failure{errors: [
          %Validex.Error{candidate: -2, message: :not_a_positive_integer, context: Validex.Validations}
      ]}
  """
  @spec pos_integer(any()) :: Core.validation_result_t()
  def pos_integer(val) when is_integer(val) and val > 0, do: Core.pure(val)
  def pos_integer(val), do: failure_from_error(val, :not_a_positive_integer)

  @doc ~S"""
  Returns a validation success if the candidate is a negative integer, returns a failure else.

  ## Examples

      iex> Validex.Validations.neg_integer(-12)
      %Validex.Success{candidate: -12}

      iex> Validex.Validations.neg_integer(0)
      %Validex.Failure{errors: [
          %Validex.Error{candidate: 0, message: :not_a_negative_integer, context: Validex.Validations}
      ]}

      iex> Validex.Validations.neg_integer(2)
      %Validex.Failure{errors: [
          %Validex.Error{candidate: 2, message: :not_a_negative_integer, context: Validex.Validations}
      ]}
  """
  @spec neg_integer(any()) :: Core.validation_result_t()
  def neg_integer(val) when is_integer(val) and val < 0, do: Core.pure(val)
  def neg_integer(val), do: failure_from_error(val, :not_a_negative_integer)

  @doc ~S"""
  Returns a validation success if the candidate is a list, returns a failure else.

  ## Examples

      iex> Validex.Validations.list([1, 2, 3])
      %Validex.Success{candidate: [1,2,3]}

      iex> Validex.Validations.list([])
      %Validex.Success{candidate: []}

      iex> Validex.Validations.list(%{})
      %Validex.Failure{errors: [
          %Validex.Error{candidate: %{}, message: :not_a_list, context: Validex.Validations}
      ]}
  """
  @spec list(any()) :: Core.validation_result_t()
  def list(val) when is_list(val), do: Core.pure(val)
  def list(val), do: failure_from_error(val, :not_a_list)

  @doc ~S"""
  Returns a validation success if the candidate is an empty list, returns a failure else.

  ## Examples

      iex> Validex.Validations.empty_list([])
      %Validex.Success{candidate: []}

      iex> Validex.Validations.empty_list([1,2,3])
      %Validex.Failure{errors: [
          %Validex.Error{candidate: [1,2,3], message: :not_an_empty_list, context: Validex.Validations}
      ]}

      iex> Validex.Validations.empty_list(%{})
      %Validex.Failure{errors: [
          %Validex.Error{candidate: %{}, message: :not_an_empty_list, context: Validex.Validations}
      ]}
  """
  @spec empty_list(any()) :: Core.validation_result_t()
  def empty_list(val) when is_list(val) and length(val) == 0, do: Core.pure(val)
  def empty_list(val), do: failure_from_error(val, :not_an_empty_list)

  @doc ~S"""
  Returns a validation success if the candidate is an non-empty list, returns a failure else.

  ## Examples

      iex> Validex.Validations.non_empty_list([1,2,3])
      %Validex.Success{candidate: [1,2,3]}

      iex> Validex.Validations.non_empty_list([])
      %Validex.Failure{errors: [
          %Validex.Error{candidate: [], message: :not_a_non_empty_list, context: Validex.Validations}
      ]}

      iex> Validex.Validations.non_empty_list(%{})
      %Validex.Failure{errors: [
          %Validex.Error{candidate: %{}, message: :not_a_non_empty_list, context: Validex.Validations}
      ]}
  """
  @spec non_empty_list(any()) :: Core.validation_result_t()
  def non_empty_list(val) when is_list(val) and length(val) > 0, do: Core.pure(val)
  def non_empty_list(val), do: failure_from_error(val, :not_a_non_empty_list)

  @doc ~S"""
  Returns a validation success if the candidate is a map, returns a failure else.

  ## Examples

      iex> Validex.Validations.map(%{})
      %Validex.Success{candidate: %{}}

      iex> Validex.Validations.map(%Validex.Success{candidate: 12})
      %Validex.Success{candidate: %Validex.Success{candidate: 12}}

      iex> Validex.Validations.map([])
      %Validex.Failure{errors: [
          %Validex.Error{candidate: [], message: :not_a_map, context: Validex.Validations}
      ]}
  """
  @spec map(any()) :: Core.validation_result_t()
  def map(val) when is_map(val), do: Core.pure(val)
  def map(val), do: failure_from_error(val, :not_a_map)

  @doc ~S"""
  Returns a validation success if the given map contains the given key, returns a failure else.

  ## Examples

      iex> Validex.Validations.map_key(%{hello: :world}, :hello)
      %Validex.Success{candidate: {%{hello: :world}, :hello}}

      iex> Validex.Validations.map_key(%{}, :hello)
      %Validex.Failure{errors: [
          %Validex.Error{candidate: {%{}, :hello}, message: :not_a_key_of_map, context: Validex.Validations}
      ]}
  """
  @spec map_key(map(), any()) :: Core.validation_result_t()
  def map_key(m, k) when is_map_key(m, k), do: Core.pure({m, k})
  def map_key(m, k), do: failure_from_error({m, k}, :not_a_key_of_map)

  @doc ~S"""
  Returns a validation success if the candidate is nil, returns a failure else.
  Since all other names are special words in elixir, we chose `nil?` as the function name.

  ## Examples

      iex> Validex.Validations.nil?(nil)
      %Validex.Success{candidate: nil}

      iex> Validex.Validations.nil?(12)
      %Validex.Failure{errors: [
          %Validex.Error{candidate: 12, message: :not_nil, context: Validex.Validations}
      ]}
  """
  @spec nil?(any()) :: Core.validation_result_t()
  def nil?(val) when is_nil(val), do: Core.pure(val)
  def nil?(val), do: failure_from_error(val, :not_nil)

  @doc ~S"""
  Returns a validation success if the candidate is not nil, returns a failure else.

  ## Examples

      iex> Validex.Validations.not_nil(12)
      %Validex.Success{candidate: 12}

      iex> Validex.Validations.not_nil(nil)
      %Validex.Failure{errors: [
          %Validex.Error{candidate: nil, message: :is_nil, context: Validex.Validations}
      ]}
  """
  @spec not_nil(any()) :: Core.validation_result_t()
  def not_nil(val) when is_nil(val), do: failure_from_error(val, :is_nil)
  def not_nil(val), do: Core.pure(val)

  @doc ~S"""
  Returns a validation success if the candidate is a number, returns a failure else.

  ## Examples

      iex> Validex.Validations.number(12.2)
      %Validex.Success{candidate: 12.2}

      iex> Validex.Validations.number(12)
      %Validex.Success{candidate: 12}

      iex> Validex.Validations.number(nil)
      %Validex.Failure{errors: [
          %Validex.Error{candidate: nil, message: :not_a_number, context: Validex.Validations}
      ]}
  """
  @spec number(any()) :: Core.validation_result_t()
  def number(val) when is_number(val), do: Core.pure(val)
  def number(val), do: failure_from_error(val, :not_a_number)

  @doc ~S"""
  Returns a validation success if the candidate is a pid, returns a failure else.

  ## Examples

      iex> Validex.Validations.pid(self())
      %Validex.Success{candidate: self()}

      iex> Validex.Validations.pid(12)
      %Validex.Failure{errors: [
          %Validex.Error{candidate: 12, message: :not_a_pid, context: Validex.Validations}
      ]}
  """
  @spec pid(any()) :: Core.validation_result_t()
  def pid(val) when is_pid(val), do: Core.pure(val)
  def pid(val), do: failure_from_error(val, :not_a_pid)

  @doc ~S"""
  Returns a validation success if the candidate is a port, returns a failure else.
  """
  @spec port(any()) :: Core.validation_result_t()
  def port(val) when is_port(val), do: Core.pure(val)
  def port(val), do: failure_from_error(val, :not_a_port)

  @doc ~S"""
  Returns a validation success if the candidate is a struct, returns a failure else.

  ## Examples

      iex> Validex.Validations.struct(Validex.Success.make("abc"))
      %Validex.Success{candidate: Validex.Success.make("abc")}

      iex> Validex.Validations.struct(%{})
      %Validex.Failure{errors: [
          %Validex.Error{candidate: %{}, message: :not_a_struct, context: Validex.Validations}
      ]}
  """
  @spec struct(any()) :: Core.validation_result_t()
  def struct(val) when is_struct(val), do: Core.pure(val)
  def struct(val), do: failure_from_error(val, :not_a_struct)

  @doc ~S"""
  Returns a validation success if the candidate is a reference, returns a failure else.

  ## Examples

      iex> ref = make_ref()
      iex> Validex.Validations.reference(ref)
      %Validex.Success{candidate: ref}

      iex> Validex.Validations.reference(12)
      %Validex.Failure{errors: [
          %Validex.Error{candidate: 12, message: :not_a_reference, context: Validex.Validations}
      ]}
  """
  @spec reference(any()) :: Core.validation_result_t()
  def reference(val) when is_reference(val), do: Core.pure(val)
  def reference(val), do: failure_from_error(val, :not_a_reference)

  @doc ~S"""
  Returns a validation success if the candidate is a tuple, returns a failure else.

  ## Examples

      iex> Validex.Validations.tuple({1,2,3})
      %Validex.Success{candidate: {1,2,3}}

      iex> Validex.Validations.tuple([1,2,3])
      %Validex.Failure{errors: [
          %Validex.Error{candidate: [1,2,3], message: :not_a_tuple, context: Validex.Validations}
      ]}
  """
  @spec tuple(any()) :: Core.validation_result_t()
  def tuple(val) when is_tuple(val), do: Core.pure(val)
  def tuple(val), do: failure_from_error(val, :not_a_tuple)

  @doc ~S"""
  Returns a validation success if the enum contains the elem, returns a failure else.

  ## Examples

      iex> Validex.Validations.member([1,2,3], 1)
      %Validex.Success{candidate: {[1,2,3], 1}}

      iex> Validex.Validations.member([], 1)
      %Validex.Failure{errors: [
          %Validex.Error{candidate: {[], 1}, message: :not_a_member, context: Validex.Validations}
      ]}

      iex> Validex.Validations.member([1,2,3], 12)
      %Validex.Failure{errors: [
          %Validex.Error{candidate: {[1,2,3], 12}, message: :not_a_member, context: Validex.Validations}
      ]}
  """
  @spec member(Enum.t(), any()) :: Core.validation_result_t()
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

      iex> Validex.Validations.not_a_member([1,2,3], 4)
      %Validex.Success{candidate: {[1,2,3], 4}}

      iex> Validex.Validations.not_a_member([], 1)
      %Validex.Success{candidate: {[], 1}}

      iex> Validex.Validations.not_a_member([1,2,3], 1)
      %Validex.Failure{errors: [
          %Validex.Error{candidate: {[1,2,3], 1}, message: :is_a_member, context: Validex.Validations}
      ]}
  """
  @spec not_a_member(Enum.t(), any()) :: Core.validation_result_t()
  def not_a_member(enum, elem) do
    if Enum.member?(enum, elem) do
      failure_from_error({enum, elem}, :is_a_member)
    else
      Core.pure({enum, elem})
    end
  end
end
