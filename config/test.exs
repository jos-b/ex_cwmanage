use Mix.Config
# if secret exists use that, otherwise use env variables
if File.exists?("config/test.secret.exs") do
  import_config "test.secret.exs"
else
  config :ex_cwmanage,
    cw_api_root: System.get_env("CW_API_ROOT"),
    cw_companyid: System.get_env("CW_COMPANYID"),
    cw_publickey: System.get_env("CW_PUBLICKEY"),
    cw_privatekey: System.get_env("CW_PRIVATEKEY")
end

## Sandbox Apis
config :ex_cwmanage, :connectwise_api, ExCwmanage.Api.Sandbox
