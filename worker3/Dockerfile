FROM python:3.7.3-alpine
MAINTAINER Franco Leonardo Bulgarelli

RUN wget https://github.com/xmlrunner/unittest-xml-reporting/archive/2.5.1.zip && \
    unzip 2.5.1.zip && \
    cd unittest-xml-reporting-2.5.1 && \
    python setup.py install

COPY rununittest /bin/rununittest
RUN chmod u+x /bin/rununittest
