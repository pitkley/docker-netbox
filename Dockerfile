FROM python:3

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        sudo graphviz postgresql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install netbox from local checkout
RUN mkdir -p /usr/src/netbox
COPY netbox/ /usr/src/netbox/
RUN cd /usr/src/netbox \
    && pip install --no-cache-dir -r requirements.txt

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
CMD ["runserver", "--noreload", "--insecure", "0.0.0.0:8000"]
