#Harvester + Store run in the same container as the store is merely a thin layer on top of the former
FROM proycon/codemeta-harvester

ENV GIT_TERMINAL_PROMPT=0
RUN mkdir -p /var/www/static && cp /usr/lib/python3.*/site-packages/codemeta/resources/* /var/www/static/

#Install webserver and build dependencies
#Install codemeta-server, this also pulls in rdflib-endpoint and uvicorn (for which we need the build dependencies)
#remove build dependencies
RUN apk add bash nginx ca-certificates runit cronie rsync py3-dotenv apache2-utils gcc libc-dev make python3-dev ; \
pip install git+https://github.com/proycon/codemeta-server flask waitress ; \
apk del gcc libc-dev make python3-dev ; rm -Rf /root/.cache /usr/src
#manual build-tools download & build can be replace by download of official release

# Patch to set proper mimetype for logs
RUN sed -i 's/txt;/txt log;/' /etc/nginx/mime.types
#nginx level auth cred.  You could add more credentials @runtime with: htpasswd -b /etc/nginx/.htpasswd <usr> <psw> && nginx -s reload
RUN htpasswd -c -b /etc/nginx/.htpasswd user Let3gue33mypa33!
#copy additional static resources
COPY static/* /var/www/static/

ADD etc /etc
ADD bin /usr/bin/
RUN chmod +x /usr/bin/*.sh
ADD app.py /app.py
RUN chmod +x /app.py

#VOLUME ["/tool-store-data/codemeta.json"]
#EXPOSE nginx port

WORKDIR /
#Runs everything under /etc/service dir: i.e. nginx, cron, codemeta-server and harvest batch
ENTRYPOINT ["runsvdir","-P","/etc/service"]
