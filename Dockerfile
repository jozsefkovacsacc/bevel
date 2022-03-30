# USAGE: 
# docker build . -t baf-build
# docker run -v $(pwd):/home/blockchain-automation-framework/ baf-build

FROM ubuntu:16.04

# Create working directory
WORKDIR /home/

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl \
        unzip \
        build-essential \
        default-jre \
	    openssh-client \
        gcc \
        git \
        libdb-dev libleveldb-dev libsodium-dev zlib1g-dev libtinfo-dev \
        jq \
        python \
        python3-dev && \
        # python3-pip && \
        # pip3 install --no-cache --upgrade pip setuptools wheel && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://bootstrap.pypa.io/pip/3.5/get-pip.py | python3.5
RUN pip3 install --no-cache --upgrade pip setuptools wheel

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    apt-add-repository ppa:ansible/ansible && \
    apt-get update && \
    apt-get install -y ansible


RUN ansible --version
# RUN python3 -m pip install ansible==3.5.3
RUN pip install jmespath
RUN pip install openshift

RUN rm /etc/apt/apt.conf.d/docker-clean
# RUN mkdir /etc/ansible/
RUN /bin/echo -e "[ansible_provisioners:children]\nlocal\n[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Copy the provisional script to build container
COPY ./run.sh /home
COPY ./reset.sh /home
RUN chmod 755 /home/run.sh
RUN chmod 755 /home/reset.sh
ENV PATH=/root/bin:/root/.local/bin/:$PATH

# The mounted repo should contain a build folder with the following files
# 1) K8s config file as config
# 2) Network specific configuration file as network.yaml
# 3) Private key file which has write-access to the git repo

#path to mount the repo
VOLUME /home/blockchain-automation-framework/

CMD ["/home/run.sh"]
