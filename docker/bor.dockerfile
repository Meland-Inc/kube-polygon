FROM public.ecr.aws/o5c4r7f1/bor:v0.2.13

RUN apt-get install jq -y

COPY ./docker/bor.start.sh /usr/local/bin/bor.start.sh

ENTRYPOINT ["bash", "/usr/local/bin/bor.start.sh"]