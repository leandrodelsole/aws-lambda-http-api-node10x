resource "aws_api_gateway_rest_api" "http-api" {
  name        = "AWS Lambda HTTP API in Node 10x"
  description = "API HTTP utilizando Lambda AWS em Node 10x"
}

resource "aws_api_gateway_resource" "movies" {
  rest_api_id = "${aws_api_gateway_rest_api.http-api.id}"
  parent_id   = "${aws_api_gateway_rest_api.http-api.root_resource_id}"
  path_part   = "movies"
}

resource "aws_api_gateway_resource" "echo" {
  rest_api_id = "${aws_api_gateway_rest_api.http-api.id}"
  parent_id   = "${aws_api_gateway_resource.movies.id}"
  path_part   = "echo"
}

resource "aws_api_gateway_method" "movies-create" {
  rest_api_id   = "${aws_api_gateway_rest_api.http-api.id}"
  resource_id   = "${aws_api_gateway_resource.movies.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "movies-list" {
  rest_api_id   = "${aws_api_gateway_rest_api.http-api.id}"
  resource_id   = "${aws_api_gateway_resource.movies.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "movies-echo" {
  rest_api_id   = "${aws_api_gateway_rest_api.http-api.id}"
  resource_id   = "${aws_api_gateway_resource.echo.id}"

  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "create-movie" {
  rest_api_id             = "${aws_api_gateway_rest_api.http-api.id}"
  resource_id             = "${aws_api_gateway_resource.movies.id}"
  http_method             = "${aws_api_gateway_method.movies-create.http_method}"
  integration_http_method = "POST" #must always be post when invoking lambda
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${aws_lambda_function.create-movie.function_name}/invocations"
  credentials             = "arn:aws:iam::${var.account_id}:role/${aws_iam_role.create-movie.name}"
}

resource "aws_api_gateway_integration" "movies-list" {
  rest_api_id             = "${aws_api_gateway_rest_api.http-api.id}"
  resource_id             = "${aws_api_gateway_resource.movies.id}"
  http_method             = "${aws_api_gateway_method.movies-list.http_method}"
  integration_http_method = "POST" #must always be post when invoking lambda
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${aws_lambda_function.list-movies.function_name}/invocations"
  credentials             = "arn:aws:iam::${var.account_id}:role/${aws_iam_role.create-movie.name}"
}

resource "aws_api_gateway_integration" "movies-echo" {
  rest_api_id             = "${aws_api_gateway_rest_api.http-api.id}"
  resource_id             = "${aws_api_gateway_resource.echo.id}"
  http_method             = "${aws_api_gateway_method.movies-echo.http_method}"
  integration_http_method = "POST" #must always be post when invoking lambda
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${aws_lambda_function.echo-movie.function_name}/invocations"
  credentials             = "arn:aws:iam::${var.account_id}:role/${aws_iam_role.create-movie.name}"
}

resource "aws_api_gateway_method_response" "insert-200" {
  rest_api_id = "${aws_api_gateway_rest_api.http-api.id}"
  resource_id = "${aws_api_gateway_resource.movies.id}"
  http_method = "${aws_api_gateway_method.movies-create.http_method}"
  response_models = {
    "application/json" = "Empty"
  }
  status_code = "200"
}

resource "aws_api_gateway_method_response" "list-200" {
  rest_api_id = "${aws_api_gateway_rest_api.http-api.id}"
  resource_id = "${aws_api_gateway_resource.movies.id}"
  http_method = "${aws_api_gateway_method.movies-list.http_method}"
  response_models = {
    "application/json" = "Empty"
  }
  status_code = "200"
}

resource "aws_api_gateway_method_response" "echo-200" {
  rest_api_id = "${aws_api_gateway_rest_api.http-api.id}"
  resource_id = "${aws_api_gateway_resource.echo.id}"
  http_method = "${aws_api_gateway_method.movies-echo.http_method}"
  response_models = {
    "application/json" = "Empty"
  }
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "movies-insert" {
  depends_on  = ["aws_api_gateway_integration.create-movie"]
  rest_api_id = "${aws_api_gateway_rest_api.http-api.id}"
  resource_id = "${aws_api_gateway_resource.movies.id}"
  http_method = "${aws_api_gateway_method.movies-create.http_method}"
  status_code = "${aws_api_gateway_method_response.insert-200.status_code}"
}

resource "aws_api_gateway_integration_response" "movies-list" {
  depends_on  = ["aws_api_gateway_integration.movies-list"]
  rest_api_id = "${aws_api_gateway_rest_api.http-api.id}"
  resource_id = "${aws_api_gateway_resource.movies.id}"
  http_method = "${aws_api_gateway_method.movies-list.http_method}"
  status_code = "${aws_api_gateway_method_response.list-200.status_code}"
}

resource "aws_api_gateway_integration_response" "movies-echo" {
  depends_on  = ["aws_api_gateway_integration.movies-echo"]
  rest_api_id = "${aws_api_gateway_rest_api.http-api.id}"
  resource_id = "${aws_api_gateway_resource.echo.id}"
  http_method = "${aws_api_gateway_method.movies-echo.http_method}"
  status_code = "${aws_api_gateway_method_response.echo-200.status_code}"
}

resource "aws_api_gateway_deployment" "http-api" {
  depends_on = [
    "aws_api_gateway_integration.create-movie", "aws_api_gateway_integration.movies-list", "aws_api_gateway_integration.movies-echo"]
  stage_name = "${var.api_env_stage_name}"
  rest_api_id = "${aws_api_gateway_rest_api.http-api.id}"
}

output "curl_list_movies" {
  value = "curl -H 'Content-Type: application/json' -X GET ${aws_api_gateway_deployment.http-api.invoke_url}/${aws_api_gateway_resource.movies.path_part}/ ; echo"
}

output "curl_insert_movie" {
  value = "curl -H 'Content-Type: application/json' -d '{\"name\": \"Gladiador\"}' -X POST ${aws_api_gateway_deployment.http-api.invoke_url}/${aws_api_gateway_resource.movies.path_part}/ ; echo"
}

output "curl_echo" {
  value = "curl -H 'Content-Type: application/json' -d '{\"name\": \"Echo\"}' -X POST ${aws_api_gateway_deployment.http-api.invoke_url}${aws_api_gateway_resource.echo.path}/ ; echo"
}