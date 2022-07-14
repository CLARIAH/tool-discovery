FROM debian:stable-slim

RUN apt-get update -qqy && apt-get install -qqy --no-install-recommends python3 python3-pip \ 
python3-yaml python3-ruamel.yaml python3-requests python3-matplotlib python3-markdown python3-rdflib python3-lxml python3-wheel \
git curl recode gawk pandoc && \
apt-get clean -qqy ; apt-get autoremove --yes ; rm -rf /var/lib/{apt,dpkg,cache,log}/

#dasel cython
RUN curl -sSLf "$(curl -sSLf https://api.github.com/repos/tomwright/dasel/releases/latest | grep browser_download_url | grep linux_amd64 | grep -v .gz | cut -d\" -f 4)" -L -o dasel && \
chmod +x dasel && \
mv ./dasel /usr/local/bin/dasel

ENV GIT_TERMINAL_PROMPT=0
#TODO: replace with stable version after codemetapy release --------------v
ARG CODEMETAPY_REPO_URL=https://github.com/xmichele/codemetapy.git
RUN python3 -m pip install  --no-cache-dir --prefix /usr Cython git+$CODEMETAPY_REPO_URL cffconvert

RUN git clone https://github.com/xmichele/codemeta-harvester.git && \
mv -f codemeta-harvester/codemeta-harvester /usr/bin/ && \
mv -f codemeta-harvester/*.sh /usr/bin/ && \
rm -rf codemeta-harvester

#WORKDIR /data
#ENTRYPOINT ["codemeta-harvester"]

#we can skip the first section If a debian codemeta-harverster image is available: FROM ..
#Harvester + Store run in the same container as the store is merely a thin layer on top of the former
#FROM proycon/codemeta-harvester
ENV GIT_TERMINAL_PROMPT=0
RUN mkdir -p /var/www/static && cp /usr/lib/python3.*/site-packages/codemeta/resources/* /var/www/static/

#Install webserver and build dependencies
#Install codemeta-server, this also pulls in rdflib-endpoint and uvicorn (for which we need the build dependencies)
#remove build dependencies
RUN apt-get install -qqy --no-install-recommends nginx ca-certificates runit cron rsync python3-dotenv apache2-utils gcc ; \
pip install --upgrade pip; pip install codemeta-server flask waitress ; \
apt-get remove -qqy gcc libc-dev make python3-dev ; \ 
apt-get clean -qqy ; apt-get autoremove --yes ; rm -rf /var/lib/{apt,dpkg,cache,log}/
#manual build-tools download & build can be replace by download of official release

# Patch to set proper mimetype for logs
RUN sed -i 's/txt;/txt log;/' /etc/nginx/mime.types
#nginx level auth cred.  You could add more credentials @runtime with: htpasswd -b /etc/nginx/.htpasswd <usr> <psw> && nginx -s reload
ARG nginx_user='user'
ARG nginx_pass='Gue33mypa33!'
RUN htpasswd -c -b /etc/nginx/.htpasswd $nginx_user $nginx_pass
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
