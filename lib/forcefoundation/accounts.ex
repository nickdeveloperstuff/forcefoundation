defmodule Forcefoundation.Accounts do
  use Ash.Domain, otp_app: :forcefoundation, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource Forcefoundation.Accounts.Token
    resource Forcefoundation.Accounts.User
  end
end
