import app/db
import envoy
import gleam/result

pub fn migrate() {
  use connection_string <- result.try(
    envoy.get("DATABASE_URL")
    |> result.replace_error("Couldn't find DATABASE_URL in env"),
  )
  use db <- result.try(
    db.connect(connection_string) |> result.replace_error("Db connection error"),
  )
  let assert Ok(_) = db.initialize(db) |> result.replace_error("Db init error")
}
