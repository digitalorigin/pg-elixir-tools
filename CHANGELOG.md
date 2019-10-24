# Changelog

## 0.14.3 (2019-10-24)
* Schema: add last function

## 0.14.2 (2019-09-17)
* Metrix: can now be disabled through the configuration

## 0.14.1 (2019-09-17)
* Metrix: default tags are no longer mandatory

## 0.14.0 (2019-08-28)
* Add optional parameter `file_extension` to `ElixirTools.Fixture.load!` for loading non-json files

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
