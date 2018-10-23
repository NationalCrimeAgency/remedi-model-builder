# REMEDI Model Builder

The project contains the setup, deployment and scripts for building a new machine translation model for use with the
[REMEDI](https://github.com/ivan-zapreev/Distributed-Translation-Infrastructure) Machine Translation software.

It will create a new machine in AWS, pull training data from various sources, train a model, upload the resultant
model files into an S3 bucket and then terminate the AWS machine.

The data sources are:

* The [OPUS Project](http://opus.nlpl.eu/)
* An S3 bucket containing translated sentences provided by a translator 
* An S3 bucket containing user contributed JSON files that need filtering (for more details, see the `remedi-tools` project)

A CloudWatch Log will be created (`/remedi/model-builder/output`) for recording the output of the model building process.

There are 2 separate parts of this project:

## Packer

Contains [Packer](https://www.packer.io/) configuration for creating an AMI image with the necessary
tools for training models, and the necessary scripts (found in the `src` directory) for automatically building these models.
This should be run before deploying the Terraform code, using something along the lines of:

```
/opt/bin/packer build \
    -var-file=vars.json \
    -var "aws_vpc_id=$VPC" \
    -var "aws_subnet_id=$SUBNET" \
    -var "aws_region=$AWS_DEFAULT_REGION" \
    packer.json

```

Additional variables can be set, see `packer/packer.json` for full details.

## Terraform

Contains [Terraform](https://www.terraform.io/) configuration for deploying a model building machine to AWS.
The model language is specified via two Terraform variables, `languages` and `language_names`. These should
contain equal length lists of the language code and language names respectively. For example:

```
languages = ["fr", "nl"]
language_names = ["French", "Dutch"]
```

If multiple languages are specified, then a machine is set up for each language in parallel.

There are numerous other variables that need to be set prior to deploying the Terraform, see `terraform/vars.tf` for full details.

Currently, it is assumed that English will always be the target language.