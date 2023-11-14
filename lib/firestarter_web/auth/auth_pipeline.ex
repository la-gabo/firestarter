defmodule FirestarterWeb.AuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :firestarter

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.LoadResource
end
