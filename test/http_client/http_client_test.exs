defmodule ElixirTools.HttpClientTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias ElixirTools.HttpClient

  defmodule FakeAdapter do
    @behaviour ElixirTools.HttpClient.Adapter

    @impl true
    def base_uri(), do: "http://test.com/"
  end

  defmodule InvalidBasePathAdapter do
    @behaviour ElixirTools.HttpClient.Adapter

    @impl true
    def base_uri(), do: ""
  end

  defmodule FakeHttpClient do
    use ElixirTools.ContractImpl, module: ElixirTools.HttpClient

    @impl true
    def get(url, headers, options \\ []) do
      send(self(), [url, headers, options])
      {:ok, %{body: "{\"foo\": \"bar\"}"}}
    end

    @impl true
    def post(url, body, headers, options \\ []) do
      send(self(), [url, body, headers, options])
      {:ok, %{body: "{\"foo\": \"bar\"}"}}
    end

    @impl true
    def put(url, body, headers, options \\ []) do
      send(self(), [url, body, headers, options])
      {:ok, %{body: "{\"foo\": \"bar\"}"}}
    end
  end

  defmodule TimeoutHttpClient do
    use ElixirTools.ContractImpl, module: ElixirTools.HttpClient

    @impl true
    def post(_url, _body, _headers, _options) do
      {:error, %HTTPoison.Error{id: nil, reason: :timeout}}
    end
  end

  describe "get/3" do
    test "it correctly processes empty responses" do
      defmodule HttpClientEmpty do
        use ElixirTools.ContractImpl, module: HTTPoison

        @impl true
        def get(_, _, _) do
          {:ok,
           %HTTPoison.Response{
             body: "",
             headers: [],
             request_url: "test",
             status_code: 200
           }}
        end
      end

      expected_response =
        {:ok,
         %HTTPoison.Response{
           body: "",
           headers: [],
           request: nil,
           request_url: "test",
           status_code: 200
         }}

      assert HttpClient.get(FakeAdapter, "path", [{:http_client, HttpClientEmpty}]) ==
               expected_response
    end

    test "when provider returns a reply that is not json" do
      defmodule HttpClientNotJson do
        use ElixirTools.ContractImpl, module: HTTPoison

        @impl true
        def get(_, _, _) do
          {:ok,
           %HTTPoison.Response{
             body: "invalid_json}",
             headers: [],
             request_url: "test",
             status_code: 200
           }}
        end
      end

      expected_message = "Invalid JSON returned from provider. Given: \"invalid_json}\""

      assert_raise(RuntimeError, expected_message, fn ->
        assert HttpClient.get(FakeAdapter, "path", [{:http_client, HttpClientNotJson}])
      end)
    end

    test "If a legit JSON is returned, parse and return the json in the body" do
      defmodule HttpClientValid do
        use ElixirTools.ContractImpl, module: HTTPoison

        @impl true
        def get(_, _, _) do
          {:ok,
           %HTTPoison.Response{
             body: ~s[{"test": "valid_json"}],
             headers: [],
             request_url: "test",
             status_code: 200
           }}
        end
      end

      expected_response =
        {:ok,
         %HTTPoison.Response{
           body: %{"test" => "valid_json"},
           headers: [],
           request_url: "test",
           status_code: 200
         }}

      assert HttpClient.get(FakeAdapter, "path", [{:http_client, HttpClientValid}]) ==
               expected_response
    end

    test "if the request reaches a timeout return a timeout error tuple" do
      defmodule HttpClientTimeout do
        use ElixirTools.ContractImpl, module: HTTPoison

        @impl true
        def get(_, _, _), do: {:error, %HTTPoison.Error{reason: :timeout}}
      end

      expected_response = {:error, :http_timeout}

      assert HttpClient.get(FakeAdapter, "path", [{:http_client, HttpClientTimeout}]) ==
               expected_response
    end

    test "If connection is closed, retry once and return the http client response" do
      defmodule HttpClientClosed do
        use ElixirTools.ContractImpl, module: HTTPoison

        @impl true
        def get(_, _, _), do: {:error, %HTTPoison.Error{reason: :closed, id: "closed_id"}}
      end

      expected_response = {:error, %HTTPoison.Error{id: "closed_id", reason: :closed}}

      assert HttpClient.get(FakeAdapter, "path", [{:http_client, HttpClientClosed}]) ==
               expected_response
    end

    test "If an unhandled http client error is passed, return it" do
      defmodule HttpClientError do
        use ElixirTools.ContractImpl, module: HTTPoison

        @impl true
        def get(_, _, _),
          do: {:error, %HTTPoison.Error{reason: :some_random_error_reason, id: "unhandled_id"}}
      end

      expected_response =
        {:error, %HTTPoison.Error{id: "unhandled_id", reason: :some_random_error_reason}}

      assert HttpClient.get(FakeAdapter, "path", [{:http_client, HttpClientError}]) ==
               expected_response
    end

    test "If an empty base_uri is set, raise an error" do
      path = "/path"

      assert_raise RuntimeError, "No valid provider base URI set in the config", fn ->
        HttpClient.get(InvalidBasePathAdapter, path, http_client: FakeHttpClient)
      end
    end

    test "allows other http_client" do
      path = "/path"

      HttpClient.get(FakeAdapter, path, http_client: FakeHttpClient)

      assert_received([%{path: ^path}, _, _])
    end

    test "overrides headers" do
      path = "/test-headers"

      custom_headers = [{"ContentType", "application/soap+xml"}]

      HttpClient.get(FakeAdapter, path, headers: custom_headers, http_client: FakeHttpClient)

      assert_received([%{path: ^path}, ^custom_headers, _opts])
    end

    test "we send the option to extend the timeout" do
      url = "test-opts"
      {:ok, _} = HttpClient.get(FakeAdapter, url, http_client: FakeHttpClient)

      timeout =
        Application.get_env(:pagantis_elixir_tools, ElixirTools.HttpClient)[:response_timeout]

      expected_ops = [recv_timeout: timeout]

      assert_received([_url, _headers, ^expected_ops])
    end

    test "decodes json response body to map" do
      url = "test-headers"
      {:ok, response} = HttpClient.get(FakeAdapter, url, http_client: FakeHttpClient)
      assert response.body == %{"foo" => "bar"}
    end
  end

  describe "post/4" do
    test "If an empty base_uri is set, raise an error" do
      path = "/path"
      body = "some cool body"

      assert_raise RuntimeError, "No valid provider base URI set in the config", fn ->
        HttpClient.post(InvalidBasePathAdapter, path, body, http_client: FakeHttpClient)
      end
    end

    test "allows other http_client" do
      path = "/path"
      body = "some cool body"

      HttpClient.post(FakeAdapter, path, body, http_client: FakeHttpClient)

      assert_received([%{path: ^path}, ^body, _, _])
    end

    test "add headers" do
      path = "/test-headers"
      body = :skipped
      headers_to_add = [{"HeaderToAdd", "value"}, {"HeaderToAdd2", "value"}]

      HttpClient.post(FakeAdapter, path, body,
        headers_to_add: headers_to_add,
        http_client: FakeHttpClient
      )

      assert_received([%{path: ^path}, ^body, headers, _opts])
      assert Enum.member?(headers, {"HeaderToAdd", "value"})
      assert Enum.member?(headers, {"HeaderToAdd2", "value"})
    end

    test "overrides headers" do
      path = "/test-headers"
      body = :skipped
      custom_headers = [{"ContentType", "application/soap+xml"}]

      HttpClient.post(FakeAdapter, path, body,
        headers: custom_headers,
        http_client: FakeHttpClient
      )

      assert_received([%{path: ^path}, ^body, ^custom_headers, _opts])
    end

    test "we send the option to extend the timeout" do
      url = "test-opts"
      body = :skipped
      {:ok, _} = HttpClient.post(FakeAdapter, url, body, http_client: FakeHttpClient)

      timeout =
        Application.get_env(:pagantis_elixir_tools, ElixirTools.HttpClient)[:response_timeout]

      expected_ops = [recv_timeout: timeout]

      assert_received([_url, _body, _headers, ^expected_ops])
    end

    test "decodes json response body to map" do
      url = "test-headers"
      body = :skipped
      {:ok, response} = HttpClient.post(FakeAdapter, url, body, http_client: FakeHttpClient)
      assert response.body == %{"foo" => "bar"}
    end
  end

  describe "post/4 connection errors" do
    test "returns expected response when connection times out" do
      path = "/path"
      body = "some cool body"

      response = HttpClient.post(FakeAdapter, path, body, http_client: TimeoutHttpClient)

      assert response == {:error, :http_timeout}
    end
  end

  describe "put/4" do
    test "If an empty base_uri is set, raise an error" do
      path = "/path"
      body = "some cool body"

      assert_raise RuntimeError, "No valid provider base URI set in the config", fn ->
        HttpClient.put(InvalidBasePathAdapter, path, body, http_client: FakeHttpClient)
      end
    end

    test "allows other http_client" do
      path = "/path"
      body = "some cool body"

      HttpClient.put(FakeAdapter, path, body, http_client: FakeHttpClient)

      assert_received([%{path: ^path}, ^body, _, _])
    end

    test "overrides headers" do
      path = "/test-headers"
      body = :skipped
      custom_headers = [{"ContentType", "application/soap+xml"}]

      HttpClient.put(FakeAdapter, path, body, headers: custom_headers, http_client: FakeHttpClient)

      assert_received([%{path: ^path}, ^body, ^custom_headers, _opts])
    end

    test "we send the option to extend the timeout" do
      url = "test-opts"
      body = :skipped
      {:ok, _} = HttpClient.put(FakeAdapter, url, body, http_client: FakeHttpClient)

      timeout =
        Application.get_env(:pagantis_elixir_tools, ElixirTools.HttpClient)[:response_timeout]

      expected_ops = [recv_timeout: timeout]

      assert_received([_url, _body, _headers, ^expected_ops])
    end

    test "decodes json response body to map" do
      url = "test-headers"
      body = :skipped
      {:ok, response} = HttpClient.put(FakeAdapter, url, body, http_client: FakeHttpClient)
      assert response.body == %{"foo" => "bar"}
    end
  end

  test "when the http_timeout is not set correctly, it warns and returns the default" do
    original_config = Application.get_env(:pagantis_elixir_tools, ElixirTools.HttpClient)

    on_exit(fn ->
      Application.put_env(:pagantis_elixir_tools, ElixirTools.HttpClient, original_config)
    end)

    Application.put_env(
      :pagantis_elixir_tools,
      ElixirTools.HttpClient,
      Keyword.delete(original_config, :response_timeout)
    )

    log =
      capture_log(fn -> HttpClient.get(FakeAdapter, "path", [{:http_client, FakeHttpClient}]) end)

    assert log =~ "nil is not valid for response_timeout. Using default 1000"
  end
end
