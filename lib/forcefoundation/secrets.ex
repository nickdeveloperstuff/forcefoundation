defmodule Forcefoundation.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        Forcefoundation.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:forcefoundation, :token_signing_secret)
  end
end
