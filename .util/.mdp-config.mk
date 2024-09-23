# -include "[path to]/p2install/.util/.mdp-config.mk"

# dependency:
#  arch linux: clang mingw-w64-gcc
#  debian: clang gcc-mingw-w64

CCWIN=x86_64-w64-mingw32-gcc
CFLAGS=-Wall -Werror

SRCS=$(shell find $(SRCDIR) -name '*.c')
OBJS=$(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o, $(SRCS))
DEPS=$(OBJS:%.o=%.d)

all: mdp mdp.exe

# use different compilation flags for windows
mdp.exe: $(OBJS:$(OBJDIR)/%.o=$(OBJDIR)/win-%.o)
	$(CCWIN) $^ $(LDFLAGS) -o $@

$(OBJDIR)/win-%.o: $(SRCDIR)/%.c
	@mkdir -p $(dir $@)
	$(CCWIN) $(CFLAGS) -D__USE_MINGW_ANSI_STDIO -MMD -c $< -o $@
