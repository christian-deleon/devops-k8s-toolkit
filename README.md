# DevOps Kubernetes Toolkit

## Project Overview

This project demonstrates a comprehensive DevOps workflow, showcasing provisioning, configuring, and deploying a fully-featured Kubernetes cluster both on-premise and in the cloud. Utilizing Infrastructure as Code (IaC), popular DevOps tools, GitOps principles, and industry best practices, this project serves as a robust reference implementation for building a production-ready Kubernetes environment.

### Objectives

- Provide a hands-on, practical guide to setting up Kubernetes clusters.
- Demonstrate the use of IaC for efficient and reproducible infrastructure setup.
- Highlight best practices in DevOps, GitOps, and Kubernetes management.

## Getting Started

Embark on building your Kubernetes cluster using the tools and methodologies illustrated in this project. Follow the step-by-step guides to create an environment where you can deploy applications via GitOps, managing both infrastructure and applications seamlessly.

### Prerequisites

- Familiarity with Kubernetes concepts.
- Basic understanding of Docker, Terraform, Ansible, and GitOps.
- Access to on-premise hardware or cloud infrastructure as required.

### Quickstart with Kind

For development and testing, leverage Kind for a quick and efficient setup.

**Kind**: A tool for running local Kubernetes clusters using Docker containers. Ideal for development, testing, and CI workflows.

- **Advantages**: Quick setup, designed for Kubernetes testing.
- **Guide**: [kind.md](docs/kind.md)

### Building on vSphere (On-premise)

For a more robust and production-like environment, consider building your cluster on-premise using vSphere.

**Steps**:

1. **Packer**: Customize Alma Linux 8 with RKE2 pre-installed.
    - **Guide**: [packer.md](docs/packer.md)
2. **Terraform**: Provision and manage the infrastructure.
    - **Guide**: [terraform.md](docs/terraform.md)
3. **Ansible**: Configure the provisioned infrastructure and deploy Kubernetes.
    - **Guide**: [ansible.md](docs/ansible.md)

### Cloud Deployment (Coming Soon)

Documentation and guides for deploying to popular cloud providers will be available in future updates.

### Deploying your Infrastructure and Applications using GitOps

Once your cluster is up and running, you can deploy applications using GitOps principles. Flux CD is a popular GitOps tool that allows you to manage your Kubernetes cluster and applications using Git repositories.

In the [flux.md](docs/flux.md) guide, you will learn how to deploy Flux CD to your cluster and configure it to deploy applications from a Git repository.

In the [vault.md](docs/vault.md) guide, you will learn how to deploy HashiCorp Vault to your cluster and configure it to store secrets for your applications.

In the [sealed-secrets.md](docs/sealed-secrets.md) guide, you will learn how to deploy Sealed Secrets to your cluster and configure it to encrypt and decrypt secrets for your applications.

## Coming Soon

- Cloud deployment guides
  - AWS
  - Azure
  - GCP
- Backup and disaster recovery with Velero
- Security best practices
  - RBAC
  - Network policies
  - mTLS - Encryption in transit
  - Third-party KMS integration with Vault
  - Securing etcd
  - Security Policies with Kyverno
- Monitoring and observability
  - Prometheus
  - Grafana
  - Loki
