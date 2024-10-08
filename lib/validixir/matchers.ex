defmodule Validixir.Matchers do
  @moduledoc """
  This module contains helper macros to use in matching.

  These macros can be used in with and case-statements as well as
  function headers.

  Example:

      case validation_result do
        success(21) -> ...          # matches a success with candidate 21
        success() -> ...            # matches a success
        {:error, failure(:my_error)} -> ...   # matches a failure that has the message
                                    # :my_error somewhere in errors
        {:error, failure()} -> ...            # matches a failure
      end
  """
  defmacro success() do
    quote do
      {:ok, _}
    end
  end

  defmacro success(candidate) do
    quote do
      {:ok, unquote(candidate)}
    end
  end

  defmacro failure() do
    quote do
      %Validixir.Failure{}
    end
  end

  defmacro failure(message) do
    quote location: :keep do
      %Validixir.Failure{__message_lookup: %{unquote(message) => true}}
    end
  end
end
