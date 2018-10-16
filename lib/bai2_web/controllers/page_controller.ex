defmodule Bai2Web.PageController do
  use Bai2Web, :controller
  alias Bai2.User
  alias Bai2.Repo

  plug :check_logged when action in [:index]

  def index(conn, _params) do
    render conn, "index.html", username: get_session(conn, :username)
  end

  def login(conn, _) do
    render conn, "login.html"
  end

  def logout(conn, _) do
    conn
      |> delete_session(:username)
      |> redirect(to: page_path(conn, :index))
  end

  def log_in(conn, %{"username" => username, "password" => password }) do
    case User.login(username, password) do
      %User{} -> conn |> put_session(:username, username) |> redirect(to: page_path(conn, :index))
      nil -> redirect conn, to: page_path(conn, :index)
    end
  end

  defp check_logged(conn, _) do
    case get_session(conn, :username) do
      nil -> redirect conn, to: page_path(conn, :login)
      _ -> conn
    end
  end

  def register(conn, _) do
    render conn, "register.html"
  end

  def register_post(conn, %{"username" => username, "password" => password}) do
    case Repo.insert(User.changeset(%User{}, %{username: username, password: password })) do
      {:ok, %User{}} -> put_session(conn, :username, username) |> redirect(to: page_path(conn, :index))
      _ -> render conn, "register.html"
    end
  end


  # Plugi

  defp check_logged(conn, _) do
    case get_session(conn, :username) do
      nil -> redirect conn, to: page_path(conn, :login)
      _ -> conn
    end
  end
end
