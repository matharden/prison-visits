test:
	casperjs test tests

# Run tests with screen captures
test-i:
	rm -f tests/failure.png \
		; casperjs test tests --images=on \
		|| open tests/failure.png

test-ci:
	rm -f tests/failure.png \
		; casperjs test tests --images=on --no-colors --xunit=log.xml
socat-ssh:
	docker inspect --format="{{ .State.Running }}" socat-ssh || \
	docker run -d --name=socat-ssh --net=host -v $$(readlink -f $$SSH_AUTH_SOCK):/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent ministryofjustice/socat-ssh

dockerbuild: socat-ssh
	docker build -t "ministryofjustice/prison-visits:build" .
	# Stop the socat container after the application build is done
	docker stop socat-ssh && docker rm socat-ssh && \
	# would be awesome if we could either merge this in or separate into some parallel build
	docker build -t "ministryofjustice/bundle-exec" - < ./docker/Dockerfile.bundle && \
	docker run --rm -v $$(pwd)/public/assets:/usr/src/app/public/assets -e RAILS_GROUPS=assets "ministryofjustice/bundle-exec" rake assets:precompile
	#docker run --rm -v ./public/assets:/usr/src/app/public/assets "ministryofjustice/bundle-exec" rake assets:s3_upload
	CID=$$(docker run -d "ministryofjustice/prison-visits:build") && \
	cat ./public/assets/manifest-*.json | docker exec -i $$CID /bin/bash -c "/bin/cat > /usr/src/app/public/assets/manifest.json" && \
	docker commit $$CID "ministryofjustice/prison-visits:latest" && \
	docker stop $$CID && docker rm $$CID && docker rmi "ministryofjustice/prison-visits:build"

.PHONY: test test-i
