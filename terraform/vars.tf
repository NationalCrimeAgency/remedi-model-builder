# REMEDI configuration

variable "languages" {
  description = "Array of languages (e.g. nl) supported for translation"
  type = "list"
  default = ["nl"]
}

variable "language_names" {
  description = "Array of language names (e.g. Dutch) supported for translation, in the same order as languages"
  type = "list"
  default = ["Dutch"]
}

variable "model_bucket" {
  description = "The name of the S3 bucket containing the models (not created by the module)"
}

variable "gold_bucket" {
  description = "The name of the S3 bucket containing the gold data (that created by human translators)"
}

variable "user_contribution_bucket" {
  description = "The name of the S3 bucket containing the user contribution data (that submitted by users)"
}

# Environment configuration

variable "cidrs" {
  description = "CIDRs from which access to the REMEDI servers will be required"
  type = "list"
}

variable "kms_key_arn" {
  description = "ARN of the KMS Key"
}

variable "kms_policy_arn" {
  description = "ARN of the KMS Policy"
}

variable "ami_id" {
  description = "ID of the REMEDI Model Builder AMI as built by the Packer configuration"
}

variable "subnet_id" {
  description = "ID of the subnet on which to set up the REMEDI infrastructure"
}

variable "vpc_id" {
  description = "ID of VPC"
}

variable "key_name" {
  description = "Name of the key pair used for accessing this instance"
}

# Optional configuration

variable "tags" {
  description = "Additional tags to add on to instances"
  type = "map"
  default = {}
}

variable "disk_size" {
  description = "Size of the disk to attach to the model builder, in GB"
  default = 100
}