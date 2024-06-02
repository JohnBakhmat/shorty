import app/db as database
import app/web
import gleam/dict
import gleam/http.{Get}
import gleam/int
import gleam/list
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
    [short_link] -> redirect_page(req, ctx, short_link)
    _ -> wisp.not_found()
  }
}

fn redirect_page(req: Request, ctx: Context, short_link: String) -> Response {
  use <- wisp.require_method(req, Get)

  let result = {
    use db <- result.try(database.connect(ctx.database_url))
    use route <- result.try(database.find_route_by_short(db, short_link))
    Ok(route)
  }

  case result {
    Ok(link) -> wisp.moved_permanently(link)
    Error(database.SelectionError) -> wisp.not_found()
    _ -> wisp.bad_request()
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
      |> dict.from_list()
      |> dict.get("link")
      |> result.replace_error("Http query error"),
    )
    use short_link <- result.try(hash(long_link))
    use db_conn <- result.try(
      database.connect(ctx.database_url)
      |> result.replace_error("Db connection error"),
    )
    database.insert_route(db_conn, long_link, short_link)
    |> result.replace_error("Insertion error")
  }

  case result {
    Ok(short_link) -> wisp.ok() |> wisp.string_body(short_link)
    Error(error) -> wisp.bad_request() |> wisp.string_body(error)
  }
}

fn hash(str: String) -> Result(String, String) {
  str
  |> string.lowercase
  |> string.to_utf_codepoints()
  |> list.map(fn(c) { string.utf_codepoint_to_int(c) |> int.to_string() })
  |> string.join("")
  |> Ok()
}
