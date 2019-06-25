resource "aws_iam_role" "this" {
  name = "${var.name}_eks_cluster"

  assume_role_policy = <<EOL
{
  "Statement": [
    {
      "Action": [
        "sts:AssumeRole"
      ],
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "eks.amazonaws.com"
        ]
      }
    }
  ],
  "Version": "2012-10-17"
}
EOL
}

resource "aws_iam_role_policy_attachment" "this_eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

  role = "${aws_iam_role.this.name}"
}

resource "aws_iam_role_policy_attachment" "this_eks_service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"

  role = "${aws_iam_role.this.name}"
}

resource "aws_iam_policy" "this" {
  name = "${var.name}_eks_cluster"

  policy = <<EOL
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "cloudwatch:PutMetricData",
        "elasticloadbalancing:*",
        "ec2:CreateSecurityGroup",
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOL
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = "${aws_iam_role.this.name}"
  policy_arn = "${aws_iam_policy.this.arn}"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/eks/${var.name}/cluster"
  retention_in_days = 3
}

resource "aws_eks_cluster" "this" {
  depends_on = ["aws_cloudwatch_log_group.this"]

  name                      = "${var.name}"
  role_arn                  = "${aws_iam_role.this.arn}"
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  version                   = "${var.cluster_version}"

  vpc_config {
    security_group_ids = "${var.security_groups}"
    subnet_ids         = "${var.subnets}"
  }
}


# resource "aws_iam_role" "node" {
#   name = "${var.name}"

#   assume_role_policy = <<EOL
# {
#   "Statement": [
#     {
#       "Action": [
#         "sts:AssumeRole"
#       ],
#       "Effect": "Allow",
#       "Principal": {
#         "Service": [
#           "ec2.amazonaws.com"
#         ]
#       }
#     }
#   ],
#   "Version": "2012-10-17"
# }
# EOL
# }

# resource "aws_iam_instance_profile" "test_profile" {
#   name = "${var.name}"
#   role = "${aws_iam_role.role.name}"
# }



# #                 "ManagedPolicyArns": [
# #                     "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
# #                     "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
# #                     "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
# #                 ],
# #                 "Path": "/"
# #             }
# #         }
# #     }
# # }
