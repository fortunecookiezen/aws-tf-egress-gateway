module "egress-gateway" {
  source             = "../"
  vpc_id             = "vpc-akldjadlkjald"
  availability_zones = [""]
  client_cidr_blocks = [""]
}
