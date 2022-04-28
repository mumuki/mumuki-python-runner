FROM python:3.7.3-alpine
MAINTAINER Franco Leonardo Bulgarelli

RUN wget https://github.com/xmlrunner/unittest-xml-reporting/archive/2.5.1.zip && \
    unzip 2.5.1.zip && \
    cd unittest-xml-reporting-2.5.1 && \
    python setup.py install

COPY rununittest /bin/rununittest

RUN adduser mumuki --home /home/mumuki -D
RUN chmod o-x -R /bin/*
RUN chmod o-x -R /sbin/
RUN chmod o-x -R /usr/bin/*
RUN chmod o-x -R /usr/sbin/
RUN chmod o-x /usr/local/bin/*

RUN chmod o+x /bin/rununittest
RUN chmod o+x /bin/touch
RUN chmod o+x /bin/cat
RUN chmod o+x /usr/bin/test
RUN chmod o+x /usr/local/bin/python

WORKDIR /home/mumuki/
USER mumuki