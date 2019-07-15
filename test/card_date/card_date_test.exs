defmodule ElixirTools.CardDateTest do
  use ExUnit.Case, async: true
  alias ElixirTools.CardDate, as: CardDateHelper

  doctest CardDateHelper

  setup _params do
    %{valid_card_date: "02/22", valid_date: ~D[2022-02-01]}
  end

  describe "get_month!/1" do
    test "for a valid card_date, it should return the valid month integer", context do
      assert CardDateHelper.get_month!(context.valid_card_date) == 2
    end
  end

  describe "get_year!/1" do
    test "for a valid card_date, it should return the valid year integer", context do
      assert CardDateHelper.get_year!(context.valid_card_date) == 2022
    end
  end

  describe "enforce_card_date_format!/1" do
    test "If the date is in the `card_date` format, return it", context do
      card_date = context.valid_card_date
      assert CardDateHelper.enforce_card_date_format!(card_date) == card_date
    end
  end

  describe "to_iso_string!/2" do
    test "For a valid `card_date` it should produce a valid iso8601 string", context do
      assert CardDateHelper.to_iso_string!(context.valid_card_date) == "2022-02-01"
    end

    test "If a custom `day` parameter is used, use it as the `day` value", context do
      card_date = context.valid_card_date
      assert CardDateHelper.to_iso_string!(card_date, day: 16) == "2022-02-16"
    end
  end

  describe "to_date!/2" do
    test "For a valid `card_date` it should produce a valid Date struct", context do
      expected_date = %Date{day: 1, month: 2, year: 2022}
      assert CardDateHelper.to_date!(context.valid_card_date) == expected_date
    end

    test "If a custom `day` parameter is used, use it as the `day` value", context do
      expected_date = %Date{day: 16, month: 2, year: 2022}
      assert CardDateHelper.to_date!(context.valid_card_date, day: 16) == expected_date
    end
  end

  describe "parse_card_date!/1" do
    test "If a valid `card_date` is entered, return it in NaiveDateTime format", context do
      card_date = context.valid_card_date
      assert CardDateHelper.parse_card_date!(card_date) == ~N[2022-02-01 00:00:00]
    end
  end

  describe "from_date!/1" do
    test "If a valid Date is entered, return the `card_date` representation", context do
      assert CardDateHelper.from_date!(context.valid_date) == "02/22"
    end
  end

  describe "Various invalid inputs for: " do
    @functions ~w(get_month! get_year! enforce_card_date_format! to_iso_string! to_date! parse_card_date!)a
    @invalid_card_dates [12, "12.22", "12-22", "2022-12-01", "2022/12/01", "02 22", %{}, [], nil]

    Enum.each(@functions, fn fun ->
      test "#{fun}" do
        fun = unquote(fun)

        Enum.each(@invalid_card_dates, fn invalid_card_date ->
          assert_raise RuntimeError, "Invalid card_date format", fn ->
            apply(CardDateHelper, fun, [invalid_card_date])
          end
        end)
      end
    end)
  end

  test "Various invalid inputs for: from_date!" do
    invalid_card_dates = [12, "2022-12-01", %{}, [], nil, ~T[20:03:08.001]]

    Enum.each(invalid_card_dates, fn invalid_card_date ->
      assert_raise RuntimeError, "Invalid Date provided", fn ->
        CardDateHelper.from_date!(invalid_card_date)
      end
    end)
  end
end
