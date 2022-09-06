FROM python:3.7.3
MAINTAINER Franco Leonardo Bulgarelli

RUN wget https://github.com/xmlrunner/unittest-xml-reporting/archive/2.5.1.zip && \
    unzip 2.5.1.zip && \
    cd unittest-xml-reporting-2.5.1 && \
    python setup.py install

RUN pip install pandas==1.3.3 \
                matplotlib==3.5.3

COPY rununittest /bin/rununittest
RUN chmod u+x /bin/rununittest
