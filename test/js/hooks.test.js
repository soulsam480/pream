import { describe, it, expect } from 'bun:test';
import { render, h } from 'preact';
import { Window } from 'happy-dom';
import * as hooks from '../../build/dev/javascript/pream/pream/hooks.mjs';

function setupDom() {
  const window = new Window();
  globalThis.document = window.document;
  if (!globalThis.requestAnimationFrame) {
    globalThis.requestAnimationFrame = (cb) => setTimeout(cb, 0);
  }
  return { window, document: window.document, body: window.document.body };
}

describe('use_effect', () => {
  it('runs after render', async () => {
    const { body } = setupDom();
    let ran = false;

    function App() {
      hooks.use_effect(() => {
        ran = true;
      }, []);
      return h('div');
    }

    render(h(App), body);
    await new Promise((r) => setTimeout(r, 100));

    expect(ran).toBe(true);
  });

  // cleanup on unmount requires a real scheduler (requestAnimationFrame)
  // and is tested via integration tests or @testing-library/preact
});

describe('use_layout_effect', () => {
  it('runs synchronously after DOM mutations', () => {
    const { body } = setupDom();
    let ran = false;

    function App() {
      hooks.use_layout_effect(() => {
        ran = true;
      }, []);
      return h('div');
    }

    render(h(App), body);
    expect(ran).toBe(true);
  });
});

describe('use_memo', () => {
  it('memoizes a computed value', () => {
    const { body } = setupDom();
    let computeCount = 0;

    function App() {
      const value = hooks.use_memo(() => {
        computeCount++;
        return 42;
      }, []);
      return h('div', null, value.toString());
    }

    render(h(App), body);
    expect(computeCount).toBe(1);
    expect(body.innerHTML).toBe('<div>42</div>');
  });
});

describe('use_callback', () => {
  it('memoizes a callback', () => {
    const { body } = setupDom();
    let callCount = 0;

    function App() {
      const cb = hooks.use_callback(() => {
        callCount++;
        return 42;
      }, []);
      return h('div', null, cb().toString());
    }

    render(h(App), body);
    expect(callCount).toBe(1);
    expect(body.innerHTML).toBe('<div>42</div>');
  });
});

describe('use_ref', () => {
  it('returns a mutable ref', () => {
    const { body } = setupDom();

    function App() {
      const ref = hooks.use_ref('initial');
      ref.current = 'updated';
      return h('div', null, ref.current);
    }

    render(h(App), body);
    expect(body.innerHTML).toBe('<div>updated</div>');
  });
});

describe('use_id', () => {
  it('returns a unique string', () => {
    const { body } = setupDom();
    let id1, id2;

    function App() {
      id1 = hooks.use_id();
      id2 = hooks.use_id();
      return h('div');
    }

    render(h(App), body);
    expect(typeof id1).toBe('string');
    expect(id1).not.toBe(id2);
  });
});

describe('use_mount', () => {
  it('runs once on mount', async () => {
    const { body } = setupDom();
    let mounted = false;

    function App() {
      hooks.use_mount(() => {
        mounted = true;
      });
      return h('div');
    }

    render(h(App), body);
    await new Promise((r) => setTimeout(r, 100));

    expect(mounted).toBe(true);
  });
});

// use_unmount cleanup on unmount requires a real scheduler
// and is tested via integration tests or @testing-library/preact
