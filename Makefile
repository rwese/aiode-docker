build: application.properties settings-private.properties Dockerfile
	docker-compose build

@PHONY: run
run:
	docker-compose up -d aiode