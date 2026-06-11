import gleam/option.{None, Some}
import gleeunit
import pream
import pream/signal
import pream/vnode

pub fn main() -> Nil {
  gleeunit.main()
}

// ── unwrap tests ──────────────────────────────────────────

pub fn unwrap_ok_test() {
  let comp = fn(_p: Nil) { Ok(vnode.new("div")) }
  let result = pream.unwrap(comp, Nil)

  assert result == vnode.new("div")
}

pub fn unwrap_error_test() {
  let comp = fn(_p: Nil) { Error(Nil) }
  let result = pream.unwrap(comp, Nil)

  assert result == vnode.empty()
}

// ── unwrap_option tests ───────────────────────────────────

pub fn unwrap_option_some_test() {
  let comp = fn(_p: Nil) { Some(vnode.new("div")) }
  let result = pream.unwrap_option(comp, Nil)

  assert result == vnode.new("div")
}

pub fn unwrap_option_none_test() {
  let comp = fn(_p: Nil) { None }
  let result = pream.unwrap_option(comp, Nil)

  assert result == vnode.empty()
}

// ── Shorthand constructor tests ─────────────────────────

pub fn div_shortcut_test() {
  let node = vnode.div()
  assert node == vnode.new("div")
}

pub fn span_shortcut_test() {
  let node = vnode.span()
  assert node == vnode.new("span")
}

// ── Attribute helper tests ──────────────────────────────

pub fn class_helper_test() {
  let node = vnode.div() |> vnode.class("container")
  let expected = vnode.new("div") |> vnode.prop("class", "container")

  assert node == expected
}

pub fn id_helper_test() {
  let node = vnode.div() |> vnode.id("main")
  let expected = vnode.new("div") |> vnode.prop("id", "main")

  assert node == expected
}

pub fn disabled_helper_test() {
  let node = vnode.div() |> vnode.disabled()
  let expected = vnode.new("div") |> vnode.prop("disabled", True)

  assert node == expected
}

pub fn checked_helper_test() {
  let node = vnode.div() |> vnode.checked()
  let expected = vnode.new("div") |> vnode.prop("checked", True)

  assert node == expected
}

// ── VChild constructor tests ─────────────────────────────

pub fn text_returns_vchild_test() {
  let child = vnode.text("hello")

  assert child == vnode.text("hello")
}

pub fn element_returns_vchild_test() {
  let inner = vnode.new("span")
  let child = vnode.element(inner)

  assert child == vnode.element(inner)
}

pub fn reactive_returns_vchild_test() {
  let sig = signal.new("hello")
  let _child =
    vnode.reactive(
      signal.map(sig, fn(v) { vnode.new("div") |> vnode.child(vnode.text(v)) }),
    )

  Nil
}

pub fn reactive_text_returns_vchild_test() {
  let sig = signal.new("hello")
  let _child = vnode.reactive_text(sig)

  Nil
}

pub fn text_with_returns_vchild_test() {
  let child = vnode.text_with("Hello, {}!", ["world"])

  assert child == vnode.text("Hello, world!")
}

// ── Component boundary tests ──────────────────────────────

pub fn component_creates_boundary_test() {
  let boundary = vnode.component(fn() { vnode.new("div") })
  let assert vnode.Boundary(render: _) = boundary
  Nil
}

// ── Conditional VChild constructor tests ────────────────

pub fn when_true_test() {
  let child = vnode.when(True, fn() { vnode.text("yes") })
  assert child == vnode.text("yes")
}

pub fn when_false_test() {
  let child = vnode.when(False, fn() { vnode.text("yes") })
  assert child == vnode.text("")
}

pub fn unless_true_test() {
  let child = vnode.unless(True, fn() { vnode.text("yes") })
  assert child == vnode.text("")
}

pub fn unless_false_test() {
  let child = vnode.unless(False, fn() { vnode.text("yes") })
  assert child == vnode.text("yes")
}

pub fn when_some_some_test() {
  let child = vnode.when_some(Some("hi"), fn(v) { vnode.text(v) })
  assert child == vnode.text("hi")
}

pub fn when_some_none_test() {
  let child = vnode.when_some(None, fn(v: String) { vnode.text(v) })
  assert child == vnode.text("")
}

// ── use_signal hook tests (smoke only, no real DOM) ───────
// use_signal and use_computed require a preact component
// context and cannot be tested in gleeunit. the external
// bindings compile and are verified by `gleam check`.

// ── dom_ffi reference is validated by compilation ───────