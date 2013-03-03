== 0.8.0

* backwards incompatible changes
  * Pending steps no longer exit with -1

* bug fix
  * Nothing

* enhancements
  * Add CHANGELOG
  * Add progress reporter
  * Add official ruby 2.0.0 support

* deprecations
  * Nothing

== 0.7.0

* backwards incompatible changes
  * Nothing

* bug fix
  * Nothing

* enhancements
  * Steps are now generated with the `step` keyword instead of `Given`, `When`, `Then`, etc..
  * Generated features are namespaced to the `Spinach::Features` to prevent conflicts.

* deprecations
  * Nothing

== 0.6.1

* backwards incompatible changes
  * Nothing

* bug fix
  * Don't run entire test suite when an inexisting feature file is given.
  * Run all features from given args instead of just the first one.
  * Don't run tests when the `--generate` flag is given.

* enhancements
  * Add docs on how to use shared steps.

* deprecations
  * Nothing