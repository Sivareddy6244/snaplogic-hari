FROM eclipse-temurin:21-jdk-jammy AS builder

# Labels for better image management
LABEL maintainer="Your Name <your.email@example.com>"
LABEL description="Docker image for Liquibase with Azure dependencies"

# Install necessary tools and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        tar \
        curl \
        bash

# Clean up apt cache
&& rm -rf /var/lib/apt/lists/*

# Download and install liquibase (specify the version you need)
ARG LIQUIBASE_VERSION=4.21.1
RUN mkdir -p /opt/liquibase && \
    curl -L "https://github.com/liquibase/liquibase/releases/download/v${LIQUIBASE_VERSION}/liquibase-${LIQUIBASE_VERSION}.tar.gz" -o liquibase.tar.gz && \
    tar -xzf liquibase.tar.gz -C /opt/liquibase && \
    rm liquibase.tar.gz && \
    chmod +x /opt/liquibase/liquibase

# Set liquibase as an environment variable
ENV LIQUIBASE_HOME=/opt/liquibase
ENV PATH=${JAVA_HOME}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${LIQUIBASE_HOME}*

# Copy custom liquibase extensions (if any)
COPY liquibase/opt/liquibase/lib/

# Copy and run the script to install Azure dependencies
COPY scripts/install_azure_dependencies.sh /tmp/
RUN chmod +x /tmp/install_azure_dependencies.sh && \
    /tmp/install_azure_dependencies.sh && \
    rm /tmp/install_azure_dependencies.sh

WORKDIR /liquibase/data

# Healthcheck (optional, but recommended) -- Adjust the command!
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD liquibase --version || exit 1

ENTRYPOINT ["liquibase"]
