defmodule ElixirNsqTestApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @my_queue ElixirNsqTestApp.MyQueue

  @impl true
  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: ElixirNsqTestApp.Router,
        options: [port: 4040]
      ),
      %{
        id: :my_queue,
        start: {
          NSQ.Producer.Supervisor,
          :start_link,
          [
            "my-queue",
            %NSQ.Config{nsqds: ["127.0.0.1:4150"]},
            [name: @my_queue]
          ]
        }
      },
      %{
        id: :consumer,
        start: {
          NSQ.Consumer.Supervisor,
          :start_link,
          [
            "my-queue",
            "my-channel",
            %NSQ.Config{
              nsqlookupds: ["127.0.0.1:4161"],
              message_handler: ElixirNsqTestApp.MessageHandler
            }
          ]
        }
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirNsqTestApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
