clone: vendor/prison_staff_info
vendor/prison_staff_info:
	rm -Rf vendor/prison_staff_info
	git clone git@github.com:ministryofjustice/prison_staff_info.git vendor/prison_staff_info

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

.PHONY: test test-i
