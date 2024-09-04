defmodule Validixir.MatchersTest do
  use ExUnit.Case

  import Validixir.Matchers

  describe "failure" do
    test "can be used to match error message" do
      failure =
        Validixir.Failure.make([
          Validixir.Error.make(:candidate, :message_1, :context_1),
          Validixir.Error.make(:candidate, :message_2, :context_2)
        ])

      res =
        case failure do
          {:error, failure(:message_1)} -> true
          _ -> false
        end

      assert res

      res =
        case failure do
          {:error, failure(:message_2)} -> true
          _ -> false
        end

      assert res

      res =
        case failure do
          {:error, failure(:message_3)} -> true
          _ -> false
        end

      refute res
    end

    test "can be used to match a deep error message" do
      failure =
        Validixir.Failure.make([
          Validixir.Error.make(:candidate, [:index, :message_1], :context_1),
          Validixir.Error.make(:candidate, [:index, :message_2], :context_2)
        ])

      res =
        case failure do
          {:error, failure(:message_1)} -> true
          _ -> false
        end

      assert res

      res =
        case failure do
          {:error, failure(:message_1)} -> true
          _ -> false
        end

      assert res
    end
  end

  describe "failure/0" do
    test "can be used to match failures" do
      failure =
        Validixir.Failure.make([
          Validixir.Error.make(:candidate, :message_1, :context_1),
          Validixir.Error.make(:candidate, :message_2, :context_2)
        ])

      res =
        case failure do
          {:error, failure()} -> true
          _ -> false
        end

      assert res

      res =
        case Validixir.success(1) do
          {:error, failure()} -> true
          _ -> false
        end

      refute res
    end
  end

  describe "success/0" do
    test "can be used to match successes" do
      res =
        case Validixir.success(1) do
          success() -> true
          _ -> false
        end

      assert res

      failure =
        Validixir.Failure.make([
          Validixir.Error.make(:candidate, :message_1, :context_1),
          Validixir.Error.make(:candidate, :message_2, :context_2)
        ])

      res =
        case failure do
          success() -> true
          _ -> false
        end

      refute res
    end
  end

  describe "success/1" do
    test "can be used to match success candidates" do
      res =
        case Validixir.success(1) do
          success(1) -> true
          _ -> false
        end

      assert res

      res =
        case Validixir.success(2) do
          success(1) -> true
          _ -> false
        end

      refute res
    end
  end
end
