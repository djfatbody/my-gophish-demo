FROM ubuntu:22.04

RUN apt-get update \
    && apt-get install -y \
    git \
    wget \
    python3 \
    python3-pip \
    sqlite3 \
    supervisor \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and install Gophish
WORKDIR /usr/src/gophish
RUN wget -O gophish.zip https://github.com/kgretzky/gophish/releases/download/v0.12.1/gophish-v0.12.1-linux-64bit.zip
RUN unzip gophish.zip
RUN rm gophish.zip
RUN chmod +x gophish

# Expose the admin port to the host
RUN sed -i 's/127.0.0.1/0.0.0.0/g' config.json

WORKDIR /usr/src/gophish-demo/
COPY . .
RUN mv docker/* .
RUN chmod +x run_demo.sh

# Install depenedencies
RUN pip3 install --no-cache-dir --root-user-action=ignore aiosmtpd astroid atpublic certifi chardet Faker flake8 gophish idna isort lazy-object-proxy mccabe pycodestyle pyflakes pylint python-dateutil requests six text-unidecode typed-ast urllib3 wrapt yapf

# Setup the supervisor
RUN mv supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 3333 8080 8443 80

CMD ["/usr/bin/supervisord"]
