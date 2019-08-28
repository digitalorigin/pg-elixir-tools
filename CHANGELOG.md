# Changelog

## 0.13.1 (2019-08-28)
* `ElixirTools.Schema` now reads the `default_repo` at runtime, not at compile time. This prevents
the bug where repo is stuck at the value `nil`.

## 0.13.0 (2019-08-23)
* Add `event_handler` for async event sending
* Add `not_send_events` for saving not sent events to DB

## 0.12.0 (2019-08-21)
* Added the integer helper logic
* HTTPClient now allows integers to be passed as string

## 0.11.0 (2019-07-30)
* add `HttpClient` - a wrapper around more basic Http Client(HTTPoison by default)

## 0.10.1 (2019-07-22)
* add optional `occurred_at` to Events.
It's an optional part used for to fill `occurred_at` field. If it's not provided, `current time` will be sent.

## 0.10.0 (2019-07-16)
* add optional `event_id_seed_optional` to Events.
It's an optional part used for `event_id` UUID5 generation. By default - `""`(empty string)
