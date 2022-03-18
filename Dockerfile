FROM alpine:3.15.1

RUN mkdir /data \
  && apk --no-cache add --update ca-certificates \
  && apk --no-cache add --update -t deps vim curl bash \
  && curl -L $(curl -L -s https://api.github.com/repos/fluxcd/flux2/releases/latest | grep -o -E "https://(.*)flux_(.*)_linux_amd64.tar.gz"|head -1) -o /tmp/flux.tgz \
  && curl -L https://get.helm.sh/$(curl -L -s https://api.github.com/repos/helm/helm/releases/latest | grep -o -E "https://(.*)helm-(.*)-linux-amd64.tar.gz"|head -1|rev|cut -d \/ -f 1|rev) -o /tmp/helm.tgz \
  && curl -L $(curl -L -s https://api.github.com/repos/derailed/k9s/releases/latest | grep -o -E "https://(.*)k9s_Linux_x86_64.tar.gz"|head -1) -o /tmp/k9s.tgz \
  && echo -e "#!/bin/bash\n" > /copy.sh \
  && echo -e "tar xzf /tmp/flux.tgz -C /data\n" >> /copy.sh \
  && echo -e "tar xvf /tmp/helm.tgz linux-amd64/helm --strip-components 1 -C /data > /dev/null\n" >> /copy.sh \
  && echo -e "tar xzf /tmp/k9s.tgz k9s -C /data\n" >> /copy.sh \
  && echo -e "chmod +x /data/*\n" >> /copy.sh \
  && echo -e "echo \"available tools and versions:\"\n" >> /copy.sh \
  && echo -e "/data/k9s version\n" >> /copy.sh \
  && echo -e "/data/helm version\n" >> /copy.sh \
  && echo -e "/data/flux -v\n" >> /copy.sh \
  && echo -e "echo \"run as 'docker run --rm -v \\\$(pwd):/data ghcr.io/ecomind/k8s-tools' to extract tools in current dir\"" >> /copy.sh \
  && chmod +x /copy.sh

ENTRYPOINT [ "/copy.sh" ]
