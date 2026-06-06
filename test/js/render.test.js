import { describe, it, expect } from "bun:test";
import { render } from "preact";
import { Window } from "happy-dom";
import { toList } from "../../build/dev/javascript/pream/gleam.mjs";
import * as vnode from "../../build/dev/javascript/pream/vnode.mjs";
import * as pream from "../../build/dev/javascript/pream/pream.mjs";
import * as signal from "../../build/dev/javascript/pream/signal.mjs";

function setupDom() {
	const window = new Window();
	globalThis.document = window.document;
	return { window, document: window.document, body: window.document.body };
}

describe("vnode rendering", () => {
	it("renders a simple div", () => {
		const { body } = setupDom();

		const node = vnode.child(
			vnode.class$(vnode.new$("div"), "container"),
			vnode.text("hello"),
		);
		const preactNode = pream.to_preact(node);
		render(preactNode, body);

		expect(body.innerHTML).toBe('<div class="container">hello</div>');
	});

	it("renders nested elements", () => {
		const { body } = setupDom();

		const node = vnode.children(
			vnode.new$("ul"),
			toList([
				vnode.element(vnode.child(vnode.new$("li"), vnode.text("a"))),
				vnode.element(vnode.child(vnode.new$("li"), vnode.text("b"))),
			]),
		);
		const preactNode = pream.to_preact(node);
		render(preactNode, body);

		expect(body.innerHTML).toBe("<ul><li>a</li><li>b</li></ul>");
	});

	it("renders a fragment", () => {
		const { body } = setupDom();

		const node = vnode.children(
			vnode.fragment(),
			toList([
				vnode.element(vnode.child(vnode.new$("div"), vnode.text("a"))),
				vnode.element(vnode.child(vnode.new$("div"), vnode.text("b"))),
			]),
		);
		const preactNode = pream.to_preact(node);
		render(preactNode, body);

		expect(body.innerHTML).toBe("<div>a</div><div>b</div>");
	});

	it("renders empty as null", () => {
		const { body } = setupDom();

		const node = vnode.empty();
		const preactNode = pream.to_preact(node);
		render(preactNode, body);

		expect(body.innerHTML).toBe("");
	});
});
