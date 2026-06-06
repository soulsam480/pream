# pream

[![Package Version](https://img.shields.io/hexpm/v/pream)](https://hex.pm/packages/pream)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/pream/)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

Type-safe Gleam bindings for [Preact](https://preactjs.com/) with [`@preact/signals`](https://github.com/preactjs/signals) integration. Ships ergonomic HTML constructors, fine-grained reactivity, and Result/Option-aware rendering — no React-style hooks required.

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
import signal
import vnode

pub fn main() {
  let count = signal.new(0)

  let app =
    vnode.div()
    |> vnode.children([
      vnode.text("Clicked "),
      vnode.reactive_text(signal.map(count, fn(n) { "clicked " <> n })),
      vnode.text(" times"),
      vnode.button()
      |> vnode.on("click", fn(_) { signal.set(count, signal.value(count) + 1) })
      |> vnode.child(vnode.text("Increment")),
    ])

  pream.to_preact(app)
}
```

## Features

- **Shorthand constructors** — `vnode.div()`, `vnode.span()`, `vnode.button()`, etc.
- **Pipe-friendly modifiers** — `prop`, `on`, `class`, `id`, `disabled`, ...
- **Fine-grained signals** — `signal.new`, `signal.computed`, `signal.effect` (from `@preact/signals`)
- **Component hooks** — `use_signal`, `use_signal_effect`, `use_computed`
- **Conditional helpers** — `vnode.when`, `vnode.unless`, `vnode.when_some`, `vnode.when_signal`, `vnode.map_signal`
- **Result/Option-aware** — `pream.unwrap` and `pream.unwrap_option` silently degrade into empty nodes on `Error`/`None`

## Documentation

- API reference: <https://hexdocs.pm/pream>
- Source code: <https://github.com/soulsam480/pream>

## License

MIT © 2026 soulsam480
