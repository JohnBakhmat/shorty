import app/db
import envoy
import gleam/result

pub fn migrate() {
  use connection_string <- result.try(envoy.get("DATABASE_URL"))
  use db <- result.try(db.connect(connection_string))
  let assert Ok(_) = db.initialize(db)
}
