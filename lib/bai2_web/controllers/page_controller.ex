defmodule Bai2Web.PageController do
  use Bai2Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
