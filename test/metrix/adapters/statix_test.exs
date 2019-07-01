defmodule ElixirTools.Metrix.Adapters.StatixTest do
  use ExUnit.Case, async: true

  alias ElixirTools.Metrix.Adapters.Statix

  describe "to_tags/1" do
    test "formats and returns the right tags" do
      tags = %{
        abc: 123,
        test: "string",
        boolean: true
      }

      assert Statix.to_tags(tags) == [tags: ["abc:123", "boolean:true", "test:string"]]
    end
  end
end
