import { describe, expect, it } from 'bun:test';
import { render } from 'preact';
import { Window } from 'happy-dom';
import * as vnode from '../../build/dev/javascript/pream/pream/vnode.mjs';
import * as pream from '../../build/dev/javascript/pream/pream.mjs';
import * as signal from '../../build/dev/javascript/pream/pream/signal.mjs';

function setupDom() {
  const window = new Window();
  globalThis.document = window.document;
  return { window, document: window.document, body: window.document.body };
}

describe('events', () => {
  it('fires a click handler', () => {
    const { body } = setupDom();

    let clicked = false;
    const node = vnode.on(vnode.new$('button'), 'click', () => {
      clicked = true;
    });
    const preactNode = pream.to_preact(node);
    render(preactNode, body);

    const btn = body.firstElementChild;
    btn.click();

    expect(clicked).toBe(true);
  });

  it('fires an input handler', () => {
    const { body, window } = setupDom();

    let value = '';
    const node = vnode.on(vnode.new$('input'), 'input', (ev) => {
      value = ev.target.value;
    });
    const preactNode = pream.to_preact(node);
    render(preactNode, body);

    const input = body.firstElementChild;
    input.value = 'hello';
    input.dispatchEvent(new window.Event('input'));

    expect(value).toBe('hello');
  });
});

describe('signal reactivity', () => {
  it('updates text when signal changes', async () => {
    const { body } = setupDom();

    const sig = signal.new$('first');
    const node = vnode.child(vnode.new$('div'), vnode.reactive_text(sig));
    const preactNode = pream.to_preact(node);
    render(preactNode, body);

    expect(body.innerHTML).toBe('<div>first</div>');

    signal.set(sig, 'second');
    // give preact a tick to re-render
    await new Promise((r) => setTimeout(r, 10));

    expect(body.innerHTML).toBe('<div>second</div>');
  });

  it('updates child element when signal changes', async () => {
    const { body } = setupDom();

    const sig = signal.new$('a');
    const node = vnode.child(
      vnode.new$('div'),
      vnode.reactive(
        signal.map(sig, (v) => vnode.child(vnode.new$('span'), vnode.text(v))),
      ),
    );
    const preactNode = pream.to_preact(node);
    render(preactNode, body);

    expect(body.innerHTML).toBe('<div><span>a</span></div>');

    signal.set(sig, 'b');
    await new Promise((r) => setTimeout(r, 10));

    expect(body.innerHTML).toBe('<div><span>b</span></div>');
  });
});
