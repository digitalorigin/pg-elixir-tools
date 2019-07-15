defmodule ElixirTools.CardDate do
  @moduledoc """
  Helper functions for dealing with card date transformations and parsing.

  ## Dictionary of terms

  Term          | Description                           | Template    | Example     |
  --------------|---------------------------------------|-------------|-------------|
  `card_date`   | Date format used by CC issuers        | MM/YY       | 12/30       |
  `date`        | Elixir Date type                      | %Date{}     | ...         |
  `iso_date`    | ISO8601 string of the date            | YYYY-MM-DD  | 2030-12-15  |
  `short_year`  | Year written in the shortened format  | YY          | 19          |
  `full_year`   | Year written in the full format       | YYYY        | 2019        |
  """

  @invalid_format_error "Invalid card_date format"
  @invalid_date_error "Invalid Date provided"

  @typep card_date :: <<_::40>>
  @typep iso_date :: <<_::80>>
  @typep date :: Date.t()
  @typep day_opt :: pos_integer

  @doc """
  Transforms the `card_date` format into an Elixir %Date{} type.
  Since the `card_date` format does not contain a `day` value, it
  must also be supplied, otherwise the default `1` is taken.

  ## Examples

      iex> ElixirTools.CardDate.to_date!("12/19")
      ~D[2019-12-01]

      iex> ElixirTools.CardDate.to_date!("12/19", [day: 16])
      ~D[2019-12-16]

  """
  @typep to_date_opts :: [day: day_opt]
  @spec to_date!(card_date, to_date_opts) :: date
  def to_date!(card_date, opts \\ []) do
    day = opts[:day] || 1

    date =
      card_date
      |> parse_card_date!()
      |> NaiveDateTime.to_date()

    %Date{date | day: day}
  end

  @doc """
  Returns the `card_date` formatted as an ISO8601 string.
  Since the `card_date` format does not contain a `day` value, it
  must also be supplied, otherwise the default `1` is taken.

  ## Examples

      iex> ElixirTools.CardDate.to_iso_string!("12/19")
      "2019-12-01"

      iex> ElixirTools.CardDate.to_iso_string!("12/19", [day: 16])
      "2019-12-16"

  """
  @typep to_iso_string_opts :: [day: day_opt]
  @spec to_iso_string!(card_date, to_iso_string_opts) :: iso_date
  def to_iso_string!(card_date, opts \\ []) do
    card_date |> to_date!(opts) |> Date.to_iso8601()
  end

  @doc """
  Gets the integer value of the (full) `year` part of the `card_date`.

  ## Examples

      iex> ElixirTools.CardDate.get_year!("12/19")
      2019

  """
  @spec get_year!(card_date) :: non_neg_integer | no_return
  def get_year!(card_date) do
    date = parse_card_date!(card_date)
    date.year
  end

  @doc """
  Gets the integer value of the `month` part of the `card_date`.

  ## Examples

      iex> ElixirTools.CardDate.get_month!("12/19")
      12

  """
  @spec get_month!(card_date) :: pos_integer | no_return
  def get_month!(card_date) do
    date = parse_card_date!(card_date)
    date.month
  end

  @doc """
  Enforces that the provided `card_date` is in the correct format (mm/yy).
  If the format is correct, the same data is returned, and if it's incorrect
  an error is raised.

  ## Examples

      iex> ElixirTools.CardDate.enforce_card_date_format!("12/19")
      "12/19"

      iex> ElixirTools.CardDate.enforce_card_date_format!("12.19")
      ** (RuntimeError) Invalid card_date format

      iex> ElixirTools.CardDate.enforce_card_date_format!("2019-12-01")
      ** (RuntimeError) Invalid card_date format

      iex> ElixirTools.CardDate.enforce_card_date_format!(42)
      ** (RuntimeError) Invalid card_date format
  """
  @spec enforce_card_date_format!(term) :: card_date | no_return
  def enforce_card_date_format!(card_date) when is_binary(card_date) do
    if Regex.match?(~r/^\d\d\/\d\d$/, card_date) do
      card_date
    else
      raise @invalid_format_error
    end
  end

  def enforce_card_date_format!(_), do: raise(@invalid_format_error)

  @doc """
  Tries to parse the `card_date` into a NaiveDateTime. Raises a RuntimeError
  if unsuccessful.

  ## Examples

      iex> ElixirTools.CardDate.parse_card_date!("12/19")
      ~N[2019-12-01 00:00:00]

      iex> ElixirTools.CardDate.parse_card_date!(42)
      ** (RuntimeError) Invalid card_date format
  """
  @spec parse_card_date!(term) :: NaiveDateTime.t() | no_return
  def parse_card_date!(card_date) do
    card_date |> enforce_card_date_format!() |> Timex.parse!("{0M}/{YY}")
  rescue
    Timex.Parse.ParseError -> reraise(@invalid_format_error, __STACKTRACE__)
  end

  @typep date_param :: Date.t() | NaiveDateTime.t() | DateTime.t()
  @spec from_date!(date_param) :: <<_::40>> | no_return()
  def from_date!(date) do
    Timex.format!(date, "{0M}/{YY}")
  rescue
    ArgumentError -> reraise(@invalid_date_error, __STACKTRACE__)
  end
end
