resource "aws_dynamodb_table" "movies" {
  name           = "movies"
  billing_mode   = "PAY_PER_REQUEST"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
