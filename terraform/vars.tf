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

variable "language_shrink" {
  description = "The amount of data to use from the OPUS dataset when training a model (e.g. 0.75 means use 75%), in the same order as languages"
  type = "list"
  default = ["0.75"]
}

variable "language_oversample" {
  description = "The number of times to oversample user provided datasets when training a model, in the same order as languages"
  type = "list"
  default = ["3"]
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

variable "opus_datasets" {
  description = "Space separated list of the OPUS (http://opus.nlpl.eu/) datasets to include. Names should be the dataset names as they appear in the download path of the dataset (with the version number)."
  default = "Books/v1 DGT/v4 DOGC/v2 ECB/v1 EMEA/v3 EUbookshop/v2 EUconst/v1 Europarl/v7 giga-fren/v2 GNOME/v1 GlobalVoices/v2017q3 hrenWaC/v1 KDE4/v2 KDEdoc/v1 memat/v1 MontenegrinSubs/v1 MultiUN/v1 News-Commentary/v11 OpenOffice/v3 OpenSubtitles/v2018 ParaCrawl/v1 PHP/v1 SETIMES/v2 SPC/v1 Tatoeba/v2 TedTalks/v1 TED2013/v1.1 Tanzil/v1 TEP/v1 Ubuntu/v14.10 UN/v20090831 WikiSource/v1 Wikipedia/v1.0 WMT-News/v2014 XhosaNavy/v1"
}