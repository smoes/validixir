defmodule ValidixirTest do
  use ExUnit.Case
  doctest Validixir

  alias Example
  alias Validixir.Failure
  alias Validixir.Success
  alias Validixir.Error

  describe "The example code" do
    test "does not construct invalid addresses" do
      street = %{}
      number = -1
      zip = nil
      city = nil

      failure = Example.Address.make(street, number, zip, city)
      assert %Failure{} = failure

      context = {Example.Address, Validixir.Validations}

      assert failure.errors == [
               Error.make(street, :not_a_binary, context),
               Error.make(number, :not_a_positive_integer, context),
               Error.make(zip, :not_a_binary, context),
               Error.make(city, :not_a_binary, context)
             ]
    end

    test "does construct valid addresses" do
      street = "Jane Street"
      number = 1
      zip = "99999"
      city = "New York"

      success = Example.Address.make(street, number, city, zip)
      assert %Success{} = success

      candidate = success.candidate
      assert candidate.street == street
      assert candidate.number == number
      assert candidate.zip == zip
      assert candidate.city == city
    end

    test "does not construct invalid persons" do
      name = 1
      username = "this username is too long"
      email = "not an email"
      address = %{}

      failure = Example.Person.make(name, username, email, address)
      assert %Failure{} = failure

      assert failure.errors == [
               Error.make(name, :not_a_binary, {Example.Person, Validixir.Validations}),
               Error.make(username, :longer_than_10, Example.Person),
               Error.make(email, :not_an_email, Example.Person),
               Error.make(address, :not_an_address, Example.Person)
             ]
    end

    test "does construct valid persons" do
      # credentials for a valid person
      name = "Simon"
      username = "smoes"
      email = "smoes@github.com"

      # ... but construct valid address first
      street = "Jane Street"
      number = 1
      zip = "99999"
      city = "New York"

      result =
        Example.Address.make(street, number, city, zip)
        # then ignore what the result would be and just continue
        # as if it is a success
        |> Validixir.and_then(fn address ->
          Example.Person.make(name, username, email, address)
        end)

      assert %Success{} = result
      candidate = result.candidate

      assert candidate.name == name
      assert candidate.username == username
      assert candidate.email == email
      # we dont have to check address - we know it's valid :)
    end
  end
end
