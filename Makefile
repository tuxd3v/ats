# include PATHs
IDIR      := /usr/include/lua5.3
# destination PATHs
LDIR      := /usr/lib/aarch64-linux-gnu/lua/5.3
SYSTEMDIR := /lib/systemd/system

NAME      := sleep
MAJOR     := 0
MINOR     := 1
VERSION   := $(MAJOR).$(MINOR)

DEPS      := lua5.3

CC        := gcc # Compiller
CFLAGS    := -fPIC -Wall -Werror -O3 -g -I$(IDIR) # Compiler Flags
LDFLAGS   := -shared -Wl,-soname,$(NAME).so.$(MAJOR) -l$(DEPS) # Linker Flags

# source code
SRCS      := sleep.c
SRCS_PATH := src/
SRCS      := $(addprefix $(SRCS_PATH),$(SRCS))
OBJS      := $(SRCS:.c=.o)

# systemd service
SERVICE_PATH := systemd

.PHONY: all
all   : $(NAME).so.$(VERSION)


$(SRCS): $(OBJS)
	$(CC) ${CFLAGS} -o $< $@


$(NAME).so.$(VERSION): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $<


.PHONY: install
install:
	cp -f $(SRCS_PATH)fanctl /usr/sbin/ && chmod 550 /usr/sbin/fanctl && chown root: /usr/sbin/fanctl
	cp -f $(SERVICE_PATH)/fanctl.service $(SYSTEMDIR)
	if [ ! -d $(LDIR) ];then \
        mkdir -p $(LDIR);   \
    fi
	mv $(NAME).so.$(VERSION) $(LDIR) && chown root: $(LDIR)/$(NAME).so.$(VERSION) && chmod 755 $(LDIR)/$(NAME).so.$(VERSION)
	if [ -L $(LDIR)/$(NAME).so ];then \
		rm -f $(LDIR)/$(NAME).so;     \
	fi
	ln -s $(LDIR)/$(NAME).so.$(VERSION) $(LDIR)/$(NAME).so


.PHONY: clean
clean:
	rm $(OBJS)


.PHONY: purge
purge:
	cd / && rm -rf /root/fanctl
