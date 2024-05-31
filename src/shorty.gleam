import app/migrate
import app/router
import gleam/erlang/process
import mist
import wisp

pub fn main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let assert Ok(_) = migrate.migrate()
  let assert Ok(_) =
    router.handle_request
    |> wisp.mist_handler(secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}
