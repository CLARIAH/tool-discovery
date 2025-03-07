docker-dev:
	docker build --no-cache -t clariah-tool-discovery:dev --build-arg BASETAG=dev --build-arg CODEMETASERVER_VERSION=git+https://github.com/proycon/codemeta-server.git@master --build-arg CODEMETA2HTML_VERSION=git+https://github.com/proycon/codemeta2html.git@master .

docker:
	docker build -t clariah-tool-discovery:latest .

run-minimal-dev:
	mkdir -p /tmp/tool-store-data
	[ -e token ] || false # store your github token in a file named 'token'
	docker run --env-file=local-dev.env --env GITHUB_TOKEN="$(shell cat token)" --env SOURCE_REGISTRY_BRANCH=minimal-test -v /tmp/tool-store-data:/tool-store-data -p 8080:80 clariah-tool-discovery:dev

run-dev:
	mkdir -p /tmp/tool-store-data
	[ -e token ] || false # store your github token in a file named 'token'
	docker run --env-file=local-dev.env --env GITHUB_TOKEN="$(shell cat token)" -v /tmp/tool-store-data:/tool-store-data -p 8080:80 clariah-tool-discovery:dev

run:
	mkdir -p /tmp/tool-store-store
	[ -e token ] || false # store your github token in a file named 'token'
	docker run --env-file=local-dev.env --env GITHUB_TOKEN="$(shell cat token)" -v /tmp/tool-store-data:/tool-store-data -p 8080:80 clariah-tool-discovery:latest

push-dev:
	#https://tools.dev.clariah.nl
	docker tag clariah-tool-discovery:dev registry.diginfra.net/mvg/clariah-tool-discovery:dev
	docker push registry.diginfra.net/mvg/clariah-tool-discovery:dev

push-production:
	#https://tools.clariah.nl
	docker tag clariah-tool-discovery:latest registry.diginfra.net/mvg/clariah-tool-discovery:latest
	docker push registry.diginfra.net/mvg/clariah-tool-discovery:latest
