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
  it('renders a component child as a Preact function component', () => {
    const { body } = setupDom();

    const comp = new pream.Component((props) =>
      vnode.child(vnode.new$('span'), vnode.text('inner')),
    );
    const child = pream.component_child(comp, {});

    const rootNode = vnode.child(vnode.new$('main'), child);
    const preactNode = pream.to_preact(rootNode);
    render(preactNode, body);

    expect(body.innerHTML).toBe('<main><span>inner</span></main>');
  });

  it('renders nested component children preserving boundaries', () => {
    const { body } = setupDom();

    const leafComp = new pream.Component((props) =>
      vnode.child(vnode.new$('span'), vnode.text(props.name)),
    );
    const innerComp = new pream.Component(() =>
      vnode.children(
        vnode.new$('div'),
        toList([
          pream.component_child(leafComp, { name: 'leaf' }),
          vnode.text('world'),
        ]),
      ),
    );
    const rootComp = new pream.Component(() =>
      vnode.child(vnode.new$('main'), pream.component_child(innerComp, {})),
    );

    const preactNode = pream.to_preact_component(rootComp, {});
    render(preactNode, body);

    expect(body.innerHTML).toBe('<main><div><span>leaf</span>world</div></main>');
  });

  it('to_preact_component returns a Preact VNode with function type', () => {
    const comp = new pream.Component(() =>
      vnode.child(vnode.new$('div'), vnode.text('hello')),
    );
    const preactNode = pream.to_preact_component(comp, {});

    expect(typeof preactNode.type).toBe('function');
  });
});
