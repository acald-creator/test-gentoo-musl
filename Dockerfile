FROM scratch

LABEL maintainer Antonette Caldwell

ENV RELEASE 20190504

ADD bb /tar

ADD http://distfiles.gentoo.org/experimental/amd64/musl/stage3-amd64-musl-vanilla-${RELEASE}.tar.bz2 /stage3.tar.bz2

ADD exclude /

RUN ["/tar", "xjpf", "stage3.tar.bz2", "-X", "exclude"]

RUN rm -f tar exclude stage3.tar.bz2

RUN sed -e 's/#rc_sys=""/rc_sys="lxc"/g' -i /etc/rc.conf

RUN echo 'UTC' > /etc/timezone

RUN touch /etc/init.d/functions.sh && \
    echo 'PYTHON_TARGETS="${PYTHON_TARGETS} python2_7 python3_6"' >> /etc/portage/make.conf && \
    echo 'PYTHON_SINGLE_TARGET="python3_6"' >> /etc/portage/make.conf && \
    echo 'RUBY_TARGETS="${RUBY_TARGETS} ruby 24 ruby25 ruby26"' >> /etc/portage/make.conf && \
    echo 'RUBY_SINGLE_TARGET="ruby25"' >> /etc/portage/make.conf && \
    echo 'MAKEOPTS="-j9"' >> /etc/portage/make.conf && \
    echo 'EMERGE_DEFAULT_OPTS="--ask=n --jobs=4"' >> /etc/portage/make.conf && \
    echo 'GENTOO_MIRRORS="http://gentoo.osuosl.org/ http://mirrors.evowise.com/gentoo/"' >> /etc/portage/make.conf

RUN mkdir -p /etc/portage/repos.conf

RUN ( \
    echo '[gentoo]'  && \
    echo 'location = /usr/portage' && \
    echo 'sync-type = rsync' && \
    echo 'sync-uri = rsync://rsync.us.gentoo.org/gentoo-portage/' && \
    echo 'auto-sync = yes' \
    )> /etc/portage/repos.conf/gentoo.conf


RUN mkdir -p /usr/portage/{distfiles,metadata,packages}
RUN chown -R portage:portage /usr/portage
RUN echo "masters = gentoo" > /usr/portage/metadata/layout.conf

RUN emerge-webrsync -q

# RUN eselect news read new

RUN env-update

CMD ["/bin/bash"]