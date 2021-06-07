FROM ubuntu:20.04

WORKDIR /home/root

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get clean && apt-get update

RUN apt-get install -y git curl build-essential
RUN apt-get install -y libssl-dev zlib1g-dev

RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
RUN /root/.rbenv/plugins/ruby-build/install.sh
ENV PATH /root/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh # or /etc/profile
RUN echo 'eval "$(rbenv init -)"' >> .bashrc
ENV CONFIGURE_OPTS --disable-install-doc
RUN rbenv install 2.7.2
RUN rbenv global 2.7.2
RUN rbenv rehash

RUN ["/bin/bash", "-c", "source /home/root/.bashrc && gem update --system"]
RUN ["/bin/bash", "-c", "source /home/root/.bashrc && gem install bundler rake"]
RUN ["/bin/bash", "-c", "source /home/root/.bashrc && rbenv rehash"]

COPY . /home/root/xgt-ruby

RUN ["/bin/bash", "-c", "source /home/root/.bashrc && cd xgt-ruby && bundle"]

CMD ["/bin/bash", "-c", "source /home/root/.bashrc && cd xgt-ruby && bundle exec ./exe/xgt-wallet"]


