NS ?= accenturecifr
VERSION ?= latest

IMAGE_NAME ?= plaso
CONTAINER_NAME ?= plaso
CONTAINER_INSTANCE ?= default
VOLUMES=-v ~/Downloads/:/data:cached -v /tmp:/output:cached
.PHONY: build push shell run start stop rm release

build: Dockerfile
	docker build -t $(NS)/$(IMAGE_NAME):$(VERSION) -f Dockerfile .

hub-build: Dockerfile
	curl -H "Content-Type: application/json" --data '{"build": true}' -X POST ${hub_url}

git-push:
	git commit && \
		git push

push:
	docker push $(NS)/$(IMAGE_NAME):$(VERSION)

shell:
	docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION) /bin/bash

shell-root:
	docker run -u root --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION) /bin/bash

run:
	docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)

start:
	docker run -d --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)


stop:
	docker stop $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

rm:
	docker rm $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

release: build
	make push -e VERSION=$(VERSION)

test: cdqr psort-analysis psort  psort-csv pinfo

log2timeline:
	docker run --rm ${VOLUMES} ${NS}/${IMAGE_NAME}  log2timeline.py \
		--artifact_definitions /usr/share/artifacts \
		--data /usr/share/plaso \
		--parsers all \
		--partitions all \
		--vss_stores all \
		--hashers md5 \
		--logfile /output/log2timeline/WinXP2.plaso.log \
		--status_view none \
		-q  \
		/output/log2timeline/WinXP2.pb /data/WinXP2.E01

psort-analysis:
	docker run --rm ${VOLUMES} ${NS}/${IMAGE_NAME}  psort.py \
		-o null \
		--data /usr/share/plaso \
		--tagging-file /usr/share/plaso/tag_windows.txt  \
		--analysis tagging,sessionize,windows_services \
		/output/log2timeline/WinXP2.E01.plaso

psort:
	docker run --rm ${VOLUMES} ${NS}/${IMAGE_NAME}  psort.py \
		-o json_line \
		-w /output/log2timeline/WinXP2.json  \
		/output/log2timeline/WinXP2.E01.plaso \
		--logfile /output/log2timeline/WinXP2.psort.log \
		-q \
		--status_view none

psort-csv:
	docker run --rm ${VOLUMES} ${NS}/${IMAGE_NAME} psort.py \
		-o l2tcsv \
		-w /output/log2timeline/WinXP2.csv  \
		/output/log2timeline/WinXP2.plaso \
		--logfile /output/log2timeline/WinXP2.psort-csv.log \
		--status_view none \
		-q

pinfo:
	docker run --rm ${VOLUMES} ${NS}/${IMAGE_NAME} pinfo.py \
		--output_format json \
		-w /output/log2timeline/WinXP2-pinfo.json  \
		/output/log2timeline/WinXP2.plaso

cdqr:
	docker run --rm -it ${VOLUMES} ${NS}/${IMAGE_NAME} cdqr.py  \
		--max_cpu \
		-p datt \
		--export /data/WinXP2.E01 \
		/output/log2timeline/

default: build
