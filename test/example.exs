defmodule Example do
  @moduledoc """
  Example code that shows how the library is intended to be used.
  """

  alias Validixir.Validations
  alias Validixir.Failure
  alias Validixir.Success

  defmodule Address do
    alias __MODULE__

    @type t :: %Address{
            street: String.t(),
            number: pos_integer(),
            city: String.t(),
            zip: String.t()
          }

    @enforce_keys [:street, :number, :city, :zip]
    defstruct [:street, :number, :city, :zip]

    defp make_unsafe(street, number, city, zip),
      do: %Address{street: street, number: number, city: city, zip: zip}

    @spec make(String.t(), pos_integer(), String.t(), String.t()) ::
            Validixir.validation_result_t(t())
    def make(street, number, city, zip) do
      # We validate the domain object in the constructor.
      # If we only use that function to create addresses, all addresses
      # in the system are valid.
      Validixir.validate(
        &make_unsafe/4,
        [
          Validations.binary(street),
          Validations.pos_integer(number),
          Validations.binary(city),
          Validations.binary(zip)
        ]
      )
      # We augment the context here, so that we see, the errors occur in
      # Example.Address. This seems trivial but can be hard to track in
      # huge projects.
      |> Validixir.augment_contexts(Example.Address)
    end

    @spec address?(any()) :: boolean()
    def address?(%Address{}), do: true
    def address?(_), do: false
  end

  defmodule Person do
    alias __MODULE__

    @type t :: %Person{
            name: String.t(),
            username: String.t(),
            email: String.t(),
            address: Address.t()
          }

    @enforce_keys [:name, :username, :email, :address]
    defstruct [:name, :username, :email, :address]

    defp make_unsafe(name, username, email, address),
      do: %Person{name: name, username: username, email: email, address: address}

    @spec validate_username_helper(String.t()) :: Validixir.validation_result_t(String.t())
    defp validate_username_helper(username) do
      # We write our own validation here.
      # Validators are nothing more than functions that return a validation result.
      cond do
        String.length(username) > 10 ->
          Failure.make_from_error(username, :longer_than_10, Example.Person)

        String.contains?(username, "!") ->
          Failure.make_from_error(username, :contains_bang, Example.Person)

        true ->
          Success.make(username)
      end
    end

    @spec validate_username(any()) :: Validixir.validation_result_t(String.t())
    defp validate_username(username),
      # here we combine already existing validation with our own custom validation
      do: Validations.binary(username) |> Validixir.and_then(&validate_username_helper/1)

    @spec validate_is_address(any()) :: Validixir.validation_result_t(Address.t())
    defp validate_is_address(address = %Address{}), do: Success.make(address)

    defp validate_is_address(address),
      do: Failure.make_from_error(address, :not_an_address, Example.Person)

    @spec validate_email_helper(String.t()) :: Validxir.validation_result_t(String.t())
    defp validate_email_helper(email) do
      # this ofc isn't enough ;)
      if String.contains?(email, "@") do
        Success.make(email)
      else
        Failure.make_from_error(email, :not_an_email, Example.Person)
      end
    end

    @spec validate_email(any()) :: Validixr.validation_result_t(String.t())
    defp validate_email(email),
      do: Validations.binary(email) |> Validixir.and_then(&validate_email_helper/1)

    @spec make(String.t(), String.t(), String.t(), Address.t()) :: t()
    def make(name, username, email, address) do
      # We validate the domain object in the constructor.
      # If we only use that function to create persons, all persons
      # in the system are valid. Be aware, that it already receives
      # a valid address if we follow that scheme.
      Validixir.validate(
        &make_unsafe/4,
        [
          Validations.binary(name) |> Validixir.augment_contexts(Example.Person),
          validate_username(username),
          validate_email(email),
          validate_is_address(address)
        ]
      )
    end
  end
end
