import app/db
import app/web
import envoy
import gleam/dict
import gleam/http.{Get}
import gleam/list
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
    let assert Ok(long_link) =
      wisp.get_query(req)
      |> dict.from_list
      |> dict.get("link")

    let assert Ok(short_link) = hash(long_link)

    let assert Ok(db_string) =
      envoy.get("DATABASE_URL")
      |> result.replace_error("No DATABASE_URL provided")

    let assert Ok(db_conn) =
      db.connect(db_string)
      |> result.replace_error("Couldn't connect to db")
    let assert Ok(_) = db.insert_route(db_conn, long_link, short_link)
    Ok(short_link)
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
  |> string.to_graphemes
  |> list.shuffle
  |> string.join("")
  |> Ok()
}
