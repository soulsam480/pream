// @ts-nocheck

import { computed } from "@preact/signals";
import { Fragment, h as preact_h } from "preact";
import {
	Prop$Attr$key,
	Prop$Attr$value,
	Prop$Handler$event,
	Prop$Handler$handle,
	Prop$isAttr,
	Prop$isHandler,
	VChild$Element$0,
	VChild$isElement,
	VChild$isReactive,
	VChild$isReactiveText,
	VChild$isText,
	VChild$Reactive$0,
	VChild$ReactiveText$0,
	VChild$Text$0,
} from "./vnode.mjs";
import { CustomType } from "./gleam.mjs";

/**
 * @param {string} str
 * @returns {string}
 */
function camelCase(str) {
	return str
		.trim()
		.toLowerCase()
		.replace(/[_\-\s]+(.)?/g, (_, char) =>
			char ? char.toUpperCase() : "",
		);
}

/**
 * @param {import('./vnode.mjs').VNode} node
 * @returns {import('preact').ComponentChildren}
 */
export function h(node) {
	/** @type {import('preact').FunctionComponent | string} */
	let tag = node.tag;

	if (tag === "$NULL") {
		return null;
	}

	if (tag === "$FRAGMENT") {
		tag = Fragment;
	}

	return preact_h(
		tag,
		serializeProps(node.props),
		serializeChildren(node.children),
	);
}

/**
 * @param {import('./gleam.mjs').List<import('./vnode.mjs').Prop$>} props
 * @returns {Record<string, unknown>}
 */
function serializeProps(props) {
	return props.toArray().reduce(
		(
			/** @type {Record<string, unknown>} */
			acc,
			prop,
		) => {
			if (Prop$isAttr(prop)) {
				acc[Prop$Attr$key(prop)] =
					Prop$Attr$value(prop);

				return acc;
			}

			if (Prop$isHandler(prop)) {
				acc[
					camelCase(
						`on_${Prop$Handler$event(prop)}`,
					)
				] = Prop$Handler$handle(prop);

				return acc;
			}

			return acc;
		},
		{},
	);
}

/**
 * @param {import('./gleam.mjs').List<import('./vnode.mjs').VChild$>} children
 */
function serializeChildren(children) {
	return children
		.toArray()
		.map((child) => {
			if (VChild$isElement(child)) {
				const inner = VChild$Element$0(child);

				if (inner instanceof CustomType) {
					return h(inner);
				}

				return inner;
			}

			if (VChild$isText(child)) {
				return VChild$Text$0(child);
			}

			if (VChild$isReactive(child)) {
				return computed(() =>
					h(
						VChild$Reactive$0(child)
							.value,
					),
				);
			}

			if (VChild$isReactiveText(child)) {
				return computed(() =>
					VChild$ReactiveText$0(child)
						.value,
				);
			}

			return null;
		})
		.filter(Boolean);
}
