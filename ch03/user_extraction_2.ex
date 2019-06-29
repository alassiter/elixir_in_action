defmodule UserExtraction do
  def extract_user(user) do
    case Enum.filter(["login","email","password"], &(not Map.has_key?(user, &1))) do
      [] -> {:ok, %{login: login, email: email, password: password}}
      missing_fields -> {:error, "missing fields: #{Enum.join(missing_fields, ", ")}"}
    end
  end
end
