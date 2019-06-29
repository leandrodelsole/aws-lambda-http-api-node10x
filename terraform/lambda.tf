data "archive_file" "create" {
  type        = "zip"
  output_path = "create.zip"

  source {
    content  = "${file("../create.js")}"
    filename = "index.js"
  }
}

data "archive_file" "list" {
  type        = "zip"
  output_path = "list.zip"

  source {
    content  = "${file("../list.js")}"
    filename = "index.js"
  }
}

data "archive_file" "echo" {
  type        = "zip"
  output_path = "echo.zip"

  source {
    content  = "${file("../echo.js")}"
    filename = "index.js"
  }
}

#insert users
resource "aws_lambda_function" "create-movie" {
  function_name = "CreateMovie"

  filename         = "${data.archive_file.create.output_path}"
  source_code_hash = "${data.archive_file.create.output_base64sha256}"

  handler = "index.writeMovie"
  runtime = "nodejs10.x"

  timeout = 60 #segundos
  memory_size = 256 #mb

  role = "${aws_iam_role.create-movie.arn}"
}

resource "aws_iam_role" "create-movie" {
  name = "create-movie"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["apigateway.amazonaws.com","lambda.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "create-movie" {
  name = "lambda_policy"
  role = "${aws_iam_role.create-movie.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:Describe*",
        "cloudwatch:Get*",
        "cloudwatch:List*"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "create-movie-DynamoDBAccess" {
  role       = "${aws_iam_role.create-movie.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_lambda_permission" "create-movie" {
  statement_id  = "AllowAPIGatewayInvokeCreateMovie"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.create-movie.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_deployment.http-api.execution_arn}/${aws_api_gateway_integration.create-movie.integration_http_method}${aws_api_gateway_resource.movies.path}"
}


#list users
resource "aws_lambda_function" "list-movies" {
  function_name = "ListMovies"

  filename         = "${data.archive_file.list.output_path}"
  source_code_hash = "${data.archive_file.list.output_base64sha256}"

  handler = "index.readAllMovies"
  runtime = "nodejs10.x"

  timeout = 60 #segundos
  memory_size = 256 #mb

  role = "${aws_iam_role.list-movies.arn}"
}

resource "aws_iam_role" "list-movies" {
  name = "list-movies"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["apigateway.amazonaws.com","lambda.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "list-movies" {
  name = "lambda_policy"
  role = "${aws_iam_role.list-movies.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:Describe*",
        "cloudwatch:Get*",
        "cloudwatch:List*"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "list-movies-DynamoDBAccess" {
  role       = "${aws_iam_role.list-movies.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_lambda_permission" "list-user" {
  statement_id  = "AllowAPIGatewayInvokeListMovie"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.list-movies.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_deployment.http-api.execution_arn}/${aws_api_gateway_integration.movies-list.integration_http_method}${aws_api_gateway_resource.movies.path}"
}

#echo user
resource "aws_lambda_function" "echo-movie" {
  function_name = "EchoMovie"

  filename         = "${data.archive_file.echo.output_path}"
  source_code_hash = "${data.archive_file.echo.output_base64sha256}"

  handler = "index.echo"
  runtime = "nodejs10.x"

  timeout = 60 #segundos
  memory_size = 128 #mb

  role = "${aws_iam_role.echo-movie.arn}"
}

resource "aws_iam_role" "echo-movie" {
  name = "echo-movie"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["apigateway.amazonaws.com","lambda.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "echo-movie" {
  name = "lambda_policy"
  role = "${aws_iam_role.echo-movie.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:Describe*",
        "cloudwatch:Get*",
        "cloudwatch:List*"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_lambda_permission" "echo-movie" {
  statement_id  = "AllowAPIGatewayInvokeEchoMovie"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.echo-movie.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_deployment.http-api.execution_arn}/${aws_api_gateway_integration.movies-echo.integration_http_method}${aws_api_gateway_resource.echo.path}"
}

