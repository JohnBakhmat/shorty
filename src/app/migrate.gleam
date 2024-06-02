import app/db
import gleam/result

pub fn migrate(db_string: String) {
  use db <- result.try(
    db.connect(db_string) |> result.replace_error("Db connection error"),
  )
  let assert Ok(_) = db.initialize(db) |> result.replace_error("Db init error")
}
