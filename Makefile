.PHONY: test lint docgen

test:
	echo "===> Testing"
	nvim --headless --noplugin -u scripts/minimal.vim \
        -c "PlenaryBustedDirectory lua/tests/ {minimal_init = 'scripts/minimal.vim'}"
