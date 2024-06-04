import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn hash(str: String) -> Result(String, String) {
  str
  |> string.lowercase
  |> string.to_utf_codepoints()
  |> list.map(fn(c) { string.utf_codepoint_to_int(c) |> int.to_string() })
  |> string.join("")
  |> Ok()
}
