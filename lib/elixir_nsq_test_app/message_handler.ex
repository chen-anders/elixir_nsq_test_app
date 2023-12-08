defmodule ElixirNsqTestApp.MessageHandler do
  def handle_message(body, msg) do
    IO.puts("received message")
   :timer.sleep(3_000)
    IO.puts(body)
    IO.puts("message processed")
    :ok
  end
end
