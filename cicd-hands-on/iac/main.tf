terraform {
  required_version = ">= 1.0.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
  }
}

resource "local_file" "hello_world" {
  filename = "${path.module}/hello.txt"
  content  = "Hello from Terraform in CI/CD!"
}

output "file_path" {
  value = local_file.hello_world.filename
}
