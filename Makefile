
IDIR    :=/usr/include/lua5.3
LDIR    :=/usr/lib/x86_64-linux-gnu

NAME    := sleep
MAJOR   := 0
MINOR   := 1
VERSION := $(MAJOR).$(MINOR)

DEPS    := lua5.3

CC      := gcc # Compiller
CFLAGS  := -fPIC -Wall -Werror -O3 -g -I$(IDIR) # Compiler Flags
LDFLAGS := -shared -Wl,-soname,$(NAME).so.$(MAJOR) -l$(DEPS) # Linking Flags


SRCS    := sleep.c
OBJS    := $(SRCS:.c=.o)


.PHONY: all
all   : $(NAME).so.$(VERSION)

$(SRCS): $(OBJS)
	$(CC) ${CFLAGS} -o $@ $<

$(NAME).so.$(VERSION): $(NAME).o
	$(CC) $(LDFLAGS) -o $@ $<

.PHONY: install
install:
	cp fanctl /usr/sbin/ && chmod 550 /usr/sbin/fanctl && chown root: /usr/sbin/fanctl
	cp fanctl.service /lib/systemd/system
	mkdir -pv $(LDIR)/lua/5.3 && cp -v $(NAME).so.$(VERSION) $(LDIR)/lua/5.3 && chown root: $(LDIR)/lua/5.3/$(NAME).so.$(VERSION) && chmod 755 $(LDIR)/lua/5.3/$(NAME).so.$(VERSION) && ln -s $(LDIR)/lua/5.3/$(NAME).so.$(VERSION) $(LDIR)/lua/5.3/$(NAME).so

.PHONY: clean
clean:
	$(RM) *.o *.so*
