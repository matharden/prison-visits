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
	socat TCP4-LISTEN:1234,fork,bind=$$(ip -o -4 addr list docker0 | awk '{print $$4}' | cut -d/ -f1) UNIX-CLIENT:$$SSH_AUTH_SOCK & \
	echo $$! > .ssh-socat.pid

dockerbuild: ssh-socat.pid
	# This should be built outside of deployment pipeline
	docker build -t "ministryofjustice/prison-visits:onbuild" - < ./docker/Dockerfile.onbuild
	docker build -t "ministryofjustice/prison-visits:tmp" .
	kill $$(cat .ssh-socat.pid) && rm .ssh-socat.pid
	docker build -t "ministryofjustice/bundle-exec" - < ./docker/Dockerfile.bundle
	docker run --rm -v ./public/assets:/usr/src/app/public/assets "ministryofjustice/bundle-exec" rake assets:precompile
	#docker run --rm -v ./public/assets:/usr/src/app/public/assets "ministryofjustice/bundle-exec" rake assets:s3_upload
	# delete everything except for manifest json
	find ./public/assets -not -name "manifest-*.json" -type f rm -rf {} \;
	CID=$$(docker run --rm -v ./public/assets/:/usr/src/app/public/assets"ministryofjustice/prison-visits:tmp" tail -f /dev/null)
	docker commit $$CID "ministryofjustice/prison-visits:latest" && docker stop $$CID && docker rmi "ministryofjustice/prison-visits:tmp"

.PHONY: test test-i
