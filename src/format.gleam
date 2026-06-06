import gleam/string

/// positional string formatting
@internal
pub fn on(source: String, values: List(String)) -> String {
  case values {
    [] -> source
    [head, ..tail] -> {
      case string.split_once(source, "{}") {
        Ok(#(pre, post)) -> on(pre <> head <> post, tail)
        _ -> source
      }
    }
  }
}
