# Changelog

# 0.21.3 (2020-06-09)
* Dependency updates

# 0.21.2 (2020-04-21)
* Make EventHandler.publish_event_call function public

# 0.21.1 (2020-04-16)
* Remove Rollbax as a required dependency

## 0.21.0 (2020-04-16)
* Metrix.Plug: Stop sending request_path in metrics for every request.

## 0.20.1 (2020-04-08)
* Events: EventFakeModule test support for publish/3.

## 0.20.0 (2020-04-08)
* Events: publish event with JSON schema validation improvement.

## 0.19.1 (2020-04-07)
* Events: creation refactor.

## 0.19.0 (2020-04-01)
* Events: publish event with JSON schema validation.

## 0.18.0 (2020-03-23)
* Add fake rollbax
* Fix: Schema.all/1 functionality
* Add Credo.NamingCheck

## 0.17.5 (2020-03-06)
* Events: add default version value to EventHandlerFake.create/4

## 0.17.4 (2020-03-06)
* Events: possible to set version during creation

## 0.17.3 (2020-02-19)
* Make new dependencies available

## 0.17.2 (2020-01-29)
* Make new dependencies available

## 0.17.1 (2019-12-18)
* Switch to Jason from Poison for ex_aws.

## 0.17.0 (2019-11-18)
* Plug for setting log levels for specific paths.

## 0.16.0 (2019-11-12)
* Add TestHelpers: MetrixFake.

## 0.15.0 (2019-11-04)
* Add TestHelpers: DateTimeFake, EventHandlerFake and TaskSupervisorFake.

## 0.14.3 (2019-10-24)
* Schema: add `last/2` function which returns the last record (by inserted_at) where given field equals given value

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
