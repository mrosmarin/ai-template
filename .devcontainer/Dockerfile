FROM mcr.microsoft.com/devcontainers/base:trixie



# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends tesseract-ocr libtesseract-dev poppler-utils libgl1-mesa-glx \
#     ffmpeg libsm6 libxext6 libmagic-dev libreoffice pandoc libsecret-1-dev graphviz xdg-utils

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends libnspr4 libnss3 libatk1.0-0t64 \
    libatk-bridge2.0-0t64 libdbus-1-3 libcups2t64 libxkbcommon0 libasound2t64 libgbm1 \
    libxcomposite1 libxdamage1 libxfixes3 libxrandr2 ibatspi2.0-0t64 bubblewrap socat \
    chromium-driver ffmpeg python3.13-venv  python3 python3-pip bind9-dnsutils

RUN apt-get -y update 
RUN apt-get -y upgrade

