# Use an official lightweight base image
FROM ubuntu:latest

# Set non-interactive mode to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/google-cloud-sdk/bin:$PATH"

# Update and install basic dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    jq \
    vim \
    tar \
    iputils-ping \
    net-tools \
    dnsutils \
    software-properties-common \
    postgresql-client \
    mysql-client \
    redis-tools \
    nmap \
    netcat-openbsd \
    python3-full \
    python3-pip \
    python3-venv \
    pipx \
    groff \
    less \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Set up Python virtual environment and install packages
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install Python packages in the virtual environment
RUN pip3 install --upgrade pip && \
    pip3 install --no-cache-dir \
    boto3 \
    awscli-local \
    docker-compose \
    python-jenkins \
    python-gitlab \
    python-terraform \
    openshift \
    kubernetes \
    pre-commit \
    ansible-lint \
    yamllint \
    molecule \
    invoke \
    fabric \
    pipenv \
    poetry

# Install standalone Python applications using pipx
RUN pipx install ansible && \
    pipx install awscli && \
    pipx install pre-commit && \
    pipx install black && \
    pipx install flake8 && \
    pipx install mypy

[Rest of the Dockerfile remains the same...]

# Install Ruby gems for DevOps
RUN gem install \
    bundler \
    rake \
    serverspec \
    test-kitchen \
    kitchen-docker \
    inspec

# -----------------------------
# 🐳 Install Docker CLI and Docker Compose
# -----------------------------
# [Previous Docker section remains the same]

# Install Docker Buildx
RUN mkdir -p ~/.docker/cli-plugins/ && \
    curl -SL https://github.com/docker/buildx/releases/download/v0.12.0/buildx-v0.12.0.linux-amd64 -o ~/.docker/cli-plugins/docker-buildx && \
    chmod a+x ~/.docker/cli-plugins/docker-buildx

# -----------------------------
# 📝 Install Git Tools
# -----------------------------
# Install Git-flow
RUN apt-get update && apt-get install -y git-flow

# Install Git-lfs
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y git-lfs && \
    git lfs install

# Install pre-commit
RUN curl -sSL https://pre-commit.com/install-local.py | python3 -

# -----------------------------
# 🚀 Install Additional CI/CD Tools
# -----------------------------
# Install Jenkins CLI
RUN curl -L https://github.com/jenkins-zh/jenkins-cli/releases/latest/download/jcli-linux-amd64.tar.gz | tar xz && \
    mv jcli /usr/local/bin/

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh

# Install GitLab CLI
RUN curl -s https://raw.githubusercontent.com/profclems/glab/trunk/scripts/install.sh | bash

# -----------------------------
# 🔧 Install Infrastructure Testing Tools
# -----------------------------
# Install Terratest
RUN curl -LO https://golang.org/dl/go1.20.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.20.linux-amd64.tar.gz && \
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc && \
    go install github.com/gruntwork-io/terratest/modules/terraform

# Install Chaos Toolkit
RUN pip3 install --no-cache-dir chaostoolkit

# -----------------------------
# 📊 Install Metrics Collection Tools
# -----------------------------
# Install collectd
RUN apt-get update && apt-get install -y collectd

# Install Telegraf
RUN wget -q https://dl.influxdata.com/telegraf/releases/telegraf_1.21.4-1_amd64.deb && \
    dpkg -i telegraf_1.21.4-1_amd64.deb

# -----------------------------
# 🔍 Install Service Mesh Tools
# -----------------------------
# Install Istioctl
RUN curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.0 sh - && \
    mv istio-1.20.0/bin/istioctl /usr/local/bin/ && \
    rm -rf istio-1.20.0

# Install Linkerd CLI
RUN curl -sL https://run.linkerd.io/install | sh

# -----------------------------
# 🔐 Install Additional Security Tools
# -----------------------------
# Install Terrascan
RUN curl -L "$(curl -s https://api.github.com/repos/accurics/terrascan/releases/latest | grep -o -E "https://.+?_Linux_x86_64.tar.gz")" > terrascan.tar.gz && \
    tar -xf terrascan.tar.gz terrascan && rm terrascan.tar.gz && \
    install terrascan /usr/local/bin && rm terrascan

# Install Checkov
RUN pip3 install --no-cache-dir checkov

# Install tfsec
RUN curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

# -----------------------------
# 📈 Install Performance Monitoring
# -----------------------------
# Install sysstat for system monitoring
RUN apt-get update && apt-get install -y sysstat

# Install Siege for load testing
RUN apt-get install -y siege

# -----------------------------
# 🛠️ Install Development Environment Tools
# -----------------------------
# Install direnv for environment management
RUN curl -sfL https://direnv.net/install.sh | bash

# Install fzf for fuzzy finding
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
    ~/.fzf/install --all

# -----------------------------
# 🏁 Final Setup
# -----------------------------
# Add more convenient aliases and functions
RUN echo 'alias k=kubectl' >> ~/.bashrc && \
    echo 'alias tf=terraform' >> ~/.bashrc && \
    echo 'alias d=docker' >> ~/.bashrc && \
    echo 'alias g=git' >> ~/.bashrc && \
    echo 'source <(kubectl completion bash)' >> ~/.bashrc && \
    echo 'source <(helm completion bash)' >> ~/.bashrc && \
    echo 'source <(terraform completion bash)' >> ~/.bashrc

# Add useful functions
RUN echo 'function kns() { kubectl config set-context --current --namespace="$1"; }' >> ~/.bashrc && \
    echo 'function kdebug() { kubectl run -i --rm --tty debug --image=busybox --restart=Never -- sh; }' >> ~/.bashrc

# Create common directories
RUN mkdir -p /root/workspace /root/.kube /root/.ssh /root/scripts

# Set working directory
WORKDIR /root/workspace

# Add healthcheck
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

# Default command
CMD [ "bash" ]