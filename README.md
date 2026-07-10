# Highly-Available Kubernetes Cluster with Automated Provisioning

An end-to-end DevOps pipeline that provisions and operates a **highly-available, fault-tolerant Kubernetes cluster** entirely through Infrastructure-as-Code and Configuration-as-Code. The cluster hosts a containerized microservices application and is designed to keep running through the failure of individual pods, virtual machines, or entire physical servers.

The full stack - from bare VMs to a running, load-balanced application; is reproducible from scratch with two commands: `terraform apply` to build the infrastructure, and `ansible-playbook site.yml` to configure and bootstrap the cluster.

---

## Why this project

Modern platforms live or die on three properties: **automation**, **scalability**, and **reliability**. The goal here was to build a system that demonstrates all three together; not a single-node toy cluster, but a genuinely highly-available control plane on real distributed hardware, provisioned reproducibly, and then *measured* under load to find where it actually breaks.

Two questions drove the design:

1. Can the whole environment be created, torn down, and recovered with zero manual configuration?
2. When you scale, what helps more under load — adding application replicas (orchestration-level scaling) or adding worker nodes (infrastructure-level scaling)?

The answer to the second question turned out to be measurable and clear (see [Results](#results)).

---

## Architecture

The system runs on **multiple physical servers hosting virtual machines** that together form one highly-available Kubernetes cluster. Both the control plane and the workers are spread across separate physical machines so that no single hardware failure takes the cluster down.

**High-availability topology (stacked control plane):**

- **3 control-plane nodes** — the cluster keeps operating if one control-plane node is lost.
- **Multiple worker nodes** — where the application workloads actually run (scaled from 3 to 7 during the experiments).
- **2 load-balancer nodes** running **HAProxy + Keepalived** in front of the Kubernetes API server.

**The API-server load balancer** is the key HA mechanism. HAProxy load-balances traffic to the API servers, and **Keepalived manages a floating Virtual IP (VIP)** that provides one stable endpoint for the cluster. If a load-balancer node fails, the VIP is automatically reassigned to the surviving node, so the control plane stays reachable.

**Pod networking and policy** are provided by **Calico** (CNI), which also enforces `NetworkPolicy` rules for pod-to-pod segmentation.

**External access** to the application is provided by **MetalLB**, which assigns external IPs from a pool to `LoadBalancer`-type Services — bringing cloud-style load balancing to a bare-metal / on-premise cluster without any cloud provider.

```
                         ┌──────────────┐
        ┌───────────────►│ Load Balancer│──┐   HAProxy + Keepalived
   kubectl / API traffic │   (VIP)      │  │   floating Virtual IP
        └───────────────►│ Load Balancer│──┘
                         └──────────────┘
                                │
              ┌─────────────────┼─────────────────┐
              ▼                 ▼                 ▼
        ┌───────────┐     ┌───────────┐     ┌───────────┐
        │Control Pl.│     │Control Pl.│     │Control Pl.│   3× control plane
        │    1      │     │    2      │     │    3      │
        └───────────┘     └───────────┘     └───────────┘
              │                 │                 │
              └───────── worker nodes (3–7) ──────┘
                                │
                          ┌───────────┐
                          │  MetalLB  │──► External traffic to the app
                          └───────────┘
```

---

## Tech stack

| Layer | Technology | Role |
|---|---|---|
| Infrastructure-as-Code | **Terraform** + libvirt + cloud-init | Provisions VMs reproducibly across physical hosts |
| Configuration-as-Code | **Ansible** (kubeadm) | Bootstraps and configures the whole cluster |
| Container runtime | **containerd** | Runs containers on every node |
| Orchestration | **Kubernetes** (kubeadm) | Cluster orchestration |
| Control-plane HA | **HAProxy + Keepalived** | Load-balances the API server behind a floating VIP |
| Pod networking | **Calico** (CNI) | Networking + `NetworkPolicy` enforcement |
| Load balancing | **MetalLB** | External IPs for bare-metal `LoadBalancer` Services |
| Load testing | **Locust** | Controlled load generation for the experiments |

---

## How it works

The pipeline runs in two automated stages.

### 1. Infrastructure provisioning (Terraform)

Terraform with **libvirt** and **cloud-init** provisions the VMs across the physical hosts. Each VM is created with a fixed hostname-to-IP mapping so cluster formation is deterministic. During first boot, cloud-init installs the base Kubernetes packages (`containerd`, `kubeadm`, `kubelet`, `kubectl`) so every machine comes up in a consistent, Kubernetes-ready state. Terraform state is kept in a remote backend so infrastructure can be managed collaboratively.

### 2. Cluster configuration (Ansible)

Ansible bootstraps the cluster in a fully automated, **idempotent** way — the entire environment can be recreated reliably. Broken down into roles, it:

- configures **HAProxy + Keepalived** on the load balancers to provide the API-server VIP (`haproxy`, `keepalived`),
- installs and configures **containerd** on all nodes (`containerd`, `common`),
- runs `kubeadm init` on the primary control plane and joins the remaining control-plane and worker nodes with generated tokens (`kubeadm_init`, `kubeadm_join`, `kube`),
- applies the **Calico** CNI for pod networking and policy (`cni`),
- deploys **MetalLB**, the application, autoscaler, and metrics server (`deploy_metallb`, `deploy_app`, `deploy_autoscaler`, `deploy_metrics_server`).

Because every task is idempotent, re-running the automation converges the cluster back to the desired state — which is also what makes recovery simple.

---

## Repository structure

```
k8s-ha-devops-pipeline/
├── infrastructure/     # Terraform IaC — VM provisioning (libvirt + cloud-init)
│   ├── main.tf, variables.tf, outputs.tf
│   ├── modules/vm/     # reusable VM module
│   └── cloud-init/     # per-VM network + user-data
├── configuration/      # Ansible CaC — cluster bootstrap
│   ├── playbooks/      # site.yml and friends
│   ├── roles/          # haproxy, keepalived, containerd, kubeadm_init,
│   │                   #   kubeadm_join, cni, deploy_metallb, deploy_app, ...
│   └── inventory/
├── benchmarks/         # Load-test results (Locust)
│   ├── orchestration-scaling/   # replica scaling experiments
│   └── threshold-tests/         # max-concurrent-user threshold tests
├── scripts/            # load-generation helper script
└── docs/               # additional notes
```

> The application deployed on the cluster is Google's [Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo) microservices demo, referenced rather than vendored here.

---

## Results

The cluster was load-tested with **Locust** to compare two ways of scaling and to find its breaking point.

**Orchestration-level scaling (adding replicas)** reduced latency under low-to-moderate load by spreading requests across more pods — but as load kept climbing, latency rose for *every* replica configuration. The lesson: **pod-level scaling only helps up to the limits of the underlying node resources.**

**Infrastructure-level scaling (adding worker nodes)** let the cluster handle higher load with lower latency, because the extra capacity reduced resource contention and let Kubernetes schedule replicas more effectively.

**Threshold test — how much it could take:**

| Configuration | Result |
|---|---|
| 7 worker nodes, 6 replicas | Served up to **~4,600 concurrent users** with **no component failures** |
| Load generator in-cluster | **< 1% failure rate at 6,000 concurrent users** |
| Load generator in-cluster | **< 10% failure rate at 10,000 concurrent users** |

**Overall finding:** orchestration-level scaling improves performance only up to the limits of the infrastructure; infrastructure-level scaling is what provides real headroom under high load.

---

## Key engineering challenges (and fixes)

- **Inconsistent VM networking** from host bridge configuration → resolved by applying uniform cloud-init network scripts across all machines.
- **Certificate mismatches / invalid `kubeadm` tokens** after repeated cluster re-initialisations → resolved by regenerating tokens and clearing stale `kubeadm` state before re-running the automation (and by making the Ansible tasks idempotent).
- **MetalLB not assigning external IPs** → resolved by correctly defining the address pool and speaker configuration.

---

## Notes on security & hygiene

This repository was reviewed before publishing:

- **No Terraform state in version control** — `*.tfstate` and the `.terraform/` cache are git-ignored, since state can contain sensitive values.
- **No secrets committed** — the keepalived VRRP auth password is a templated variable, not a hardcoded value; the SSH keys present in cloud-init are *public* keys; password SSH auth is disabled in favour of key-based auth.
- `.tfvars` files (which typically hold sensitive input) are git-ignored.

---

> Originally a four-person team project for the *Large Systems* course (MSc, University of Amsterdam), where I worked on the implementation, experiments, Ansible automation, and security. Restructured and documented here as a portfolio piece.