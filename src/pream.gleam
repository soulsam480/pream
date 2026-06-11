import gleam/option.{type Option}
import pream/vnode.{type VNode}

/// https://npmx.dev/package-docs/preact/v/10.29.2#class-ComponentChildren
@external(javascript, "preact", "ComponentChildren")
pub type PreactComponent

/// https://npmx.dev/package-docs/preact/v/10.29.2#function-h
/// converts a vnode tree into a preact
/// `ComponentChildren` value, ready to pass to
/// preact's `render()`
@external(javascript, "./pream/component_ffi.mjs", "h")
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