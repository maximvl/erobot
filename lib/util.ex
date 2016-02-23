defmodule Erobot.Util do
  require Logger

  def get_title(url) do
    case HTTPoison.get url, [], [follow_redirect: true,
                                 max_redirect: 3] do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_title body
      {:ok, %HTTPoison.Response{status_code: code}} ->
        "server returned #{code}"
      {:error, e} ->
        "request error #{HTTPoison.Error.message e}"
    end
  end

  def parse_title(html) do
    html |> Floki.find("title") |> Floki.text
  end
end
