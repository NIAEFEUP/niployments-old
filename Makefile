lint-shell-scripts:
	find . -type f -name '*.sh' | xargs shellcheck --external-sources

