FROM ubuntu:22.04

# Stop interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive





########## SETUP START ##########

RUN apt-get update

# Basic installation and toolchain installation
RUN apt install -y sudo openssh-server git

# Install Apache and Python dependencies for Django hosting
RUN apt install -y apache2 libapache2-mod-wsgi-py3 python3 python3-pip

# Enable Apache WSGI module
RUN a2enmod wsgi

# Install Django
RUN pip3 install django

########## SETUP END ############





########## CREATE USER START ##########

RUN groupadd dev && \
    useradd -r -m -u 1001 -g dev -s /bin/bash dev && \
    echo 'export PATH="$HOME/bin:$PATH"' > /home/dev/.profile && \
    echo 'export EDITOR=vim' >> /home/dev/.profile && \
    chown dev:dev /home/dev/.profile

RUN echo 'root:dev123' | chpasswd
RUN echo 'dev:dev123' | chpasswd

RUN usermod -aG sudo dev

# Add the user to the sudoers file with NOPASSWD option
RUN echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev

# Ensure the permissions are correct
RUN chmod 0440 /etc/sudoers.d/dev

########## CREATE USER END ############





########## SSH setup : START ##########

USER root

RUN mkdir /var/run/sshd

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Expose the default SSH port (22)
EXPOSE 22
# Expose Apache web server port
EXPOSE 80
# Expose server development port
EXPOSE 8080

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]

########## SSH setup : END   ##########
