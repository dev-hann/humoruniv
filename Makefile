.PHONY: check analyze test coverage e2e smoke fix format clean

check:
	dart format --set-exit-if-changed .
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

format:
	dart format .

fix:
	dart fix --apply
	dart format .

clean:
	flutter clean
	flutter pub get
