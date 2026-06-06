/// represents any JS Native value
pub type Native

/// convert a gleam value to js
@external(javascript, "./dom_ffi.mjs", "to_native")
pub fn to_native(value: a) -> Native
