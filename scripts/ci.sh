#!/usr/bin/env bash
#
nixfmt --check .
find . -name "*.sh" -print0 | xargs -0 shellcheck --format=gcc
ruff check .
