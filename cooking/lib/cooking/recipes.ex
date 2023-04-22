defmodule Cooking.Recipes do
  alias AWS.DynamoDB
  alias Cooking.Recipes.Recipe

  @recipe_table "Recipes"

  def check_recipe_table_exists(), do: Cooking.check_table_exists(@recipe_table)

  def create_recipe_table_if_not_exists() do
    Cooking.get_client()
    |> DynamoDB.create_table(%{
      "TableName" => @recipe_table,
      "AttributeDefinitions" => [
        %{"AttributeName" => "HomeId", "AttributeType" => "S"},
        %{"AttributeName" => "RecipeId", "AttributeType" => "S"}
      ],
      "KeySchema" => [
        %{"AttributeName" => "HomeId", "KeyType" => "HASH"},
        %{"AttributeName" => "RecipeId", "KeyType" => "RANGE"}
      ],
      "ProvisionedThroughput" => %{
        "ReadCapacityUnits" => 5,
        "WriteCapacityUnits" => 5
      },
      "TableClass" => "STANDARD"
    })
  end

  def add_recipe(%Recipe{} = recipe) do
    recipe_to_add = Map.update(recipe, :id, nil, fn _val -> Elixir.UUID.uuid4() end)

    Cooking.get_client()
    |> DynamoDB.put_item(%{
      "TableName" => @recipe_table,
      "Item" => convert_to_aws_stuct(recipe_to_add)
    })
    |> capture_response()
  end

  def get_recipe(home_id, recipe_id) do
    Cooking.get_client()
    |> AWS.DynamoDB.get_item(%{
      "TableName" => @recipe_table,
      "Key" => %{
        "HomeId" => %{"S" => home_id},
        "RecipeId" => %{"S" => recipe_id}
      }
    })
    |> capture_response()
    |> Map.fetch!("Item")
    |> Cooking.Recipes.convert_from_aws_stuct()
  end

  def list_recipes(home_id) do
    Cooking.get_client()
    |> AWS.DynamoDB.query(%{
      "TableName" => @recipe_table,
      "KeyConditionExpression" => "HomeId = :id",
      "ExpressionAttributeValues" => %{
        ":id" => %{
          "S" => home_id
        }
      }
    })
    |> capture_response()
    |> Map.fetch!("Items")
    |> Enum.map(&Cooking.Recipes.convert_from_aws_stuct(&1))
  end

  def convert_from_aws_stuct(item) do
    %Recipe{
      home_id: item["HomeId"]["S"],
      id: item["RecipeId"]["S"],
      name: item["RecipeName"]["S"],
      source: item["RecipeSource"]["S"],
      prep_time: item["RecipePrepTime"]["S"],
      cook_time: item["RecipeCookTime"]["S"],
      servings: item["RecipeServings"]["S"],
      description: item["RecipeDesc"]["S"]
    }
  end

  defp convert_to_aws_stuct(%Recipe{} = recipe) do
    %{
      "HomeId" => %{"S" => recipe.home_id},
      "RecipeId" => %{"S" => recipe.id},
      "RecipeName" => %{"S" => recipe.name},
      "RecipeSource" => %{"S" => recipe.source},
      "RecipePrepTime" => %{"S" => recipe.prep_time},
      "RecipeCookTime" => %{"S" => recipe.cook_time},
      "RecipeServings" => %{"S" => recipe.servings},
      "RecipeDesc" => %{"S" => recipe.description}
    }
  end

  defp capture_response({:ok, response, _raw_response}), do: response

  defp capture_response({_status, _response, _raw_response}),
    do: throw("Error occured while processing request")
end
