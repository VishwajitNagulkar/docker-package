# Use an official lightweight base image
FROM ubuntu:latest

# Set non-interactive mode to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/google-cloud-sdk/bin:$PATH"

# Update and install basic dependencies
# Update and install basic dependencies
# RUN apt-get update && apt-get install -y \
#     curl \
#     wget \
#     git \
#     unzip \
#     jq \
#     vim \
#     iputils-ping \
#     net-tools \
#     dnsutils \
#     software-properties-common \
#     postgresql-client \
#     mysql-client \
#     redis-tools \
#     nmap \
#     netcat-openbsd \
#     && rm -rf /var/lib/apt/lists/*


# # -----------------------------
# # 🐳 Install Docker CLI
# # -----------------------------
# RUN curl -fsSL https://get.docker.com | sh

# # -----------------------------
# # ☸️ Install Kubernetes CLI tools
# # -----------------------------
# # Install kubectl
# RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
#     && chmod +x kubectl \
#     && mv kubectl /usr/local/bin/

# # Install kustomize
# RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash

# # Install Helm
# RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# # Install kind (Kubernetes in Docker)
# RUN curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64 && chmod +x /usr/local/bin/kind

# # Install k9s (Kubernetes Terminal UI)
# RUN curl -sSLO https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz && \
#     tar -xvf k9s_Linux_amd64.tar.gz && mv k9s /usr/local/bin/ && rm k9s_Linux_amd64.tar.gz

# # Install kubectx and kubens (Kubernetes context switching)
# RUN git clone https://github.com/ahmetb/kubectx /opt/kubectx && \
#     ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx && \
#     ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# # -----------------------------
# # ⚙️ Install Terraform & Ansible
# # -----------------------------
# RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
#     apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
#     apt-get update && apt-get install -y terraform ansible

# # -----------------------------
# # 🚀 Install CI/CD Tools
# # -----------------------------
# # Install ArgoCD CLI
# RUN curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 && chmod +x /usr/local/bin/argocd

# # Install Tekton CLI
# RUN curl -sSL -o /usr/local/bin/tkn https://github.com/tektoncd/cli/releases/latest/download/tkn-linux-amd64 && chmod +x /usr/local/bin/tkn

# # Install FluxCD CLI
# RUN curl -s https://fluxcd.io/install.sh | bash

# # Install Skaffold
# RUN curl -Lo /usr/local/bin/skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && chmod +x /usr/local/bin/skaffold

# -----------------------------
# 🔍 Install Observability Tools
# -----------------------------
# Get latest Prometheus release version dynamically
RUN PROM_VERSION=$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | jq -r .tag_name) && \
    curl -sSLO "https://github.com/prometheus/prometheus/releases/download/${PROM_VERSION}/prometheus-${PROM_VERSION#v}.linux-amd64.tar.gz" && \
    tar -xzf prometheus-${PROM_VERSION#v}.linux-amd64.tar.gz && \
    mv prometheus-${PROM_VERSION#v}.linux-amd64/promtool /usr/local/bin/ && \
    rm -rf prometheus-*

# Install Grafana CLI
RUN curl -sSLO https://dl.grafana.com/oss/release/grafana-*-linux-amd64.tar.gz && \
    tar -xzf grafana-*-linux-amd64.tar.gz && mv grafana-*-linux-amd64/bin/grafana-cli /usr/local/bin/ && rm -rf grafana-*

# Install Velero (Kubernetes Backup)
RUN curl -LO https://github.com/vmware-tanzu/velero/releases/latest/download/velero-linux-amd64.tar.gz && \
    tar -xzf velero-linux-amd64.tar.gz && mv velero-linux-amd64/velero /usr/local/bin/

# -----------------------------
# 🛡️ Install Security Tools
# -----------------------------
# Install Trivy (Container Security Scanner)
RUN curl -fsSL https://aquasecurity.github.io/trivy/releases/latest/trivy-linux-amd64.tar.gz | tar xz && mv trivy /usr/local/bin/

# Install kube-bench (Kubernetes CIS Benchmark)
RUN curl -LO https://github.com/aquasecurity/kube-bench/releases/latest/download/kube-bench-linux-amd64 && chmod +x kube-bench-linux-amd64 && mv kube-bench-linux-amd64 /usr/local/bin/kube-bench

# -----------------------------
# ☁️ Install Cloud CLI Tools
# -----------------------------
# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install && rm -rf awscliv2.zip aws

# Install GCP SDK
RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-$(curl -s https://dl.google.com/dl/cloudsdk/channels/rapid/components-2.json | jq -r .version)-linux-x86_64.tar.gz && \
    tar -xzf google-cloud-sdk-*.tar.gz && ./google-cloud-sdk/install.sh -q && rm -rf google-cloud-sdk-*.tar.gz

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# -----------------------------
# 🏁 Final Setup
# -----------------------------
# Set working directory
WORKDIR /root

# Default command
CMD [ "bash" ]
