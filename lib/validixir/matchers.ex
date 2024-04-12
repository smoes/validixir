defmodule Validixir.Matchers do
  @moduledoc """
  This module contains helper macros to use in matching.

  These macros can be used in with and case-statements as well as
  function headers.

  Example:

      case validation_result do
        success(21) -> ...          # matches a success with candidate 21
        success() -> ...            # matches a success
        failure(:my_error) -> ...   # matches a failure that has the message
                                    # :my_error somewhere in errors
        failure() -> ...            # matches a failure
      end
  """
  defmacro success() do
    quote do
      %Validixir.Success{}
    end
  end

  defmacro success(candidate) do
    quote do
      %Validixir.Success{candidate: unquote(candidate)}
    end
  end

  defmacro failure() do
    quote do
      %Validixir.Failure{}
    end
  end

  defmacro failure(message) do
    quote location: :keep do
      %Validixir.Failure{message_lookup: %{unquote(message) => true}}
    end
  end
end
