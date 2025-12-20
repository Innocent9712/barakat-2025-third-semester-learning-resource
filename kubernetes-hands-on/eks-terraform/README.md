# Simple EKS Cluster with Terraform

This project spins up a cost-effective EKS cluster on AWS using Terraform.

## Prerequisites

1.  **Terraform**: [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
2.  **AWS CLI**: [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3.  **kubectl**: [Install kubectl](https://kubernetes.io/docs/tasks/tools/)

## Setup Instructions

### 1. Configure AWS Credentials
Ensure you have your AWS credentials set up.
```bash
aws configure
```

### 2. Initialize Terraform
Navigate to this directory and initialize the project to download necessary plugins.
```bash
terraform init
```

### 3. Plan and Apply
Check what will be created.
```bash
terraform plan
```

If it looks good, create the infrastructure. This will take ~10-15 minutes.
```bash
terraform apply
```
Type `yes` when prompted.

### 4. Connect to the Cluster
Once Terraform finishes, it will output the cluster name. Run the following command to update your local `kubeconfig` file:

```bash
aws eks update-kubeconfig --region us-east-2 --name simple-demo-cluster
```

or create a custom `kubeconfig` file:

```bash
aws eks update-kubeconfig --region us-east-2 --name simple-demo-cluster --kubeconfig ~/.kube/demo-web-app-eks
```
Note: you'll have to use the --kubeconfig ~/.kube/demo-web-app-eks flag for kubectl commands.

Confirm/Set as active kubectl cluster context:
```bash
kubectl config use-context demo-web-app-eks
```

Verify the connection:
```bash
kubectl get nodes
```

## Cleaning Up
To avoid charges, destroy the resources when you are done.
```bash
terraform destroy

rm -rf ~/.kube/demo-web-app-eks # if custom kube config set
```

## Architecture Notes
-   **Cost Optimization**: This setup uses strictly PUBLIC subnets for the worker nodes to avoid the cost of AWS NAT Gateways (~$30/month per AZ).
-   **Security**: While fine for demos, production clusters typically use private subnets for worker nodes.
-   **Spot Instances**: The node group is configured to use SPOT instances (`capacity_type = "SPOT"`) to further reduce costs.
