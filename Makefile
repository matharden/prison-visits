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
	docker build -t "gyre007/prison-visits:onbuild" - < ./docker/Dockerfile.onbuild
	docker build -t "gyre007/prison-visits:v1" .
	kill $$(cat .ssh-socat.pid) && rm .ssh-socat.pid

.PHONY: test test-i
