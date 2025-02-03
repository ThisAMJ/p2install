# To use, put the following in SourceAutoRecord/config.mk
# -include "[path to]/p2install/.util/.sar-config.mk"

# CXX=i686-pc-linux-gnu-g++
CXX=g++
CXXFLAGS+=-O0 -g # -DNO_DEV_WATERMARK

COMMONDIR=$(dir $(realpath $(lastword $(filter %.mk, $(MAKEFILE_LIST)))))../p2c

binary=sar.so
src="$(PWD)/$(binary)"

KILL=1
COPY=0

all: install

install: sar.so
	@echo ""
	@echo Killing existing processes...
	@-killall -s 9 portal2_linux 2>/dev/null || true
	@-killall -s 9 TWTM_linux 2>/dev/null || true
	@-killall -s 9 beginnersguide.bin 2>/dev/null || true
	@-killall -s 9 gameoverlayui 2>/dev/null || true
	@if [ "$(COPY)" == "1" ]; then \
		echo Copying $(binary) to common directory...; \
		cp -f "$(src)" "$(COMMONDIR)/$(binary)"; \
	else \
		echo Moving $(binary) to common directory.; \
		mv -f "$(src)" "$(COMMONDIR)/$(binary)"; \
	fi
	@appid=620; \
	if [[ -f "$(COMMONDIR)/../.util/.sar-appid.txt" ]]; then \
		appid=$(shell cat "$(COMMONDIR)/../.util/.sar-appid.txt"); \
	fi; \
	touch "$(COMMONDIR)/../.util/.sar-build.txt"; \
	echo SAR built and installed!; \
	if [ "$(KILL)" == "1" ]; then \
		echo "Restarting the game (appid $$appid)..."; \
		steam steam://rungameid/$$appid; \
	else \
		echo "Done!"; \
	fi
	@echo ""
