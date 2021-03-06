defmodule ExCwmanageApiTest do
  use ExUnit.Case
  doctest ExCwmanage

  alias ExCwmanage.Api, as: Api

  test "test get no conditions" do
    {:ok, resp} = Api.get("/system/info")
    assert is_map(resp)
    assert Map.has_key?(resp, "version")
  end

  test "test bad path" do
    {:error, resp} = Api.get("/badpath")
    assert resp == {:invalid, "<", 0}
  end

  test "get with conditions" do
    {:ok, resp} = Api.get("/service/locations")
    {:ok, resp2} = Api.get("/service/locations", [:conditions, "id=1"])
    assert length(resp) > 0
    assert length(resp2) > 0
    assert length(resp) > length(resp2)
  end
end
