import {
	useCallback as preact_use_callback,
	useDebugValue as preact_use_debug_value,
	useEffect as preact_use_effect,
	useId as preact_use_id,
	useImperativeHandle as preact_use_imperative_handle,
	useLayoutEffect as preact_use_layout_effect,
	useMemo as preact_use_memo,
	useRef as preact_use_ref,
} from 'preact/hooks';

/**
 * Convert a Gleam List to a JS array for Preact's deps.
 * Preact treats `undefined` deps as "every render" and
 * `[]` as "once on mount".
 * @param {import('../gleam.mjs').List<any> | null} deps
 * @returns {any[] | undefined}
 */
function deps_array(deps) {
	if (deps == null) return undefined;
	if (Array.isArray(deps)) return deps;
	return deps.toArray();
}

export function use_effect(run, deps) {
	preact_use_effect(run, deps_array(deps));
}

export function use_layout_effect(run, deps) {
	preact_use_layout_effect(run, deps_array(deps));
}

export function use_effect_cleanup(run, deps) {
	preact_use_effect(run, deps_array(deps));
}

export function use_layout_effect_cleanup(run, deps) {
	preact_use_layout_effect(run, deps_array(deps));
}

export function use_memo(factory, deps) {
	return preact_use_memo(factory, deps_array(deps));
}

export function use_callback(callback, deps) {
	return preact_use_callback(callback, deps_array(deps));
}

export function use_ref(initial) {
	return preact_use_ref(initial);
}

export function use_imperative_handle(ref, create_handle, deps) {
	preact_use_imperative_handle(ref, create_handle, deps_array(deps));
}

export function use_id() {
	return preact_use_id();
}

export function use_debug_value(value) {
	preact_use_debug_value(value);
}
