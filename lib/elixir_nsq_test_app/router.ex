defmodule ElixirNsqTestApp.Router do
  use Plug.Router

  # This module is a Plug, that also implements it's own plug pipeline, below:

  # Using Plug.Logger for logging request information
  plug(Plug.Logger)
  # responsible for matching routes
  plug(:match)
  # Using Poison for JSON decoding
  # Note, order of plugs is important, by placing this _after_ the 'match' plug,
  # we will only parse the request AFTER there is a route match.
  # responsible for dispatching responses
  plug(:dispatch)


  get "/healthz" do
    send_resp(conn, 200, ~s({"status": "OK"}))
  end

  post "/ingest" do
    {:ok, post_body, _} = Plug.Conn.read_body(conn)
    {:ok, json} = Jason.decode(post_body)
    msg = Map.get(json, "msg", "")

    # Assuming you have an NSQ producer configured
    NSQ.Producer.pub(ElixirNsqTestApp.MyQueue, msg)

    send_resp(conn, 200, "Message ingested successfully")
  end

  # Catch-all route
  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
