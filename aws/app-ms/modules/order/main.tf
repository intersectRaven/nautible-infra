# ecrpublic_repository can only be used with us-east-1 region.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_ecrpublic_repository" "ecr_order" {
  provider        = aws.us_east_1
  repository_name = "nautible-app-ms-order"
}

resource "aws_elasticache_cluster" "order_elasticache" {
  cluster_id           = "order-statestore"
  engine               = "redis"
  node_type            = var.order_elasticache_node_type
  num_cache_nodes      = 1
  parameter_group_name = var.order_elasticache_parameter_group_name
  engine_version       = var.order_elasticache_engine_version
  port                 = var.order_elasticache_port
  subnet_group_name    = aws_elasticache_subnet_group.order_elasticache_subnet_group.name
  security_group_ids   = [var.eks_cluster_security_group_id]
}

resource "aws_elasticache_subnet_group" "order_elasticache_subnet_group" {
  name       = "order-elasticache-subnet-group"
  subnet_ids = var.private_subnets
}

resource "aws_route53_record" "order_statestore_r53record" {
  zone_id = var.private_zone_id
  name    = "order-statestore.${var.private_zone_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_elasticache_cluster.order_elasticache.cache_nodes.0.address]
}

resource "aws_dynamodb_table" "order" {
  name           = "Order"
  hash_key       = "OrderNo"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "OrderNo"
    type = "S"
  }

  attribute {
    name = "CustomerId"
    type = "N"
  }

  global_secondary_index {
    name            = "GSI-CustomerId"
    hash_key        = "CustomerId"
    range_key       = "OrderNo"
    write_capacity  = 1
    read_capacity   = 1
    projection_type = "ALL"
  }
}

resource "aws_sqs_queue" "order_sqs_dapr_pubsub" {
  # dapr 1.0.0-rc2: name must be app name hash value
  name = "a028ace4f2fd29f6e3aecbbde75cb72e9180a9ac82c2c2f77c3f985792aaefe6"
  tags = {
    # dapr 1.0.0-rc2: tag must be folling value
    "dapr-queue-name" = "nautible-app-order"
  }
}

resource "aws_sns_topic" "order_sns_topic_create_order_reply" {
  # dapr 1.0.0-rc2: name must be topic name hash value
  name = "f38092bf2e1ee3c6788054ced76c0ecc0fb2ec5310bcd54f59c9743bb9581d89"

  tags = {
    # dapr 1.0.0-rc2: tag must be folling value
    "dapr-topic-name" = "create-order-reply"
  }
}

resource "aws_sns_topic_subscription" "order_topic_subscription_create_order_reply" {
  topic_arn = aws_sns_topic.order_sns_topic_create_order_reply.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.order_sqs_dapr_pubsub.arn
}

