# API Gateway
resource "aws_api_gateway_rest_api" "movies_api" {
  name = "movies-api"
}

resource "aws_api_gateway_deployment" "movies_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.movies_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.movies_root_resource.id,
      aws_api_gateway_resource.movie_resource.id,
      module.get_movie_method.id,
      module.get_movie_method.integration_id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "live" {
  deployment_id = aws_api_gateway_deployment.movies_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.movies_api.id
  stage_name    = "live"

}

resource "aws_api_gateway_resource" "movies_root_resource" {
  parent_id   = aws_api_gateway_rest_api.movies_api.root_resource_id
  path_part   = "movies"
  rest_api_id = aws_api_gateway_rest_api.movies_api.id
}

resource "aws_api_gateway_resource" "movie_resource" {
  parent_id   = aws_api_gateway_resource.movies_root_resource.id
  path_part   = "{movieID}"
  rest_api_id = aws_api_gateway_rest_api.movies_api.id
}

module "get_movie_method" {
  source               = "./modules/rest-api-method"
  api_id               = aws_api_gateway_rest_api.movies_api.id
  http_method          = "GET"
  resource_id          = aws_api_gateway_resource.movie_resource.id
  resource_path        = aws_api_gateway_resource.movie_resource.path
  integration_uri      = module.get_movie_lambda.invoke_arn
  lambda_function_name = module.get_movie_lambda.name
  execution_arn        = aws_api_gateway_rest_api.movies_api.execution_arn
  stage_name           = aws_api_gateway_stage.live.stage_name
}
