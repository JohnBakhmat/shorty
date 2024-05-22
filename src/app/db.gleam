import gleam/dynamic
import gleam/list
import gleam/pgo
import gleam/option.{Some}

pub fn connect(connection_string cs: String) -> Result(pgo.Connection, Nil) {
  //use config <- result.try(pgo.url_config(cs))

  Ok(pgo.connect(
    pgo.Config(
      ..pgo.default_config(),
      host: "127.0.0.1",
      port: 5432,
      database: "postgres",
      user: "postgres",
      password: Some("supfuckers"),
    ),
  ))
}

pub fn insert_route(db: pgo.Connection, long_url: String, short_url: String) {
  let sql = "insert into routes (long_url,short_url) values ($1,$2)"
  pgo.execute(sql, db, [pgo.text(long_url), pgo.text(short_url)], dynamic.int)
}

pub fn find_route_by_short(db: pgo.Connection, short_url url: String) {
  let sql = "select long_url from routes where short_url = $1 limit 1"
  let assert Ok(resp) = pgo.execute(sql, db, [pgo.text(url)], dynamic.string)
  list.first(resp.rows)
}

pub fn find_route_by_long(db: pgo.Connection, long_url url: String) {
  let sql = "select short_url from routes where long_url = $1 limit 1"
  let assert Ok(resp) = pgo.execute(sql, db, [pgo.text(url)], dynamic.string)
  list.first(resp.rows)
}
