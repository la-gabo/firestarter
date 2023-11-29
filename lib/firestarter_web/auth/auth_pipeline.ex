defmodule FirestarterWeb.AuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :firestarter

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.LoadResource

  # research on plugs, how to get the user_id from token
  # configs
end
