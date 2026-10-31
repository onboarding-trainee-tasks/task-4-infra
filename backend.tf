terraform {
  backend "s3" {
    bucket = "tf-backend-task-4"
    key    = "infra/state-t4"
    region = "eu-central-1"
  }
}
