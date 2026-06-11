import gleam/int
import pream
import pream/hooks
import pream/signal
import pream/vnode

fn leaf(count: signal.Signal(Int)) -> vnode.VNode {
  vnode.new("span")
  |> vnode.child(vnode.reactive_text(signal.map(count, int.to_string)))
}

fn inner(count: signal.Signal(Int)) -> vnode.VNode {
  vnode.new("div")
  |> vnode.child(vnode.text("Count: "))
  |> vnode.child(vnode.component(fn() { leaf(count) }))
}

pub fn main() -> pream.PreactComponent {
  let count = hooks.use_signal(0)

  vnode.new("main")
  |> vnode.class("app")
  |> vnode.child(vnode.text("Component Boundaries Demo"))
  |> vnode.child(vnode.component(fn() { inner(count) }))
  |> vnode.child(vnode.element(
    vnode.button()
    |> vnode.on("click", fn(_) {
      signal.setter(count, fn(c) { c + 1 })
      Nil
    })
    |> vnode.child(vnode.text("Increment")),
  ))
  |> pream.to_preact()
}