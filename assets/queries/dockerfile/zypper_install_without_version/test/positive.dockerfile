FROM opensuse/leap:15.2
RUN zypper install -y httpd && zypper clean
HEALTHCHECK CMD curl --fail http://localhost:3000 || exit 1
