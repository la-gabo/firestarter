defmodule FirestarterWeb.Guardian do
  use Guardian, otp_app: :firestarter

  def subject_for_token(resource, _claims) do
    # Use the resource's ID as the subject for the JWT
    sub = to_string(resource.id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    # Find the user from the database using the ID from the claims
    id = claims["sub"]
    resource = Firestarter.Accounts.get_user!(id)
    {:ok, resource}
  end
end
