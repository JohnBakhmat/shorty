import app/db
import app/web
import gleam/dict
import gleam/http.{Get}
import gleam/int
import gleam/list
import gleam/pgo
import gleam/result
import gleam/string
import wisp.{type Request, type Response}

pub type Context {
  Context(database_url: String)
}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    [] -> home_page(req, ctx)
    ["new"] -> create_page(req, ctx)
    _ -> wisp.not_found()
  }
}

fn home_page(req: Request, _ctx: Context) -> Response {
  use <- wisp.require_method(req, Get)
  wisp.ok()
  |> wisp.string_body("OK")
}

fn create_page(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Get)
  let result = {
    use long_link <- result.try(
      wisp.get_query(req)
      |> dict.from_list
      |> dict.get("link")
      |> result.replace_error("Http query error"),
    )
    use short_link <- result.try(
      hash(long_link) |> result.replace_error("Hashing error"),
    )

    use db_conn <- result.try(
      db.connect(ctx.database_url)
      |> result.replace_error("Can't connect to database"),
    )
    let db_result = db.insert_route(db_conn, long_link, short_link)

    case db_result {
      Ok(_) -> Ok(short_link)
      Error(pgo.ConstraintViolated(_, _, _)) -> Ok(short_link)
      _ -> Error("Unexpected insertion error")
    }
  }

  case result {
    Ok(short_link) -> wisp.ok() |> wisp.string_body(short_link)
    Error(error) -> wisp.bad_request() |> wisp.string_body(error)
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
