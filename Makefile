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

ssh-socat.pid:
	if [ -e /tmp/ssh-socat.pid ]; then kill $$(cat /tmp/ssh-socat.pid); fi
	socat TCP4-LISTEN:1234,fork,bind=$$(ip -o -4 addr list docker0 | awk '{print $$4}' | cut -d/ -f1) UNIX-CLIENT:$$SSH_AUTH_SOCK & \
	echo $$! > /tmp/ssh-socat.pid

dockerbuild: ssh-socat.pid
	# This should be built outside of deployment pipeline
	docker build -t "ministryofjustice/ruby-app:onbuild" - < ./docker/Dockerfile.onbuild
	docker build -t "ministryofjustice/prison-visits:build" .
	kill $$(cat /tmp/ssh-socat.pid) && rm /tmp/ssh-socat.pid
	docker build -t "ministryofjustice/bundle-exec" - < ./docker/Dockerfile.bundle
	docker run --rm -v $(shell pwd)/public/assets:/usr/src/app/public/assets -e RAILS_GROUPS=assets "ministryofjustice/bundle-exec" rake assets:precompile
	#docker run --rm -v ./public/assets:/usr/src/app/public/assets "ministryofjustice/bundle-exec" rake assets:s3_upload
	# delete everything except for manifest json
	# this is ok as runit will keep the unicorn up so we won't override the CMD instruction
	CID=$$(docker run -d "ministryofjustice/prison-visits:build") && \
	cat ./public/assets/manifest-*.json | docker exec -i $$CID /bin/bash -c "/bin/cat > /usr/src/app/public/assets/manifest.json" && \
	docker commit $$CID "ministryofjustice/prison-visits:latest" && \
	docker stop $$CID && docker rm $$CID && docker rmi "ministryofjustice/prison-visits:build"

.PHONY: test test-i ssh-socat.pid
