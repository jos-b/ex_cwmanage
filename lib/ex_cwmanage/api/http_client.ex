defmodule ExCwmanage.Api.HTTPClient do
  @moduledoc """
  HTTP Interaction with the ConnectWise api.

  Handles generation of security token and and all http communication

  Configurable settings:
  cw_api_root - the root connectwise url
  cw_companyid - the company id
  cw_publickey - your public key
  cw_privatekey - your private key
  """

  def get(path, opts \\ []) do
    to = Application.get_env(:ex_cwmanage, :http_timeout)
    rto = Application.get_env(:ex_cwmanage, :http_recv_timeout)

    with {:ok, token} <- generate_token(),
         {:ok, headers} <- generate_headers(token),
         {:ok, url} <- generate_url(path, generate_parameters(opts)),
         {:ok, http} <- HTTPoison.get(url, headers, timeout: to, recv_timeout: rto),
         {:ok, resp} <- Poison.decode(http.body) do
      {:ok, resp}
    else
      err -> err
    end
  end

  def post(path, payload) do
    to = Application.get_env(:ex_cwmanage, :http_timeout)
    rto = Application.get_env(:ex_cwmanage, :http_recv_timeout)

    with {:ok, token} <- generate_token(),
         {:ok, headers} <- generate_headers(token),
         {:ok, url} <- generate_url(path),
         {:ok, http} <- HTTPoison.post(url, payload, headers, timeout: to, recv_timeout: rto),
         {:ok, resp} <- Poison.decode(http.body) do
      {:ok, resp}
    else
      err -> err
    end
  end

  defp generate_parameters(parameters) do
    cond do
      parameters == [] ->
        nil

      length(parameters) == 2 ->
        {parameter, value} = process_parameter(parameters)
        "?#{parameter}=#{value}"

      true ->
        parms =
          parameters
          |> Enum.chunk_every(2)
          |> Enum.map(&process_parameter(&1))

        parameter_joiner(parms)
    end
  end

  defp parameter_joiner(parameters) do
    parms =
      parameters
      |> Enum.map(&"#{elem(&1, 0)}=#{elem(&1, 1)}")

    parm_string = Enum.join(parms, "&")
    "?#{parm_string}"
  end

  defp process_parameter(parameters) do
    parameter = List.first(parameters)
    value = List.last(parameters)

    case parameter do
      :conditions ->
        {"conditions", value}

      :page ->
        {"page", value}

      _unknown ->
        {:error, :unknown_option}
    end
  end

  defp generate_token do
    id = Application.get_env(:ex_cwmanage, :cw_companyid)
    pub = Application.get_env(:ex_cwmanage, :cw_publickey)
    priv = Application.get_env(:ex_cwmanage, :cw_privatekey)
    token = "#{id}+#{pub}:#{priv}"
    {:ok, Base.encode64(token)}
  end

  defp generate_headers(token) do
    headers = [
      Authorization: "Basic #{token}",
      Accept: "application/vnd.connectwise.com+json; version=3.0.0",
      "Content-Type": "application/json"
    ]

    {:ok, headers}
  end

  defp generate_url(path) do
    root = Application.get_env(:ex_cwmanage, :cw_api_root)
    url = "#{root}#{path}"
    {:ok, url}
  end

  defp generate_url(path, conditions) do
    root = Application.get_env(:ex_cwmanage, :cw_api_root)
    url = "#{root}#{path}#{conditions}"
    {:ok, url}
  end
end
