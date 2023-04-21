run iex -S mix

> ## Note
> I've added the 2 alias to make the commands smaller:
> - `alias AWS.Client`
> - `alias AWS.DynamoDB`

then run the below command to create a client:

```
client = Client.put_endpoint(%Client{ access_key_id: "", secret_access_key: "", port: 8000, proto: "http" }, "dynamodb-local:8000")
```

then run the below command to get the limits of the DynamoDb service:
```
DynamoDB.describe_limits(client, %{})
```

to Create a table, run the below code:
```
DynamoDB.create_table(client, %{
  "TableName" => "Music",
  "AttributeDefinitions" => [
    %{"AttributeName" => "Artist", "AttributeType" => "S"},
    %{"AttributeName" => "SontTitle", "AttributeType" => "S"}
  ],
  "KeySchema" => [
    %{"AttributeName" => "Artist", "KeyType" => "HASH"},
    %{"AttributeName" => "SontTitle", "KeyType" => "RANGE"}
  ],
  "ProvisionedThroughput" => %{
    "ReadCapacityUnits" => 5,
    "WriteCapacityUnits" =>  5
  },
  "TableClass" => "STANDARD"
})

```

To Write data, use the below command:
```
DynamoDB.put_item(client, %{
  "TableName" => "Music",
  "Item" => %{
    "Artist" => %{
      "S" => "No One You Know"
    },
    "SontTitle" => %{
      "S" => "You Still Have Not Called"
    },
    "AlbumTitle" => %{
      "S" => "SomeWhat Famous"
    },
    "Awards" => %{
      "N" => "1"
    }
  }
})
```

To read data, use the below command:
```
DynamoDB.get_item(client, %{
  "TableName" => "Music",
  "Key" => %{
    "Artist" => %{
      "S" => "No One You Know"
    },
    "SontTitle" => %{
      "S" => "You Still Have Not Called"
    }
  }
})
```

To update data, use the below command:
```
DynamoDB.update_item(client, %{
  "TableName" => "Music",
  "Key" => %{
    "Artist" => %{
      "S" => "No One You Know"
    },
    "SontTitle" => %{
      "S" => "You Still Have Not Called"
    }
  },
  "UpdateExpression" => "SET AlbumTitle = :newval",
  "ExpressionAttributeValues" => %{
    ":newval" => %{
      "S" => "Updated Album Title"
    }
  },
  "ReturnValues" => "ALL_NEW"
})
```

To query data, use the below command:
```
DynamoDB.query(client, %{
  "TableName" => "Music",
  "KeyConditionExpression" => "Artist = :name",
  "ExpressionAttributeValues" => %{
    ":name" => %{
      "S" => "No One You Know"
    }
  }
})
```

To create a secondary index, use the below command:
```
DynamoDB.update_table(client, %{
  "TableName" => "Music",
  "AttributeDefinitions" => [
    %{"AttributeName" => "AlbumTitle", "AttributeType" => "S"}
  ],
  "GlobalSecondaryIndexUpdates" => [
    %{
      "Create" => %{
        "IndexName" => "AlbumTitle-index",
        "KeySchema" => [
          %{
            "AttributeName" => "AlbumTitle",
            "KeyType" => "HASH"
          }
        ],
        "ProvisionedThroughput" => %{
          "ReadCapacityUnits" => 10,
          "WriteCapacityUnits" =>  5
        },
        "Projection" => %{
          "ProjectionType" => "ALL"
        }
      }   
    }
  ]
})
```

To use a secondary index, use the below command:
```
DynamoDB.query(client, %{
  "TableName" => "Music",
  "IndexName" => "AlbumTitle-index",
  "KeyConditionExpression" => "AlbumTitle = :name",
  "ExpressionAttributeValues" => %{
    ":name" => %{
      "S" => "Updated Album Title"
    }
  }
})
```