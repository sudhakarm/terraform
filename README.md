# Terraform
This repository is a collection of sample scripts to create/manage infrastucture in AWS (primarily).
Intended to run via Github workflows (actions). 

## Prerequisites:
- Knowledge on Terraform
- Terraform CLI
- AWS account (access key & secret)
- AWS CLI (optional) - for testing deployed infra

Run terraform configuration in 3 steps:
```sh
# initialize *.tf files and downloads required modules, provisioner etc
$ terraform init

# to test the configuration and syntax issues
$ terraform plan

# to apply the configuration, have to give input 'yes' to give your approval to apply changes. 
# Also, If run along with the `-auto-approve` flag (its pre-aproved, better be careful using this)
$ terraform apply


```

## Important!
Before running the terraform code, please be aware that you need to replace the secrets for AWS connection.
I have confugured them as secrets in github actions. 


```yaml
#github_actions_sample.yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
...
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
...

```

you can test the configuration in your local by adding these values. Intentionally `ommited` that file.
```sh
#vars.tf
variable "access_key" {
  default = "<ACCESS_KEY>"
}
variable "secret_key" {
    default = "<SECRET_KEY>"
}
```

## Resources
### 1. Creating an EKS cluster in AWS using terraform module (customized). 
documentation here >> [EKS Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) | [EKS sample](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks)
