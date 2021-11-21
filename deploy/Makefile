.POSIX:

CURR_DIR = $(shell pwd)
LOCAL_IP ?= $(shell ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | awk '{print $1}')
SS_TOOLS_IMAGE ?= -

ifeq (-,$(SS_TOOLS_IMAGE))
  ANSIBLE_PLAYBOOK_CMD = ansible-playbook
  ANSIBLE_LINT_CMD = ansible-lint
else
  ANSIBLE_PLAYBOOK_CMD = docker run --rm -v ${CURR_DIR}:/data -w /data ${SS_TOOLS_IMAGE} ansible-playbook
  ANSIBLE_LINT_CMD = docker run --rm -v ${CURR_DIR}:/data -w /data ${SS_TOOLS_IMAGE} ansible-lint
endif

default: gen-files docker-start

gen-files:
	$(ANSIBLE_PLAYBOOK_CMD)  \
		--inventory hosts.yml \
		main.yml

docker-start:
	docker-compose up

docker-stop:
	docker-compose down

lint:
	$(ANSIBLE_LINT_CMD)  --project-dir .