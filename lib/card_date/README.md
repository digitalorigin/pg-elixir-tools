# Card date

This support module includes helper functions for dealing with card date transformations and parsing.
This includes transforming dates from the `card_date` format into Elixir's `Date` format or into
an `ISO8601` string.

## Examples

```elixir
# From `card date` to Date
ElixirTools.CardDate.to_date!("12/19")
# ~D[2019-12-01]

# From `card date` to an ISO8601 string
ElixirTools.CardDate.to_iso_string!("12/19")
# "2019-12-01"

# Get the full year integer value from a card date
ElixirTools.CardDate.get_year!("12/19")
# 2019
```
