FROM public.ecr.aws/o5c4r7f1/heimdall:v0.2.4

RUN apt-get install -y systemctl

COPY ./docker/heimdalld.service /etc/systemd/system/heimdalld.service

COPY ./docker/heimdall.start.sh /usr/local/bin/heimdall.start.sh

ENTRYPOINT ["bash", "/usr/local/bin/heimdall.start.sh"]