## 1.0.0

- First release. The `@DtoLog` builder that used to ship inside `dto_logger` 1.x
  moved to its own package, so `dto_logger` has no dependencies.
- Generates the same code as `dto_logger` 1.1.1, except that a field read with
  `safeCast` keeps nullable type arguments (`Map<String, int?>` was read as
  `Map<String, int>`).
- Supports private named parameters (`Profile({this._nick})`): the value is
  passed as `nick`, and `copyWith` takes `nick`.
- Supports analyzer 8.1.1 to 14.x, `build` 4 and `source_gen` 4.
