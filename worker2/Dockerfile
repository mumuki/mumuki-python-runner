FROM python:2.7.16-alpine
MAINTAINER Franco Leonardo Bulgarelli

RUN wget https://github.com/xmlrunner/unittest-xml-reporting/archive/master.zip && \
    unzip master.zip && \
    cd unittest-xml-reporting-master && \
    python setup.py install

COPY rununittest /bin/rununittest
RUN chmod u+x /bin/rununittest
