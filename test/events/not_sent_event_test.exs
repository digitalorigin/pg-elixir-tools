defmodule ElixirTools.Events.NotSentEventTest do
  use ExUnit.Case, async: true

  alias ElixirTools.Events.NotSentEvent

  setup do
    %{valid_params: %{content: "content"}}
  end

  describe "changeset/1" do
    test "correct cast", %{valid_params: valid_params} do
      changeset = NotSentEvent.changeset(valid_params)
      assert changeset.valid?
      assert changeset.changes.content == valid_params[:content]
    end

    test "is not valid when content is missing", %{valid_params: valid_params} do
      params = Map.delete(valid_params, :content)
      changeset = NotSentEvent.changeset(params)
      refute changeset.valid?
    end
  end
end
