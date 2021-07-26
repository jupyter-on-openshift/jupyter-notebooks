FROM docker.io/bitnami/python:3.7-prod

USER root

COPY . /tmp/src

ENV PATH="/opt/app-root/bin:${PATH}"

RUN rm -rf /tmp/src/.git* && \
    useradd unpriviliged_user -u 1001 -d /opt/app-root/src && \
    chown -R 1001 /tmp/src && \
    chgrp -R 0 /tmp/src && \
    mkdir -p /opt/app-root/etc/ && \
    mkdir -p /opt/app-root/bin/ && \
    mkdir /.kube && \
    chgrp -R 0 /.kube && \
    chown -R 1001 /opt/app-root/ && \
    chgrp -R 0 /opt/app-root/ && \
    chmod -R g+w /tmp/src && \
    rm -rf /tmp/scripts && \
    mv /tmp/src/.s2i/bin /tmp/scripts && \
    apt-get update && \
    apt-get install --no-install-recommends -y apache2 apache2-dev npm && \
    rm -rf /var/lib/apt/lists/*

USER 1001

LABEL io.k8s.description="S2I builder for custom Jupyter notebooks." \
      io.k8s.display-name="Jupyter Notebook" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,jupyter" \
      io.openshift.s2i.scripts-url="image:///opt/app-root/builder"

RUN /tmp/scripts/assemble

USER root

RUN  chgrp -R 0 /opt/app-root && chmod -R g+rwx /opt/app-root

USER 1001

CMD [ "/opt/app-root/builder/run" ]
