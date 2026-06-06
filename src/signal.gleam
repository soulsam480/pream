/// https://npmx.dev/package-docs/@preact%2Fsignals/v/2.9.1#class-Signal
@external(javascript, "@preact/signals", "Signal")
pub type Signal(a)

/// https://npmx.dev/package-docs/@preact%2Fsignals/v/2.9.1#function-signal
@external(javascript, "@preact/signals", "signal")
pub fn new(state a: a) -> Signal(a)

/// same as new but stores inside localStorage
@external(javascript, "./signal_ffi.mjs", "persisted")
pub fn new_persisted(with name: String, and initial_value: a) -> Signal(a)

/// https://npmx.dev/package-docs/@preact%2Fsignals/v/2.9.1#function-computed
@external(javascript, "@preact/signals", "computed")
pub fn computed(with fun: fn() -> a) -> Signal(a)

/// reads `value` of the signal
/// using this inside a computed/effect will subscribe
/// to the signal being read
@external(javascript, "./signal_ffi.mjs", "signal_value")
pub fn value(signal: Signal(a)) -> a

/// sets `value` of the signal
@external(javascript, "./signal_ffi.mjs", "signal_set")
pub fn set(signal: Signal(a), value: a) -> Signal(a)

/// reads `value` of the signal without subscribing
/// this can be used inside computed/effect to opt-out
/// of reactivity
@external(javascript, "./signal_ffi.mjs", "signal_peek")
pub fn peek(signal: Signal(a)) -> a

/// sets `value` of the signa from result of setter
/// useful to wrap local logic
pub fn setter(signal: Signal(a), setter compute: fn(a) -> a) -> Signal(a) {
  set(signal, compute(peek(signal)))
}

/// https://npmx.dev/package-docs/@preact%2Fsignals/v/2.9.1#function-effect
@external(javascript, "@preact/signals", "effect")
pub fn effect(run: fn() -> a) -> a

/// similar to computed but wraps a single signal
/// inside a computed. useful for transformations
pub fn map(signal: Signal(a), map compute: fn(a) -> b) -> Signal(b) {
  computed(fn() { compute(value(signal)) })
}
