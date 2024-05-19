import app/web
import gleam/dict
import gleam/http.{Get}
import gleam/io
import gleam/list
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

  let link =
    wisp.get_query(req)
    |> dict.from_list
    |> dict.get("link")

  case link {
    Ok(l) -> {
      io.debug(l)
      wisp.ok()
    }
    Error(_) ->
      wisp.bad_request()
      |> wisp.string_body("Got no link innit")
  }
}
