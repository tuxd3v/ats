# include PATHs
IDIR		:= /usr/include/lua5.3
# destination PATHs
TRIPLET		:= $(shell gcc -dumpmachine)
#LDIR		:= /usr/lib/$(TRIPLET)/lua/5.3
LDIR		:= /usr/local/lib/lua/5.3
BINDIR		:= /usr/local/sbin
SYSTEMDIR	:= /lib/systemd/system

# Shared Library
NAME		:= ats
MAJOR		:= 0
MINOR		:= 2
VERSION		:= $(MAJOR).$(MINOR)

DEPS		:= lua5.3

CC		:= gcc # Compiller
CFLAGS		:= -c -march=armv8-a+simd+crypto+crc -mtune=cortex-a72.cortex-a53 -fPIC -Wall -Werror -O3 -g -I$(IDIR) # Compiler Flags, armv8-a+crc, tune for Big.Litle a72+a53
LDFLAGS	:= -shared -Wl,-soname,$(NAME).so.$(MAJOR) -l$(DEPS) # Linker Flags

# source code
SRCS		:= ats.c
SRCS_PATH	:= src/
SRCS		:= $(addprefix $(SRCS_PATH),$(SRCS))
OBJS		:= $(SRCS:.c=.o)

# systemd service
SERVICE_PATH	:= systemd

.PHONY: all
all   : $(NAME).so.$(VERSION)


$(OBJS): $(SRCS)
	$(CC) ${CFLAGS} -o $@ $<


$(NAME).so.$(VERSION): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $<


.PHONY:	install
install:
	@if [ -L "/var/run/systemd/units/invocation:ats.service" ];then		\
		systemctl stop ats;						\
	fi
	@echo "Install ATS Tool ..................: ats in ${BINDIR}"
	@install --preserve-timestamps --owner=root --group=root --mode=750 --target-directory=$(BINDIR) $(SRCS_PATH)ats
	@echo "Install ATS Service File ..........: ats.service in ${SERVICE_PATH}"
	@install --preserve-timestamps --owner=root --group=root --mode=640 --target-directory=$(SYSTEMDIR) $(SERVICE_PATH)/ats.service
	@if [ ! -d $(LDIR) ];then																								\
		mkdir -pv $(LDIR);																								\
	else																											\
		if [ -L $(LDIR)/$(NAME).so ] || [ -f $(LDIR)/$(NAME).so.?.? ];then																		\
			echo "Remove previous ATS Library .......: ${NAME}.so.* from ${LDIR}";																	\
			rm -f $(LDIR)/$(NAME).so*;																						\
		fi;																										\
		if [ -L $(LDIR)/fanctl.so ] || [ -f $(LDIR)/fanctl.so.?.? ] || [ -L $(LDIR)/sleep.so ] || [ -f $(LDIR)/sleep.so.?.? ] || [ -L $(LDIR)/ats.so ] || [ -f $(LDIR)/ats.so.?.? ];then				\
			echo "V0.1.6 or older detected, Removing it from System..";																		\
			systemctl stop fanctl 1> /dev/null 2>&1;																				\
			systemctl disable fanctl 1> /dev/null 2>&1 && journalctl -u fanctl --rotate 1> /dev/null 2>&1;														\
			sleep 1 && sync && journalctl -u fanctl --vacuum-time=1s 1> /dev/null 2>&1;																\
			find /lib/systemd/system /usr/sbin /usr/lib/${TRIPLET}/lua/5.3 \( -name fanctl -o -name fanctl.so\* -o -name fanctl.service -o -name sleep.so\* -o -name ats -o -name ats.so\* \) -exec rm -v {} \;	\
		;fi																										\
	fi
	@echo "Install new ATS Library ...........: ${NAME}.so.${VERSION} in ${LDIR}"
	@install --preserve-timestamps --owner=root --group=root --mode=640 --target-directory=$(LDIR) $(NAME).so.$(VERSION)
	@echo "Create soname symLink .............: ${NAME}.so in ${LDIR}"
	@ln -s $(LDIR)/$(NAME).so.$(VERSION) $(LDIR)/$(NAME).so
	@systemctl enable ats
	@echo "Starting ATS Service.."
	@systemctl start ats
	@sleep 1
	@systemctl status ats


.PHONY:	clean
clean:
	rm $(OBJS)
	rm $(NAME).so.$(VERSION)

.PHONY: purge
purge:
	cd / && rm -rf ${OLDPWD}/ats
