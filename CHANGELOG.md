# Changelog

## 0.10.1 (2019-07-22)
* add optional `occurred_at` to Events. 
It's an optional part used for to fill `occurred_at` field. If it's not provided, `current time` will be sent.

## 0.10.0 (2019-07-16)
* add optional `event_id_seed_optional` to Events. 
It's an optional part used for `event_id` UUID5 generation. By default - `""`(empty string)