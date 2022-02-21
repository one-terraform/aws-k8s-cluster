terraform {
    required_providers {
      aws = {
          version = "~> 3.0"
          source = "hashicorp/aws"

      }
    }
}

provider "aws" {
  region = "us-east-1"
  profile = "terra"
}

variable "AMI" {
  type = string
  default = "ami-04505e74c0741db8d"
}

resource "random_integer" "node-suffix"{
    min = 1
    max = 500
}

#Master Node
resource "aws_instance" "k8sMaster" {
  ami = var.AMI
  instance_type = "t2.medium"
  #name = "kb8-master"

  user_data = file("manager.sh")

  tags = {
      Name = "K8sMaster"
  }

  key_name = "ansible"

  security_groups = ["kb8s"]
}

#Worker Nodes
resource "aws_instance" "k8sNode" {
    count = 2
    ami = var.AMI
    instance_type = "t2.micro"
    #name = join("-", ["kb8-Node", count.index])

    user_data = file("worker.sh")

    tags = {
        #Name = join("-", ["Kb8-Master", random_integer.node-suffix.result])
        Name = join("-", ["k8sNode", count.index])
    }

    key_name = "ansible"

    security_groups = ["kb8s"]
}

