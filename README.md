# pream

[![Package Version](https://img.shields.io/hexpm/v/pream)](https://hex.pm/packages/pream)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/pream/)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

Signals-first Gleam bindings for [Preact](https://preactjs.com/) with
[`@preact/signals`](https://github.com/preactjs/signals) integration.
Re-rendering is driven by signals, not component state.

## Philosophy

pream is signals-first. Components don't hold local state — they read from
signals and re-render when signals change. This means:

- No `useState` / `useReducer` — use `signal.new` and `signal.set` instead
- No manual dependency arrays for signal effects — use `use_signal_effect`
- Component boundaries preserve Preact devtools and signal-driven re-rendering

## Install

```sh
gleam add pream
```

Requires Preact and `@preact/signals` as npm dependencies:

```sh
npm install preact @preact/signals
```

## Quick start

```gleam
import pream
import pream/signal
import pream/vnode

pub fn main() {
  let count = signal.new(0)

  let app =
    vnode.div()
    |> vnode.children([
      vnode.text("Clicked "),
      vnode.reactive_text(signal.map(count, fn(n) { int.to_string(n) })),
      vnode.text(" times"),
      vnode.element(
        vnode.button()
        |> vnode.on("click", fn(_) { signal.setter(count, fn(c) { c + 1 }) })
        |> vnode.child(vnode.text("Increment")),
      ),
    ])

  pream.to_preact(app)
}
```

## Component boundaries

Use `vnode.component` to create a Preact component boundary. This preserves
Preact devtools visibility and ensures signal-driven re-rendering is scoped
to the component. Static values are passed via closure capture; dynamic
values flow through signals.

```gleam
import pream
import pream/hooks
import pream/signal
import pream/vnode

fn counter() -> vnode.VNode {
  let count = hooks.use_signal(0)
  vnode.new("div")
  |> vnode.child(vnode.reactive_text(signal.map(count, int.to_string)))
  |> vnode.child(vnode.element(
    vnode.button()
    |> vnode.on("click", fn(_) { signal.setter(count, fn(c) { c + 1 }); Nil })
    |> vnode.child(vnode.text("+1")),
  ))
}

pub fn main() -> pream.PreactComponent {
  vnode.new("main")
  |> vnode.child(vnode.text("Counter Demo"))
  |> vnode.child(vnode.component(counter))
  |> pream.to_preact()
}
```

Functions with arguments need a wrapping closure to capture state:

```gleam
fn greeting(name: String) -> vnode.VNode {
  vnode.new("div")
  |> vnode.child(vnode.text("Hello, " <> name))
}

// In another component:
vnode.new("main")
|> vnode.child(vnode.component(fn() { greeting("Alice") }))
```

Dynamic values use signals instead of changing props:

```gleam
fn counter_display(count: signal.Signal(Int)) -> vnode.VNode {
  vnode.new("span")
  |> vnode.child(vnode.reactive_text(signal.map(count, int.to_string)))
}

// In another component:
vnode.new("main")
|> vnode.child(vnode.component(fn() { counter_display(some_signal) }))
```

## Examples

### Counter with signal

```gleam
import pream/signal
import pream/vnode

pub fn counter() {
  let count = signal.new(0)

  vnode.div()
  |> vnode.child(vnode.reactive_text(signal.map(count, fn(n) {
    "Count: " <> int.to_string(n)
  })))
  |> vnode.child(vnode.element(
    vnode.button()
    |> vnode.on("click", fn(_) {
      signal.setter(count, fn(c) { c + 1 })
      Nil
    })
    |> vnode.child(vnode.text("Increment")),
  ))
}
```

### Conditional rendering

```gleam
import pream/vnode
import pream/signal

pub fn visibility_toggle() {
  let visible = signal.new(True)

  vnode.div()
  |> vnode.child(vnode.when_signal(visible, fn() {
    vnode.text("Hello, world!")
  }))
  |> vnode.child(vnode.element(
    vnode.button()
    |> vnode.on("click", fn(_) {
      signal.setter(visible, fn(v) { !v })
      Nil
    })
    |> vnode.child(vnode.text("Toggle")),
  ))
}
```

### Using useEffect

```gleam
import pream/hooks
import pream/dom

pub fn timer_component() {
  let count = hooks.use_ref(0)

  hooks.use_effect(fn() {
    let id = setInterval(fn() { count.current = count.current + 1 }, 1000)
    fn() { clearInterval(id) }
  }, [])

  vnode.new("div") |> vnode.child(vnode.text("Timer running"))
}
```

## Features

- **Signals-first** — re-rendering driven by signals, not component state
- **Component boundaries** — `vnode.component` preserves Preact devtools and
  signal-driven re-rendering
- **Shorthand constructors** — `vnode.div()`, `vnode.span()`, `vnode.button()`,
  etc.
- **Pipe-friendly modifiers** — `prop`, `on`, `class`, `id`, `disabled`, ...
- **Fine-grained signals** — `signal.new`, `signal.computed`, `signal.effect`
- **Component hooks** — `use_signal`, `use_signal_effect`, `use_computed`
- **Preact hooks** — `use_effect`, `use_memo`, `use_callback`, `use_ref`,
  `use_id`, ...
- **QoL hooks** — `use_mount`, `use_unmount`
- **Conditional helpers** — `vnode.when`, `vnode.unless`, `vnode.when_some`,
  `vnode.when_signal`, `vnode.map_signal`
- **Result/Option-aware** — `pream.unwrap` and `pream.unwrap_option` silently
  degrade into empty nodes on `Error`/`None`

## Hooks

All hooks are available from `import pream/hooks`.

### Signal hooks

| Hook                     | Description                                    |
| ------------------------ | ---------------------------------------------- |
| `use_signal(initial)`    | Create a reactive signal scoped to a component |
| `use_signal_effect(run)` | Run a reactive effect on signal changes        |
| `use_computed(fn)`       | Create a computed signal scoped to a component |

### Effect hooks

| Hook                                   | Description                            |
| -------------------------------------- | -------------------------------------- |
| `use_effect(run, deps)`                | Side effect after render (no cleanup)  |
| `use_effect_cleanup(run, deps)`        | Side effect with cleanup function      |
| `use_layout_effect(run, deps)`         | Synchronous effect after DOM mutations |
| `use_layout_effect_cleanup(run, deps)` | Synchronous effect with cleanup        |

### Memoization hooks

| Hook                           | Description                      |
| ------------------------------ | -------------------------------- |
| `use_memo(compute, deps)`      | Memoize an expensive computation |
| `use_callback(callback, deps)` | Memoize a callback function      |

### Ref hooks

| Hook                                       | Description                       |
| ------------------------------------------ | --------------------------------- |
| `use_ref(initial)`                         | Create a mutable reference object |
| `use_imperative_handle(ref, create, deps)` | Customize ref handle              |

### Misc hooks

| Hook                     | Description                            |
| ------------------------ | -------------------------------------- |
| `use_id()`               | Unique ID for accessibility attributes |
| `use_debug_value(value)` | Custom devtools label                  |

### QoL hooks

| Hook              | Description         |
| ----------------- | ------------------- |
| `use_mount(fn)`   | Run once on mount   |
| `use_unmount(fn)` | Run once on unmount |

## Documentation

- API reference: <https://hexdocs.pm/pream>
- Source code: <https://github.com/soulsam480/pream>

## License

MIT © 2026 soulsam480