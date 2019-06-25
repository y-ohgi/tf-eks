terraform {}

provider "aws" {
  region = "ap-northeast-1"
}

variable "name" {
  default = "search"
}

module "vpc" {
  source = "git::https://github.com/y-ohgi/tf-vpc.git?ref=v1.0.0"

  name               = "${var.name}"
  single_nat_gateway = true

  tags = {
    "kubernetes.io/cluster/search" = "shared"
  }
}

module "sg_eks" {
  source = "./modules/security-group"

  name   = "${var.name}"
  vpc_id = "${module.vpc.vpc_id}"

  ingress_with_cidr_block_rules = [
    {
      cidr_blocks = "${module.vpc.vpc_cidr_block}"
      from_port   = -1
      to_port     = -1
      protocol    = -1
      description = "Allow access from within VPC"
    },
  ]

}

module "eks_cluster" {
  source = "./modules/eks-cluster"

  name            = "${var.name}"
  cluster_version = "1.12"
  subnets         = "${concat(module.vpc.public_subnets, module.vpc.private_subnets)}"
  security_groups = ["${module.sg_eks.sg_id}"]
}
