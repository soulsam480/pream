/**
 * @private only for gleam compat
 * @typedef {HTMLElement} THTMLElement
 */

import { Option$isNone, Option$isSome } from "./gleam_stdlib/gleam/option.mjs";

/**
 * @param {unknown} value
 */
const to_native = (value) => {
	if (Option$isSome(value)) {
		return value;
	}

	if (Option$isNone(value)) {
		return;
	}

	return value;
};

export { to_native };
