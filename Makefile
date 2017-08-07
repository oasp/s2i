
IMAGE_NAME = oasp/s2i

build:
	docker build -t $(IMAGE_NAME) .

push:
	docker push $(IMAGE_NAME)

.PHONY: build
