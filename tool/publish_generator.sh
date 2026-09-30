#!/bin/sh
# Publishes dto_logger_generator from a copy outside this git repository.
# Inside it, the root .pubignore (which keeps the folder out of dto_logger)
# would hide every file. Publish dto_logger first: the generator depends on it.
#
#   tool/publish_generator.sh --dry-run
#   tool/publish_generator.sh
set -e
cd "$(dirname "$0")/../dto_logger_generator"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cp -R . "$tmp/dto_logger_generator"
cd "$tmp/dto_logger_generator"
rm -rf .dart_tool pubspec.lock pubspec_overrides.yaml
dart pub publish "$@"
