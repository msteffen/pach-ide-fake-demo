export DOCKER_BUILDKIT=1

build:
	docker build -t demo_git_jupyter -f Notebook.Dockerfile .

run: build
	docker run -p 30888:8888 demo_git_jupyter

debug: build
	docker run -ti -p 30888:8888 demo_git_jupyter /bin/sh
