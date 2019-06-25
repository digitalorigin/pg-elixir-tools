defmodule ElixirTools.JsonApi.ViewTest do
  use ExUnit.Case

  defmodule CoolStruct do
    defstruct test: "a"
  end

  defmodule ViewImplTest do
    use ElixirTools.JsonApi.View

    attributes([:test, :value, :external_value])

    def external_value(_), do: "cool"
  end

  describe "render" do
    setup do
      valid_json_api = %{data: %{id: "123456", test: true, value: "string"}}

      expected_json_api_body = %{
        "jsonapi" => %{"version" => "1.0"},
        "data" => %{
          "id" => "123456",
          "type" => "impl-test",
          "attributes" => %{"external-value" => "cool", "test" => true, "value" => "string"}
        }
      }

      %{valid_json_api: valid_json_api, expected_json_api_body: expected_json_api_body}
    end

    test "renders the expected json api", context do
      json_api = ViewImplTest.render("index.json-api", context.valid_json_api)

      assert json_api == context.expected_json_api_body
    end

    test "filters out all non-json-api values", context do
      params = Map.merge(context.valid_json_api, %{invalid: :json_param})
      json_api = ViewImplTest.render("index.json-api", params)

      assert json_api == context.expected_json_api_body
    end

    test "translates _ in keys to -", context do
      json_api = ViewImplTest.render("index.json-api", context.valid_json_api)

      assert %{"data" => %{"attributes" => %{"external-value" => _}}} = json_api
    end

    test "translates struct into map", context do
      params = put_in(context.valid_json_api, [:data, :value], %CoolStruct{test: "a"})
      json_api = ViewImplTest.render("index.json-api", params)

      assert %{"data" => %{"attributes" => %{"value" => %{"test" => "a"}}}} = json_api
    end
  end

  describe "format_datetime/1" do
    test "formats the datetime to UTC0 and to iso8601" do
      time = %DateTime{
        year: 2019,
        month: 06,
        day: 20,
        hour: 19,
        minute: 05,
        second: 32,
        microsecond: {634_238, 6},
        time_zone: "Europe/Madrid",
        zone_abbr: "CEST",
        utc_offset: 3600,
        std_offset: 3600
      }

      expected = "2019-06-20T17:05:32.634238Z"
      assert ViewImplTest.format_datetime(time) == expected
    end
  end
end
