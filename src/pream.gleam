import gleam/option.{type Option}
import signal
import vnode.{type VNode}

/// https://npmx.dev/package-docs/preact/v/10.29.2#class-ComponentChildren
@external(javascript, "preact", "ComponentChildren")
pub type PreactComponent

/// https://npmx.dev/package-docs/preact/v/10.29.2#function-h
/// converts a vnode tree into a preact
/// `ComponentChildren` value, ready to pass to
/// preact's `render()`
@external(javascript, "./component_ffi.mjs", "h")
pub fn to_preact(from node: VNode) -> PreactComponent

/// unwraps a `Result`-returning render function.
/// an `Error` is silently coerced into an empty
/// vnode — useful when a component is allowed to
/// fail without taking down the whole tree
pub fn unwrap(
  render component: fn(p) -> Result(VNode, b),
  with props: p,
) -> VNode {
  case component(props) {
    Ok(node) -> node
    Error(_) -> vnode.empty()
  }
}

/// unwraps an `Option`-returning render function.
/// `None` is silently coerced into an empty vnode
pub fn unwrap_option(
  render component: fn(p) -> Option(VNode),
  with props: p,
) -> VNode {
  case component(props) {
    option.Some(node) -> node
    option.None -> vnode.empty()
  }
}

/// typed component record — wraps a props-to-vnode
/// render function so it can be named, composed,
/// and passed around explicitly
pub type Component(p) {
  Component(render: fn(p) -> VNode)
}

/// construct a component from a render function
pub fn component(render: fn(p) -> VNode) -> Component(p) {
  Component(render:)
}

/// render a component with the given props
pub fn render_component(comp: Component(p), props: p) -> VNode {
  comp.render(props)
}

/// render a component and convert directly to a
/// preact component, ready for `render()`
pub fn to_preact_component(comp: Component(p), props: p) -> PreactComponent {
  comp.render(props) |> to_preact
}

// ── Signal hooks (from @preact/signals) ─────────────────

/// https://npmx.dev/package-docs/@preact%2Fsignals/v/2.9.1#function-useSignal
/// creates a reactive signal scoped to a component.
/// returns the same `Signal` type as `signal.new`,
/// composable with `signal.value`, `signal.set`,
/// `signal.map`, etc.
@external(javascript, "@preact/signals", "useSignal")
pub fn use_signal(initial: a) -> signal.Signal(a)

/// https://npmx.dev/package-docs/@preact%2Fsignals/v/2.9.1#function-useSignalEffect
/// runs a reactive effect scoped to a component
@external(javascript, "@preact/signals", "useSignalEffect")
pub fn use_signal_effect(run: fn() -> Nil) -> Nil

/// https://npmx.dev/package-docs/@preact%2Fsignals/v/2.9.1#function-useComputed
/// returns a read-only computed signal scoped to
/// a component — same semantics as `signal.computed`
@external(javascript, "@preact/signals", "useComputed")
pub fn use_computed(compute: fn() -> a) -> signal.Signal(a)
