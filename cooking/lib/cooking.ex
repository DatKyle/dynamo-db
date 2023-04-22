defmodule Cooking do
  alias AWS.Client
  alias AWS.DynamoDB

  def get_client() do
    Client.put_endpoint(
      %Client{
        access_key_id: "",
        secret_access_key: "",
        port: 8000,
        proto: "http"
      },
      "dynamodb-local:8000"
    )
  end

  def check_table_exists(table_name) do
    {:ok, tables, _full_response} =
      Cooking.get_client()
      |> DynamoDB.list_tables(%{})

    tables["TableNames"]
    |> Enum.find(fn val -> val == table_name end)
    |> table_exists()

  end

  defp table_exists(nil), do: false
  defp table_exists(_table_name), do: true

end
