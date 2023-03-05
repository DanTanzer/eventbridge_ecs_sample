FROM amazonlinux:2

WORKDIR /usr/src/app

RUN yum install -y python3 && \
    yum install -y python3-pip

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r ./requirements.txt

COPY ./logging_ecs_service .

CMD [ "python3", "./app.py" ]