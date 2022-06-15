variable "vpc_id" {
  type = string
}
variable "availability_zones" {
  type = list(string)
}
variable "client_cidr_blocks" {
  type = list(string)
}
