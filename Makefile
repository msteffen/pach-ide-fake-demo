export DOCKER_BUILDKIT=1

build:
	docker build -t demo_git_jupyter -f Notebook.Dockerfile .

run: build
	docker run demo_git_jupyter
