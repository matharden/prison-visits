clone: vendor/prison_staff_info

vendor/prison_staff_info:
	rm -Rf vendor/bundle/prison_staff_info
	git clone git@github.com:ministryofjustice/prison_staff_info.git vendor/bundle/prison_staff_info

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

dockerbuild: clone
	docker build -t "ministryofjustice/prison-visits:build" .
	docker build -t "ministryofjustice/bundle-exec" - < ./docker/Dockerfile.bundle
	docker run --rm -v $(shell pwd)/public/assets:/usr/src/app/public/assets -e RAILS_GROUPS=assets "ministryofjustice/bundle-exec" rake assets:precompile
	#docker run --rm -v ./public/assets:/usr/src/app/public/assets "ministryofjustice/bundle-exec" rake assets:s3_upload
	# delete everything except for manifest json
	CID=$$(docker run -d "ministryofjustice/prison-visits:build") && \
	cat ./public/assets/manifest-*.json | docker exec -i $$CID /bin/bash -c "/bin/cat > /usr/src/app/public/assets/manifest.json" && \
	docker commit $$CID "ministryofjustice/prison-visits:latest" && \
	docker stop $$CID && docker rm $$CID && docker rmi "ministryofjustice/prison-visits:build"

.PHONY: test test-i
