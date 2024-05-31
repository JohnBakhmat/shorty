import app/db
import app/web
import envoy
import gleam/dict
import gleam/http.{Get}
import gleam/int
import gleam/list
import gleam/pgo
import gleam/result
import gleam/string
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    [] -> home_page(req)
    ["new"] -> create_page(req)
    _ -> wisp.not_found()
  }
}

fn home_page(req: Request) -> Response {
  use <- wisp.require_method(req, Get)
  wisp.ok()
  |> wisp.string_body("OK")
}

fn create_page(req: Request) -> Response {
  use <- wisp.require_method(req, Get)

  let result = {
    use long_link <- result.try(
      wisp.get_query(req)
      |> dict.from_list
      |> dict.get("link"),
    )
    use short_link <- result.try(hash(long_link))

    use db_string <- result.try(envoy.get("DATABASE_URL"))
    use db_conn <- result.try(db.connect(db_string))
    let db_result = db.insert_route(db_conn, long_link, short_link)
    case db_result {
      Ok(_) -> Ok(short_link)
      Error(pgo.ConstraintViolated(_, _, _)) -> Ok(short_link)
      _ -> Error(Nil)
    }
  }

  case result {
    Ok(l) -> {
      wisp.ok()
      |> wisp.string_body(l)
    }
    Error(_) ->
      wisp.bad_request()
      |> wisp.string_body("Got no link innit")
  }
}

fn hash(str: String) -> Result(String, Nil) {
  str
  |> string.lowercase
  |> string.to_utf_codepoints()
  |> list.map(fn(c) { string.utf_codepoint_to_int(c) |> int.to_string() })
  |> string.join("")
  |> Ok()
}
