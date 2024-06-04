import app/migrate
import app/router
import envoy
import gleam/erlang/process
import gleam/int
import gleam/result
import mist
import wisp

pub fn main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let assert Ok(db_string) = envoy.get("DATABASE_URL")
  let port = envoy.get("PORT") |> result.then(int.parse) |> result.unwrap(80)
  let assert Ok(_) = migrate.migrate(db_string)
  let context = router.Context(db_string)

  let assert Ok(_) =
    router.handle_request(_, context)
    |> wisp.mist_handler(secret_key_base)
    |> mist.new
    |> mist.port(port)
    |> mist.start_http

  process.sleep_forever()
}
