import gleam/dynamic/decode.{type Dynamic}
import gleam/list
import gleam/option
import plinth/browser/event
import pream/dom
import pream/format
import pream/signal

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
  ComponentNode(component: dom.Native, props: dom.Native)
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
  Handler(event: String, handle: fn(event.Event(Dynamic)) -> Nil)
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

// ── HTML shorthand constructors ─

/// Creates a `<div>` vnode.
pub fn div() -> VNode {
  new("div")
}

/// Creates a `<span>` vnode.
pub fn span() -> VNode {
  new("span")
}

/// Creates a `<p>` vnode.
pub fn p() -> VNode {
  new("p")
}

/// Creates an `<h1>` vnode.
pub fn h1() -> VNode {
  new("h1")
}

/// Creates an `<h2>` vnode.
pub fn h2() -> VNode {
  new("h2")
}

/// Creates an `<h3>` vnode.
pub fn h3() -> VNode {
  new("h3")
}

/// Creates an `<h4>` vnode.
pub fn h4() -> VNode {
  new("h4")
}

/// Creates an `<h5>` vnode.
pub fn h5() -> VNode {
  new("h5")
}

/// Creates an `<h6>` vnode.
pub fn h6() -> VNode {
  new("h6")
}

/// Creates a `<button>` vnode.
pub fn button() -> VNode {
  new("button")
}

/// Creates an `<a>` vnode.
pub fn a() -> VNode {
  new("a")
}

/// Creates a `<nav>` vnode.
pub fn nav() -> VNode {
  new("nav")
}

/// Creates a `<section>` vnode.
pub fn section() -> VNode {
  new("section")
}

/// Creates an `<article>` vnode.
pub fn article() -> VNode {
  new("article")
}

/// Creates a `<header>` vnode.
pub fn header() -> VNode {
  new("header")
}

/// Creates a `<footer>` vnode.
pub fn footer() -> VNode {
  new("footer")
}

/// Creates a `<main>` vnode.
pub fn main() -> VNode {
  new("main")
}

/// Creates a `<ul>` vnode.
pub fn ul() -> VNode {
  new("ul")
}

/// Creates an `<ol>` vnode.
pub fn ol() -> VNode {
  new("ol")
}

/// Creates an `<li>` vnode.
pub fn li() -> VNode {
  new("li")
}

/// Creates a `<form>` vnode.
pub fn form() -> VNode {
  new("form")
}

/// Creates a `<label>` vnode.
pub fn label() -> VNode {
  new("label")
}

/// Creates a `<select>` vnode.
pub fn select() -> VNode {
  new("select")
}

/// Creates an `<option>` vnode.
pub fn option_tag() -> VNode {
  new("option")
}

/// Creates an `<input>` vnode.
pub fn input() -> VNode {
  new("input")
}

/// Creates a `<textarea>` vnode.
pub fn textarea() -> VNode {
  new("textarea")
}

/// Creates a `<table>` vnode.
pub fn table() -> VNode {
  new("table")
}

/// Creates a `<tr>` vnode.
pub fn tr() -> VNode {
  new("tr")
}

/// Creates a `<td>` vnode.
pub fn td() -> VNode {
  new("td")
}

/// Creates a `<th>` vnode.
pub fn th() -> VNode {
  new("th")
}

/// Creates an `<img>` vnode.
pub fn img() -> VNode {
  new("img")
}

/// Creates a `<br>` vnode.
pub fn br() -> VNode {
  new("br")
}

/// Creates an `<hr>` vnode.
pub fn hr() -> VNode {
  new("hr")
}

// ── Modifiers ───────────────────────

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
pub fn on(
  vnode: VNode,
  event: String,
  handle: fn(event.Event(Dynamic)) -> Nil,
) -> VNode {
  VNode(..vnode, props: list.append(vnode.props, [Handler(event:, handle:)]))
}

// ── Typed attribute helpers (common cases) ──────────────

/// Sets the `class` attribute on the vnode.
pub fn class(vnode: VNode, name: String) -> VNode {
  prop(vnode, "class", name)
}

/// Sets the `id` attribute on the vnode.
pub fn id(vnode: VNode, name: String) -> VNode {
  prop(vnode, "id", name)
}

/// Sets the `type` attribute on the vnode.
pub fn type_(vnode: VNode, name: String) -> VNode {
  prop(vnode, "type", name)
}

/// Sets the `name` attribute on the vnode.
pub fn name(vnode: VNode, name: String) -> VNode {
  prop(vnode, "name", name)
}

/// Sets the `value` attribute on the vnode as a string.
pub fn value_string(vnode: VNode, val: String) -> VNode {
  prop(vnode, "value", val)
}

/// Sets the `value` attribute on the vnode as an integer.
pub fn value_int(vnode: VNode, val: Int) -> VNode {
  prop(vnode, "value", val)
}

/// Sets the `href` attribute on the vnode.
pub fn href(vnode: VNode, url: String) -> VNode {
  prop(vnode, "href", url)
}

/// Sets the `src` attribute on the vnode.
pub fn src(vnode: VNode, url: String) -> VNode {
  prop(vnode, "src", url)
}

/// Sets the `alt` attribute on the vnode.
pub fn alt(vnode: VNode, text: String) -> VNode {
  prop(vnode, "alt", text)
}

/// Sets the `title` attribute on the vnode.
pub fn title(vnode: VNode, text: String) -> VNode {
  prop(vnode, "title", text)
}

/// Sets the `placeholder` attribute on the vnode.
pub fn placeholder(vnode: VNode, text: String) -> VNode {
  prop(vnode, "placeholder", text)
}

/// Sets the `disabled` attribute on the vnode to `True`.
pub fn disabled(vnode: VNode) -> VNode {
  prop(vnode, "disabled", True)
}

/// Sets the `required` attribute on the vnode to `True`.
pub fn required(vnode: VNode) -> VNode {
  prop(vnode, "required", True)
}

/// Sets the `checked` attribute on the vnode to `True`.
pub fn checked(vnode: VNode) -> VNode {
  prop(vnode, "checked", True)
}

/// Sets the `role` attribute on the vnode.
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
