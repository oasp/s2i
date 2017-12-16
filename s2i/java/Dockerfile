FROM centos:centos7
MAINTAINER Michael Kuehl <mkuehl@redhat.com>

# Image version
ENV VERSION 1.0
ENV RELEASE 1

# Installed components version
ENV JAVA_VERSION 1.8.0
ENV MAVEN_VERSION 3.5.2

# Packages to install
ENV INSTALL_PKGS "curl tar unzip bc which lsof make nss_wrapper bind-utils"
ENV DEVEL_PACKAGES "java-$JAVA_VERSION-openjdk java-$JAVA_VERSION-openjdk-devel"

# Image metadata
ENV NAME="oasp-java"
ENV MAINTAINER="mkuehl@redhat.com"
ENV VENDOR="Capgemini"
ENV SUMMARY="Base image for running OASP-based java applications"
ENV DESCRIPTION="Base image for running OASP-based java applications"
ENV TAGS="builder,s2i,java,oasp"

# Locations, $PATH etc.
ENV STI_SCRIPTS_PATH=/usr/local/sti
ENV MAVEN_HOME /usr/local/maven
ENV PATH=/opt/maven/bin/:$PATH

# User & User ID for the stuff inside the container
ENV USER_NAME=default USER_UID=1001

### Atomic/OpenShift Labels - https://github.com/projectatomic/ContainerApplicationGenericLabels
LABEL name="$NAME" \
      maintainer="$MAINTAINER" \
      vendor="$VENDOR" \
      version="$VERSION" \
      release="$RELEASE" \
      summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="DESCRIPTION" \
      io.k8s.display-name="$NAME" \
      io.openshift.tags="$TAGS"

# Install basic components

# Gain access to EPEL (Extra Packages for Enterprise Linux)
RUN yum install -y epel-release

# Clean the cache (see https://access.redhat.com/articles/1320623)
RUN rm -fr /var/cache/yum/* && yum clean all 

# Install OS packages
RUN yum install -y --enablerepo=centosplus $INSTALL_PKGS $DEVEL_PACKAGES && \
    rpm -V $INSTALL_PKGS $DEVEL_PACKAGES && \
    yum clean all && \
    rm -rf /var/cache/yum

# Install Maven
RUN (curl -0 http://www.eu.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | \
    tar -zx -C /usr/local) && \
    mv /usr/local/apache-maven-$MAVEN_VERSION /usr/local/maven && \
    ln -sf /usr/local/maven/bin/mvn /usr/local/bin/mvn

COPY s2i/java/contrib/settings.xml $MAVEN_HOME/conf
RUN chmod -R a+rwX $MAVEN_HOME/conf

# Install S2I scripts etc.
LABEL io.openshift.s2i.scripts-url=image:///usr/local/sti
COPY s2i/java/bin/ $STI_SCRIPTS_PATH

# In order to drop the root user, we have to make some directories world
# writeable as OpenShift default security model is to run the container under
# random UID.
RUN mkdir -p /opt/openshift && \
    mkdir -p /opt/app-root/source && \
    mkdir -p /opt/s2i/destination && \
    mkdir -p /opt/app-root/src && \
    chmod -R a+rwx /opt/openshift && \
    chmod -R a+rwx /opt/app-root/source && \
    chmod -R a+rwx /opt/s2i/destination && \
    chmod -R a+rwx /opt/app-root/src && \
    chown -R $USER_ID:0 /opt/openshift && \
    chown -R $USER_ID:0 /opt/app-root/source && \
    chown -R $USER_ID:0 /opt/s2i/destination && \
    chown -R $USER_ID:0 /opt/app-root/src

# The default user in the centos image
USER $USER_ID

# Set the default port for applications built using this image
EXPOSE 8080

# Set the default CMD for the image
CMD $STI_SCRIPTS_PATH/usage
