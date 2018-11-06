defmodule Bai2Web.PageController do
  use Bai2Web, :controller
  alias Bai2.User
  alias Bai2.Repo

  plug :check_logged when action in [:index, :account_details]

  def index(conn, _params) do
    render conn, "index.html", username: get_session(conn, :username)
  end

  def login(conn, %{"username" => username, "password" => password }) do
    case User.login(username, password) do
      {:ok, liczba, %User{}} -> conn |> put_session(:username, username) |> put_session(:liczba_nieudanych, liczba) |> redirect(to: page_path(conn, :index))
      {:blokada, czas} -> render conn, "login.html", czas: czas, blokada: true
      :blokada -> render conn, "login.html", czas: nil, blokada: true
      nil -> redirect conn, to: page_path(conn, :index)
    end
  end

  def login(conn, _) do
    render conn, "login.html", blokada: false, czas: nil
  end

  def logout(conn, _) do
    conn
      |> delete_session(:username)
      |> redirect(to: page_path(conn, :index))
  end


  defp check_logged(conn, _) do
    case get_session(conn, :username) do
      nil -> redirect conn, to: page_path(conn, :login)
      _ -> conn
    end
  end

  def register(conn, %{"username" => username, "password" => password}) do
    user = Repo.get_by(User, username: username)

    if is_nil(user) or user.nie_istnieje do
      if not is_nil(user) and user.nie_istnieje do
        Repo.delete!(user)
      end

      case Repo.insert(User.changeset(%User{}, %{username: username, password: password })) do
        {:ok, %User{}} -> render conn, "login.html", blokada: false, czas: nil
        _ -> render conn, "register.html"
      end
    else
      render conn, "register.html"
    end
  end

  def register(conn, _) do
    render conn, "register.html"
  end

  

  def account_details(conn, params) do
    render conn, "account_details.html", info: User.info(get_session(conn, :username)), liczba: get_session(conn, :liczba_nieudanych)
  end

  def set_account_details(conn, params) do
    blokowanie = 
      if params["blokowanie"] == "on" do
        true
      else
        false
      end

    Repo.get_by!(User, username: get_session(conn, :username))
    |> User.changeset(%{ile_nieudanych_blokuje: params["ile_blokuje"], blokowanie_konta_wlaczone: blokowanie})
    |> Repo.update!()

    render conn, "index.html", username: get_session(conn, :username)
  end


  # Plugi

  defp check_logged(conn, _) do
    case get_session(conn, :username) do
      nil -> redirect conn, to: page_path(conn, :login)
      _ -> conn
    end
  end
end
