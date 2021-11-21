.POSIX:

TAG = siliconsheep/tools

default: build

build:
	docker build . --tag ${TAG}

run:
	docker run \
		--rm \
		--interactive \
		--tty \
		--env "TERM=${TERM}" \
		${TAG}

update-env:
	@echo eval export SS_TOOLS_IMAGE=${TAG}
