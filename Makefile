.PHONY: check analyze test coverage e2e smoke fix clean

check:
	flutter analyze --no-fatal-infos --no-fatal-warnings
	flutter test

analyze:
	flutter analyze --no-fatal-infos --no-fatal-warnings

test:
	flutter test

coverage:
	flutter test --coverage
	@echo "Coverage report: coverage/lcov.info"

e2e:
	flutter test integration_test/app_e2e_test.dart

smoke:
	flutter test integration_test/app_smoke_test.dart

fix:
	dart fix --apply

clean:
	flutter clean
	flutter pub get
