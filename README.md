# simple-nginx-webserver

## Introduction

This repo provides an example of AWS three-tier VPC architecture and a deployment of simple webserver using NGINX on top of ECS cluster. The architecture diagram could be seen below.

![image info](./diagrams/vpc-three-tier.drawio.png)

Sample Terraform modules and codes are provided in the directory `infrastructure/terraform`. The Terraform module could be used to provision the infrastructure foundation consists of an AWS VPC, an AWS ECS Cluster, and a cheaper alternative of AWS NAT Gateway. The other module is used to setup an Fargate ECS service alongside with AWS Application Load Balancer, AWS Code Deploy to handle the blue-green deployment, and AWS SSM Parameter Store to source configurations that will be used by the service.

Both infra-foundation and sample service had been provisioned and could be accessed using this URL:
- https://webserver-staging.grnnd.online/
- https://webserver-prod.grnnd.online/

