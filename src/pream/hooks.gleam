import pream/dom.{type Native}
import pream/signal

// ── Signal hooks (moved from pream.gleam) ──────────────

/// Creates a reactive signal scoped to a component.
/// Returns the same `Signal` type as `signal.new`,
/// composable with `signal.value`, `signal.set`,
/// `signal.map`, etc.
@external(javascript, "@preact/signals", "useSignal")
pub fn use_signal(initial: a) -> signal.Signal(a)

/// Runs a reactive effect scoped to a component.
/// The effect runs after every render where any signal
/// read inside the effect has changed.
@external(javascript, "@preact/signals", "useSignalEffect")
pub fn use_signal_effect(run: fn() -> Nil) -> Nil

/// Returns a read-only computed signal scoped to
/// a component — same semantics as `signal.computed`
@external(javascript, "@preact/signals", "useComputed")
pub fn use_computed(compute: fn() -> a) -> signal.Signal(a)

// ── Effect hooks (basic — no cleanup) ──────────────────

/// Runs a side effect after render. The effect re-runs when
/// any value in `deps` changes. Pass `[]` to run once on mount.
/// Pass a list of dependencies like `[dom.to_native(signal.value(sig))]`
/// to re-run when those values change.
///
/// # Examples
///
/// ```gleam
/// // Run once on mount
/// use_effect(fn() { console.log("mounted") }, [])
///
/// // Re-run when a signal changes
/// use_effect(
///   fn() { console.log("count changed") },
///   [dom.to_native(signal.value(count))],
/// )
/// ```
@external(javascript, "./hooks_ffi.mjs", "use_effect")
pub fn use_effect(run: fn() -> Nil, deps: List(Native)) -> Nil

/// Like `use_effect` but runs synchronously after DOM mutations,
/// before the browser paints. Use for measuring layout or other
/// synchronous DOM reads.
@external(javascript, "./hooks_ffi.mjs", "use_layout_effect")
pub fn use_layout_effect(run: fn() -> Nil, deps: List(Native)) -> Nil

// ── Effect hooks (cleanup variant) ─────────────────────

/// Like `use_effect` but the callback returns a cleanup function
/// that runs before the next effect invocation and on unmount.
///
/// # Examples
///
/// ```gleam
/// use_effect_cleanup(fn() {
///   let interval_id = set_interval(fn() { ... }, 1000)
///   fn() { clearInterval(interval_id) }
/// }, [])
/// ```
@external(javascript, "./hooks_ffi.mjs", "use_effect_cleanup")
pub fn use_effect_cleanup(run: fn() -> fn() -> Nil, deps: List(Native)) -> Nil

/// Like `use_layout_effect` but with cleanup support.
@external(javascript, "./hooks_ffi.mjs", "use_layout_effect_cleanup")
pub fn use_layout_effect_cleanup(
  run: fn() -> fn() -> Nil,
  deps: List(Native),
) -> Nil

// ── Memoization hooks ──────────────────────────────────

/// Memoizes a computed value. Only recomputes when a dep in
/// `deps` changes. Useful for expensive calculations.
@external(javascript, "./hooks_ffi.mjs", "use_memo")
pub fn use_memo(compute: fn() -> a, deps: List(Native)) -> a

/// Memoizes a callback function. Only returns a new function
/// reference when a dep in `deps` changes. Useful for passing
/// stable callbacks to child components.
@external(javascript, "./hooks_ffi.mjs", "use_callback")
pub fn use_callback(callback: fn() -> a, deps: List(Native)) -> fn() -> a

// ── Ref hooks ──────────────────────────────────────────

/// A mutable reference object whose `.current` field persists
/// across renders. At the JavaScript level, `Ref(current: x)`
/// compiles to `{ current: x }`.
///
/// # Examples
///
/// ```gleam
/// let input_ref = use_ref("")
/// // In FFI or event handler: input_ref.current = "new value"
/// ```
pub type Ref(a) {
  Ref(current: a)
}

/// Creates a `Ref` that persists for the lifetime of the component.
@external(javascript, "./hooks_ffi.mjs", "use_ref")
pub fn use_ref(initial: a) -> Ref(a)

/// Customizes the instance value exposed through a ref.
/// Typically used with `forwardRef` in component libraries.
@external(javascript, "./hooks_ffi.mjs", "use_imperative_handle")
pub fn use_imperative_handle(
  ref: Ref(a),
  create_handle: fn() -> a,
  deps: List(Native),
) -> Nil

// ── Misc hooks ─────────────────────────────────────────

/// Returns a unique ID string for use in accessibility
/// attributes (`id`, `for`, `aria-labelledby`, etc.).
@external(javascript, "./hooks_ffi.mjs", "use_id")
pub fn use_id() -> String

/// Displays a custom label for a hook in the Preact devtools panel.
@external(javascript, "./hooks_ffi.mjs", "use_debug_value")
pub fn use_debug_value(value: a) -> Nil

// ── QoL hooks ──────────────────────────────────────────

/// Runs `run` once on component mount. Equivalent to
/// `use_effect(run, [])`.
pub fn use_mount(run: fn() -> Nil) -> Nil {
  use_effect(run, [])
}

/// Runs `run` once on component unmount. Equivalent to
/// `use_effect_cleanup(fn() { fn() { run() } }, [])`.
pub fn use_unmount(run: fn() -> Nil) -> Nil {
  use_effect_cleanup(fn() { fn() { run() } }, [])
}
