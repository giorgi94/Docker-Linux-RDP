FROM giok94/linux-rdp:debian-13.4-vnc

RUN userdel -r abc || true
RUN useradd -m -s /bin/bash worker && echo "worker:123" | chpasswd
RUN usermod -aG sudo worker

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y firefox-esr 7zip gimp inkscape

RUN apt-get clean && rm -rf /var/lib/apt/lists/*