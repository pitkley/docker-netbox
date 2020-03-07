FROM python:3

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        sudo graphviz postgresql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone and install netbox
ENV NETBOX_COMMIT f9073a2f07e8965d1ff4e5da458d8838d2f3a55f
RUN mkdir -p /usr/src/netbox \
    && git clone https://github.com/digitalocean/netbox.git /usr/src/netbox \
    && (cd /usr/src/netbox && git checkout -q "$NETBOX_COMMIT") \
    && (cd /usr/src/netbox && pip install --no-cache-dir -r requirements.txt)

# Change workdir
WORKDIR /usr/src/netbox/netbox

# Create user
RUN groupadd -g 1000 netbox \
    && useradd -u 1000 -g 1000 -d /usr/src/netbox netbox \
    && chown -Rh netbox:netbox /usr/src/netbox

# Setup entrypoint
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

# Expose ports
EXPOSE 8000/tcp

ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["runserver", "--insecure", "0.0.0.0:8000"]
