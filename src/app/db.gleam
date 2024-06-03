import gleam/dynamic
import gleam/list
import gleam/pgo
import gleam/result

pub type DatabaseError {
  ConnectionError
  InsertionError
  SelectionError
  Nil
}

pub fn connect(
  connection_string cs: String,
) -> Result(pgo.Connection, DatabaseError) {
  use config <- result.try(
    pgo.url_config(cs) |> result.replace_error(ConnectionError),
  )
  Ok(pgo.connect(config))
}

pub fn initialize(db: pgo.Connection) {
  let sql =
    "
    create table if not exists routes(
      id serial primary key,
      short_url text not null unique,
      long_url text not null unique
    )
    "
  pgo.execute(sql, db, [], dynamic.dynamic)
}

pub fn insert_route(db: pgo.Connection, long_url: String, short_url: String) {
  let sql = "insert into routes (long_url,short_url) values ($1,$2)"
  let res =
    pgo.execute(
      sql,
      db,
      [pgo.text(long_url), pgo.text(short_url)],
      dynamic.dynamic,
    )
  case res {
    Ok(_) -> Ok(short_url)
    Error(pgo.ConstraintViolated(_, _, _)) -> Ok(short_url)
    _ -> Error(InsertionError)
  }
}

pub fn find_route_by_short(db: pgo.Connection, short_url url: String) {
  let sql = "select long_url,short_url from routes where short_url = $1 limit 1"
  let assert Ok(resp) =
    pgo.execute(
      sql,
      db,
      [pgo.text(url)],
      dynamic.tuple2(dynamic.string, dynamic.string),
    )
  list.first(resp.rows)
  |> result.map(fn(res) {
    let #(long_link, _) = res
    long_link
  })
  |> result.replace_error(SelectionError)
}

pub fn find_route_by_long(db: pgo.Connection, long_url url: String) {
  let sql = "select short_url from routes where long_url = $1 limit 1"
  let assert Ok(resp) = pgo.execute(sql, db, [pgo.text(url)], dynamic.string)
  list.first(resp.rows)
}
