FROM debian:bookworm-slim

ARG TERRAFORM_VERSION=1.9.8

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl unzip git jq python3 bash \
 && curl -fsSLo /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
 && unzip -q /tmp/terraform.zip -d /usr/local/bin \
 && rm -f /tmp/terraform.zip \
 && apt-get purge -y curl unzip \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY . /workspace

RUN chmod +x scripts/*.sh tests/*.sh \
 && git config --global --add safe.directory /workspace

CMD ["/bin/bash"]