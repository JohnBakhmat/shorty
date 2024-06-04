import gleam/int
import gleam/list
import gleam/result
import gleam/string

const words = [
  "sus", "slay", "cheugy", "bussin'", "nocap", "bet", "sheesh", "slaps", "cap",
  "cringe", "yolo", "snatched", "periodt", "oof", "sksksk", "stan", "sksksks",
  "wig", "slayin'", "deadass", "skibidi", "bop", "fanum tax", "gyat",
]

fn get_word() {
  let rnd = words |> list.length |> int.random
  list.at(words, rnd) |> result.unwrap("sup")
}

pub fn hash(_str: String) -> Result(String, String) {
  ["", "", ""] |> list.map(fn(_) { get_word() }) |> string.join("-") |> Ok()
  //str
  //|> string.lowercase
  //|> string.to_utf_codepoints()
  //|> list.map(fn(c) { string.utf_codepoint_to_int(c) |> int.to_string() })
  //|> string.join("")
  //|> Ok()
}
