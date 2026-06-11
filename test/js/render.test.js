import { describe, expect, it } from 'bun:test';
import { render } from 'preact';
import { Window } from 'happy-dom';
import { toList } from '../../build/dev/javascript/pream/gleam.mjs';
import * as vnode from '../../build/dev/javascript/pream/pream/vnode.mjs';
import * as pream from '../../build/dev/javascript/pream/pream.mjs';

function setupDom() {
  const window = new Window();
  globalThis.document = window.document;
  return { window, document: window.document, body: window.document.body };
}

describe('vnode rendering', () => {
  it('renders a simple div', () => {
    const { body } = setupDom();

    const node = vnode.child(
      vnode.class$(vnode.new$('div'), 'container'),
      vnode.text('hello'),
    );
    const preactNode = pream.to_preact(node);
    render(preactNode, body);

    expect(body.innerHTML).toBe('<div class="container">hello</div>');
  });

  it('renders nested elements', () => {
    const { body } = setupDom();

    const node = vnode.children(
      vnode.new$('ul'),
      toList([
        vnode.element(vnode.child(vnode.new$('li'), vnode.text('a'))),
        vnode.element(vnode.child(vnode.new$('li'), vnode.text('b'))),
      ]),
    );
    const preactNode = pream.to_preact(node);
    render(preactNode, body);

    expect(body.innerHTML).toBe('<ul><li>a</li><li>b</li></ul>');
  });

  it('renders a fragment', () => {
    const { body } = setupDom();

    const node = vnode.children(
      vnode.fragment(),
      toList([
        vnode.element(vnode.child(vnode.new$('div'), vnode.text('a'))),
        vnode.element(vnode.child(vnode.new$('div'), vnode.text('b'))),
      ]),
    );
    const preactNode = pream.to_preact(node);
    render(preactNode, body);

    expect(body.innerHTML).toBe('<div>a</div><div>b</div>');
  });

  it('renders empty as null', () => {
    const { body } = setupDom();

    const node = vnode.empty();
    const preactNode = pream.to_preact(node);
    render(preactNode, body);

    expect(body.innerHTML).toBe('');
  });
});

describe('component boundaries', () => {
  it('renders a component boundary with a named function', () => {
    const { body } = setupDom();

    function counter() {
      return vnode.child(vnode.new$('span'), vnode.text('inner'));
    }
    const child = vnode.component(counter);

    const rootNode = vnode.child(vnode.new$('main'), child);
    const preactNode = pream.to_preact(rootNode);
    render(preactNode, body);

    expect(body.innerHTML).toBe('<main><span>inner</span></main>');
  });

  it('renders a component boundary with an inline closure', () => {
    const { body } = setupDom();

    const child = vnode.component(() =>
      vnode.child(vnode.new$('span'), vnode.text('inner')),
    );

    const rootNode = vnode.child(vnode.new$('main'), child);
    const preactNode = pream.to_preact(rootNode);
    render(preactNode, body);

    expect(body.innerHTML).toBe('<main><span>inner</span></main>');
  });

  it('renders nested component boundaries', () => {
    const { body } = setupDom();

    const leaf = (name) =>
      vnode.child(vnode.new$('span'), vnode.text(name));
    const inner = () =>
      vnode.children(vnode.new$('div'), toList([
        vnode.component(() => leaf('leaf')),
        vnode.text('world'),
      ]));

    const rootNode = vnode.child(
      vnode.new$('main'),
      vnode.component(inner),
    );
    const preactNode = pream.to_preact(rootNode);
    render(preactNode, body);

    expect(body.innerHTML).toBe('<main><div><span>leaf</span>world</div></main>');
  });

  it('component boundary creates a Boundary VChild', () => {
    const child = vnode.component(() =>
      vnode.child(vnode.new$('div'), vnode.text('hello')),
    );

    expect(vnode.VChild$isBoundary(child)).toBe(true);
  });
});