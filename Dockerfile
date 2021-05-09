### Package deps, for build and devel phases
#FROM whosgonna/dancer2-tt-gazelle:build AS build
FROM whosgonna/perl-build:latest AS burnnote-build

## Install all of the perl modules:
USER root
RUN apk add --no-cache mariadb-dev
USER perl
COPY cpanfile* /home/perl/
RUN cpm install --workers 16 --without-develop --without-configure --with-suggests \
    && carton install --without 'develop,configure'


### Final phase: the runtime version - notice that we start from the base perl image.
FROM whosgonna/perl-runtime:latest

### Copy the maria DB libraries.  Note that this copies symlinks as actual files,
### so it's twice as large as it needs to be (~36MB instead of 18MB).
USER root
COPY --from=burnnote-build /usr/lib/libmaria* /usr/lib/
COPY --from=burnnote-build /usr/lib/mariadb/plugin /usr/lib/mariadb/plugin

WORKDIR /home/perl
USER perl

## Set any environmental variables here.
ENV PLACK_ENV=docker_production


## Copy the actual application files:
COPY --chown=perl ./ ./


## Copy the local directory with the perl libraries and the cpan files from the
## ephemeral build image.
COPY --from=burnnote-build --chown=perl /home/perl/local/ /home/perl/local/
COPY --from=burnnote-build --chown=perl /home/perl/cpanfile* /home/perl/


CMD  carton exec plackup -p  5000 --server Gazelle /home/perl/bin/app.psgi
#CMD /bin/sh
