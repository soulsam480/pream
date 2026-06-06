import dom
import format
import gleam/list
import gleam/option
import signal

/// virtual dom node — same shape as the output
/// of preact's `h()`. built up via small composable
/// helpers below, then handed to `pream.to_preact`
pub opaque type VNode {
  VNode(tag: String, props: List(Prop), children: List(VChild))
}

/// child of a vnode — one of four variants:
/// static element, static text, reactive element,
/// or reactive text. use the constructors below
/// (e.g. `text`, `element`, `reactive`, `reactive_text`)
/// to build values of this type.
pub type VChild {
  Element(VNode)
  Text(String)
  Reactive(signal.Signal(VNode))
  ReactiveText(signal.Signal(String))
}

/// vnode property — either an attribute (any gleam
/// value, serialized downstream in ffi) or an
/// event handler. handlers are camelCased and
/// prefixed with `on_` in ffi
pub type Prop {
  /// NOTE: a prop can be any gleam value
  /// we're swallowing the type here and handle
  /// it downstram in ffi. this is done to make
  /// the render API simple
  Attr(key: String, value: dom.Native)
  Handler(event: String, handle: fn(dom.Event) -> Nil)
}

// ── Construction ────────────────────────────────────────

/// https://npmx.dev/package-docs/preact/v/10.29.2#function-h
/// creates an empty vnode with the given tag and
/// no props or children — equivalent to `<tag />`
pub fn new(tag: String) -> VNode {
  VNode(tag: tag, props: [], children: [])
}

/// renders nothing — mapped to preact's `null` in ffi
pub fn empty() -> VNode {
  VNode("$NULL", [], [])
}

/// https://npmx.dev/package-docs/preact/v/10.29.2#function-fragment
/// a fragment vnode — used to return multiple
/// sibling children without a wrapper element
pub fn fragment() -> VNode {
  VNode("$FRAGMENT", [], [])
}

// ── HTML shorthand constructors (all empty, pipe-friendly) ─

pub fn div() -> VNode {
  new("div")
}

pub fn span() -> VNode {
  new("span")
}

pub fn p() -> VNode {
  new("p")
}

pub fn h1() -> VNode {
  new("h1")
}

pub fn h2() -> VNode {
  new("h2")
}

pub fn h3() -> VNode {
  new("h3")
}

pub fn h4() -> VNode {
  new("h4")
}

pub fn h5() -> VNode {
  new("h5")
}

pub fn h6() -> VNode {
  new("h6")
}

pub fn button() -> VNode {
  new("button")
}

pub fn a() -> VNode {
  new("a")
}

pub fn nav() -> VNode {
  new("nav")
}

pub fn section() -> VNode {
  new("section")
}

pub fn article() -> VNode {
  new("article")
}

pub fn header() -> VNode {
  new("header")
}

pub fn footer() -> VNode {
  new("footer")
}

pub fn main() -> VNode {
  new("main")
}

pub fn ul() -> VNode {
  new("ul")
}

pub fn ol() -> VNode {
  new("ol")
}

pub fn li() -> VNode {
  new("li")
}

pub fn form() -> VNode {
  new("form")
}

pub fn label() -> VNode {
  new("label")
}

pub fn select() -> VNode {
  new("select")
}

pub fn option_tag() -> VNode {
  new("option")
}

pub fn input() -> VNode {
  new("input")
}

pub fn textarea() -> VNode {
  new("textarea")
}

pub fn table() -> VNode {
  new("table")
}

pub fn tr() -> VNode {
  new("tr")
}

pub fn td() -> VNode {
  new("td")
}

pub fn th() -> VNode {
  new("th")
}

pub fn img() -> VNode {
  new("img")
}

pub fn br() -> VNode {
  new("br")
}

pub fn hr() -> VNode {
  new("hr")
}

// ── Modifiers (pipeline-friendly) ───────────────────────

/// sets an attribute on the vnode. any gleam value
/// is accepted — stringification/serialization is
/// deferred to the ffi at render time
pub fn prop(vnode: VNode, key: String, value: a) -> VNode {
  VNode(
    ..vnode,
    props: list.append(vnode.props, [Attr(key:, value: dom.to_native(value))]),
  )
}

/// attaches an event handler. the event name is
/// camelCased and prefixed with `on_` in ffi
/// (e.g. `click` becomes `onClick`)
pub fn on(vnode: VNode, event: String, handle: fn(dom.Event) -> Nil) -> VNode {
  VNode(..vnode, props: list.append(vnode.props, [Handler(event:, handle:)]))
}

// ── Typed attribute helpers (common cases) ──────────────

pub fn class(vnode: VNode, name: String) -> VNode {
  prop(vnode, "class", name)
}

pub fn id(vnode: VNode, name: String) -> VNode {
  prop(vnode, "id", name)
}

pub fn type_(vnode: VNode, name: String) -> VNode {
  prop(vnode, "type", name)
}

pub fn name(vnode: VNode, name: String) -> VNode {
  prop(vnode, "name", name)
}

pub fn value_string(vnode: VNode, val: String) -> VNode {
  prop(vnode, "value", val)
}

pub fn value_int(vnode: VNode, val: Int) -> VNode {
  prop(vnode, "value", val)
}

pub fn href(vnode: VNode, url: String) -> VNode {
  prop(vnode, "href", url)
}

pub fn src(vnode: VNode, url: String) -> VNode {
  prop(vnode, "src", url)
}

pub fn alt(vnode: VNode, text: String) -> VNode {
  prop(vnode, "alt", text)
}

pub fn title(vnode: VNode, text: String) -> VNode {
  prop(vnode, "title", text)
}

pub fn placeholder(vnode: VNode, text: String) -> VNode {
  prop(vnode, "placeholder", text)
}

pub fn disabled(vnode: VNode) -> VNode {
  prop(vnode, "disabled", True)
}

pub fn required(vnode: VNode) -> VNode {
  prop(vnode, "required", True)
}

pub fn checked(vnode: VNode) -> VNode {
  prop(vnode, "checked", True)
}

pub fn role(vnode: VNode, name: String) -> VNode {
  prop(vnode, "role", name)
}

/// appends a single child
pub fn child(vnode: VNode, child: VChild) -> VNode {
  VNode(..vnode, children: list.append(vnode.children, [child]))
}

/// appends a list of children
pub fn children(vnode: VNode, children: List(VChild)) -> VNode {
  VNode(..vnode, children: list.append(vnode.children, children))
}

// ── VChild constructors ─────────────────────────────────

/// wraps a vnode as a child element
pub fn element(node: VNode) -> VChild {
  Element(node)
}

/// creates a static text child
pub fn text(content: String) -> VChild {
  Text(content)
}

/// creates a static text child with positional
/// formatting — each `{}` is replaced with the
/// next value from the list
pub fn text_with(content: String, args: List(String)) -> VChild {
  Text(format.on(content, args))
}

/// creates a reactive element child from a signal
pub fn reactive(s: signal.Signal(VNode)) -> VChild {
  Reactive(s)
}

/// creates a reactive text child from a signal
pub fn reactive_text(s: signal.Signal(String)) -> VChild {
  ReactiveText(s)
}

// ── Conditional VChild constructors ────────────────────

/// renders `render` when `condition` is `True`,
/// otherwise returns an empty text node
pub fn when(condition: Bool, render: fn() -> VChild) -> VChild {
  case condition {
    True -> render()
    False -> text("")
  }
}

/// renders `render` when `condition` is `False`,
/// otherwise returns an empty text node
pub fn unless(condition: Bool, render: fn() -> VChild) -> VChild {
  when(!condition, render)
}

/// renders `render` when the option is `Some`,
/// otherwise returns an empty text node
pub fn when_some(option: option.Option(a), render: fn(a) -> VChild) -> VChild {
  case option {
    option.Some(v) -> render(v)
    option.None -> text("")
  }
}

/// renders `render` when the signal value is `True`,
/// otherwise returns an empty fragment. the result
/// is itself a reactive VChild.
pub fn when_signal(s: signal.Signal(Bool), render: fn() -> VChild) -> VChild {
  reactive(
    signal.map(s, fn(condition) {
      case condition {
        True -> fragment() |> child(render())
        False -> fragment()
      }
    }),
  )
}

/// maps a signal through `render` — each value
/// is wrapped as a VChild inside a fragment. the
/// result is itself a reactive VChild.
pub fn map_signal(s: signal.Signal(a), render: fn(a) -> VChild) -> VChild {
  reactive(signal.map(s, fn(v) { fragment() |> child(render(v)) }))
}
