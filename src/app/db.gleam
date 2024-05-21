import gleam/pgo
import gleam/result
import gleam/dynamic

pub fn connect(connection_string cs: String) -> Result(pgo.Connection, Nil) {
  use config <- result.try(pgo.url_config(cs))
  Ok(pgo.connect(config))
}

//type DTO {
//InsertRoute(long_url: String, short_url: String)
//SelectRouteByLong(long_url: String)
//SelectRouteByShort(short_url: String)
//}

pub fn insert_route(db: pgo.Connection, long_url: String, short_url: String) {
  let sql = "insert into routes values ($1,$2)"
  pgo.execute(sql, db, [pgo.text(long_url), pgo.text(short_url)], dynamic.int)
}
