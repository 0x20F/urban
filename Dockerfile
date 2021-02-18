# Should have ZSH installed along with Quality of life 
# extensions to make life easier. As well as some sane
# defaults for different things.
FROM archlinux:latest


# Update the distro
RUN pacman-db-upgrade
RUN pacman -Syyu --noconfirm

# Turn on pacman colors and man pages
RUN sed '/^#Color/ s/^#//' -i /etc/pacman.conf
RUN sed -e '/usr\/share\/man\/\*/ s/^#*/#/' -i /etc/pacman.conf

# Install good to have things
RUN pacman -Syu --noconfirm \
        git \
        base-devel \
        go \ 
        wget \
        exa \
        bat \
        vim \
        tzdata \ 
        iproute2 \
        iputils \
        unzip \
        openssh \
        openvpn \
        psmisc \ 
	    man-db \
	    man-pages \
	    net-tools \
	    netcat \
	    tmux \
	    ruby \
	    zsh \
        samba \
        nfs-utils


# Setup locale
RUN locale-gen en_US.UTF-8

# Set timezone
RUN cat /usr/share/zoneinfo/Europe/Stockholm > /etc/localtime


# User to use instead of root
ENV ME snowwhite


# Add a non-root user, and give them some permissions
RUN groupadd -r $ME && \
    useradd -r -g $ME $ME && \
    mkdir /home/$ME && \
    chmod a+rwx /home/$ME && \
    passwd -d $ME && \
    printf "$ME ALL=(ALL) ALL\n" | tee -a /etc/sudoers


# Give builder rights to its own home
RUN chown -R $ME /home/$ME


# Switch away from root
USER ${ME}


# Install something to get packages from AUR
WORKDIR /home/$ME
RUN git clone https://aur.archlinux.org/yay.git
RUN cd yay && makepkg -si --noconfirm


# Terminal colors
ENV TERM xterm-256color
# Run the installation script for oh-my-zsh
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true


# Clone configs
RUN git clone https://github.com/0x20F/dotfiles.git ~/dotfiles
RUN cp ~/dotfiles/.zsh/.zshrc ~/.zshrc
RUN cp ~/dotfiles/.tmux.conf ~/.tmux.conf

# Clone tmux themes (theme from here is sourced in tmux config)
RUN git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux-themepack



# Download some useful plugins
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
RUN git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions



# Start home
WORKDIR /home/$ME


# Run zsh instead of bash
CMD [ "/bin/zsh" ]



