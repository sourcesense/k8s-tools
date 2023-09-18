FROM alpine:3.15.1

RUN mkdir /data \
  && apk --no-cache add --update ca-certificates \
  && apk --no-cache add --update -t deps vim curl bash \
  && curl -L $(curl -L -s https://api.github.com/repos/fluxcd/flux2/releases/latest | grep -o -E "https://(.*)flux_(.*)_linux_amd64.tar.gz"|head -1) -o /tmp/flux.tgz \
  && curl -L https://get.helm.sh/$(curl -L -s https://api.github.com/repos/helm/helm/releases/latest | grep -o -E "https://(.*)helm-(.*)-linux-amd64.tar.gz"|head -1|rev|cut -d \/ -f 1|rev) -o /tmp/helm.tgz \
  && curl -L $(curl -L -s https://api.github.com/repos/derailed/k9s/releases/latest | grep -o -E "https://(.*)k9s_Linux_x86_64.tar.gz"|head -1) -o /tmp/k9s.tgz \
  && curl -L $(curl -L -s https://api.github.com/repos/direnv/direnv/releases/latest | grep -o -E "https://(.*)direnv.linux-amd64"|head -1) -o /tmp/direnv \
  && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" \
  && curl "https://download-installer.cdn.mozilla.net/pub/firefox/releases/117.0.1/win64/it/Firefox%20Setup%20117.0.1.exe" -o "/tmp/ffs.exe" \
  && curl "https://netix.dl.sourceforge.net/project/portableapps/Mozilla%20Firefox%2C%20Portable%20Ed./Mozilla%20Firefox%2C%20Portable%20Edition%20117.0.1/FirefoxPortable_117.0.1_Italian.paf.exe" -o "/tmp/ffp.exe" \
  && echo -e "#!/bin/bash\n" > /copy.sh \
  && echo -e "tar xzf /tmp/flux.tgz -C /data\n" >> /copy.sh \
  && echo -e "tar xvf /tmp/helm.tgz linux-amd64/helm --strip-components 1 -C /data > /dev/null\n" >> /copy.sh \
  && echo -e "tar xzf /tmp/k9s.tgz k9s -C /data\n" >> /copy.sh \
  && echo -e "cp /tmp/direnv /data\n" >> /copy.sh \
  && echo -e "cp /tmp/awscliv2.zip /data\n" >> /copy.sh \
  && echo -e "cp /tmp/ffs.exe /data\n" >> /copy.sh \
  && echo -e "cp /tmp/ffp.exe /data\n" >> /copy.sh \
  && echo -e "chmod +x /data/*\n" >> /copy.sh \
  && echo -e "echo \"available tools and versions:\"\n" >> /copy.sh \
  && echo -e "/data/k9s version\n" >> /copy.sh \
  && echo -e "echo -n \"helm: \";/data/helm version|cut -d\\\" -f2\n" >> /copy.sh \
  && echo -e "echo -n \"flux: \";/data/flux -v|cut -d\\\  -f 3\n" >> /copy.sh \
  && echo -e "echo -n \"direnv: \";/data/direnv version\n" >> /copy.sh \
  && echo -e "echo \"run as 'docker run --rm -v \\\$(pwd):/data ghcr.io/ecomind/k8s-tools' to extract tools in current dir\"" >> /copy.sh \
  && chmod +x /copy.sh

ENTRYPOINT [ "/copy.sh" ]
