variable "zone_id" {
  description = "ID of Route 53 Hosted Zone"
  type       = string
}

variable "name" {
  description = "Name of attached domain address"
  type        = string
}

variable "type" {
  description = "Type of the DNS record"
  type        = string
}

variable "dns_name" {
  description = "DNS address of attached ALB"
  type        = string
}

variable "alb_zone_id" {
  description = "ID of ALB AZ"
  type        = string
}