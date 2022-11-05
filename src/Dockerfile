FROM archlinux:base-devel

# Update and install packages
RUN pacman --noconfirm -Syu && \
    pacman --noconfirm --needed -S sudo git base-devel python-pip python-setuptools \
      x264 x265 ffmpeg4.4 tesseract-data-eng meson rust \
      vapoursynth ffms2 vapoursynth-plugin-lsmashsource

# Add user
RUN useradd -m yuuno && \
    echo "yuuno ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/build
USER yuuno
WORKDIR /home/yuuno

# Auto-fetch GPG keys and install paru
RUN mkdir .gnupg && \
    touch .gnupg/gpg.conf && \
    echo "keyserver-options auto-key-retrieve" > .gnupg/gpg.conf && \
    git clone https://aur.archlinux.org/paru-bin.git && \
    cd paru-bin && \
    makepkg --noconfirm --syncdeps --rmdeps --install --clean

# Install vapoursynth plugins (split for caching reasons)
RUN paru --noconfirm --needed -S vapoursynth-plugin-fmtconv-git vapoursynth-plugin-bm3d-git vapoursynth-plugin-mvsfunc-git
RUN paru --noconfirm --needed -S vapoursynth-plugin-descale-git vapoursynth-plugin-mvtools-git vapoursynth-plugin-cas-git
RUN paru --noconfirm --needed -S vapoursynth-plugin-mvtools-git vapoursynth-plugin-deblock-git vapoursynth-plugin-fluxsmooth-git
RUN paru --noconfirm --needed -S vapoursynth-plugin-eedi2-git vapoursynth-plugin-nnedi3_weights_bin
RUN paru --noconfirm --needed -S vapoursynth-plugin-nnedi3-git vapoursynth-plugin-nnedi3-git vapoursynth-plugin-znedi3-git 
RUN paru --noconfirm --needed -S vapoursynth-plugin-nnedi3_resample-git vapoursynth-plugin-g41fun-git
RUN paru --noconfirm --needed -S vapoursynth-plugin-vardefunc-git
RUN paru --noconfirm --needed -S vapoursynth-plugin-muvsfunc-git
RUN paru --noconfirm --needed -S vapoursynth-plugin-fvsfunc-git
RUN paru --noconfirm --needed -S vapoursynth-plugin-lvsfunc-git
RUN paru --noconfirm --needed -S vapoursynth-plugin-havsfunc-git

# Install yuuno
RUN pip install yuuno

# Configure Jupyter
ADD jupyter_notebook_config.py /home/yuuno/.jupyter/jupyter_notebook_config.py

WORKDIR /yuuno
ADD entrypoint.sh /usr/bin
RUN sudo chmod 755 /usr/bin/entrypoint.sh && sudo chown yuuno:yuuno -R /home/yuuno
ENV STARTUP_SCRIPT /yuuno/startup.sh
EXPOSE 8888
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
