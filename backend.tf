terraform {
  backend "s3" {
    bucket = "tf-backend-task-4"
    key    = "infra/state"
    region = "eu-central-1"
  }
}
