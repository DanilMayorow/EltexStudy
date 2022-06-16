defmodule Course do
  use Sippet.Core

  def receive_request(incoming_request, server_key) do
    # route the request to your UA or proxy process
  end

  def receive_response(incoming_response, client_key) do
    # route the response to your UA or proxy process
  end

  def receive_error(reason, client_or_server_key) do
    # route the error to your UA or proxy process
  end
end