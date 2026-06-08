// @ts-nocheck

import { computed } from '@preact/signals';
import { Fragment, h as preact_h } from 'preact';
import {
  Prop$Attr$key,
  Prop$Attr$value,
  Prop$Handler$event,
  Prop$Handler$handle,
  Prop$isAttr,
  Prop$isHandler,
  VChild$ComponentNode$0,
  VChild$ComponentNode$1,
  VChild$Element$0,
  VChild$isComponentNode,
  VChild$isElement,
  VChild$isReactive,
  VChild$isReactiveText,
  VChild$isText,
  VChild$Reactive$0,
  VChild$ReactiveText$0,
  VChild$Text$0,
} from './vnode.mjs';
import { Component } from '../pream.mjs';
import { CustomType } from '../gleam.mjs';

const componentCache = new WeakMap();

function getOrCreatePreactComponent(comp) {
  let fn = componentCache.get(comp);
  if (!fn) {
    fn = function GleamComponent(props) {
      return h(comp.render(props));
    };
    fn.displayName = 'GleamComponent';
    componentCache.set(comp, fn);
  }
  return fn;
}

/**
 * @param {string} str
 * @returns {string}
 */
function camel_case(str) {
  return str
    .trim()
    .toLowerCase()
    .replace(/[_\-\s]+(.)?/g, (_, char) => (char ? char.toUpperCase() : ''));
}

/**
 * @param {import('./vnode.mjs').VNode} node
 * @returns {import('preact').ComponentChildren}
 */
export function h(node) {
  /** @type {import('preact').FunctionComponent | string} */
  let tag = node.tag;

  if (tag === '$NULL') {
    return null;
  }

  if (tag === '$FRAGMENT') {
    tag = Fragment;
  }

  return preact_h(
    tag,
    serialize_props(node.props),
    serialize_children(node.children),
  );
}

/**
 * @param {import('./gleam.mjs').List<import('./vnode.mjs').Prop$>} props
 * @returns {Record<string, unknown>}
 */
function serialize_props(props) {
  return props.toArray().reduce(
    (
      /** @type {Record<string, unknown>} */
      acc,
      prop,
    ) => {
      if (Prop$isAttr(prop)) {
        acc[Prop$Attr$key(prop)] = Prop$Attr$value(prop);

        return acc;
      }

      if (Prop$isHandler(prop)) {
        acc[camel_case(`on_${Prop$Handler$event(prop)}`)] =
          Prop$Handler$handle(prop);

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
function serialize_children(children) {
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
        return computed(() => h(VChild$Reactive$0(child).value));
      }

      if (VChild$isReactiveText(child)) {
        return computed(() => VChild$ReactiveText$0(child).value);
      }

      if (VChild$isComponentNode(child)) {
        const comp = VChild$ComponentNode$0(child);
        const props = VChild$ComponentNode$1(child);
        const preactComp = getOrCreatePreactComponent(comp);
        return preact_h(preactComp, props);
      }

      return null;
    })
    .filter(Boolean);
}

function shallowEqual(a, b) {
  if (a === b) return true;
  const keysA = Object.keys(a);
  const keysB = Object.keys(b);
  if (keysA.length !== keysB.length) return false;
  for (const key of keysA) {
    if (a[key] !== b[key]) return false;
  }
  return true;
}

export function memo(component) {
  let lastProps;
  let lastResult;

  return new Component(function (props) {
    if (lastProps !== undefined && shallowEqual(lastProps, props)) {
      return lastResult;
    }
    lastProps = props;
    lastResult = component.render(props);
    return lastResult;
  });
}

export function memo_custom(component, compare) {
  let lastProps;
  let lastResult;

  return new Component(function (props) {
    if (lastProps !== undefined && compare(lastProps, props)) {
      return lastResult;
    }
    lastProps = props;
    lastResult = component.render(props);
    return lastResult;
  });
}

export function to_preact_lazy(comp, props) {
  const preactComp = getOrCreatePreactComponent(comp);
  return preact_h(preactComp, props);
}
