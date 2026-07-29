output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "A list of public subnet IDs"
  value       = [for subnet in aws_subnet.this : subnet.id if subnet.tags["Type"] == "public"]
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}