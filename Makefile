
## Lua-dev Dependencies Related
#
DEPS		:= lua5.3
# Lua-dev header PATHs
IDIR		:= /usr/include/lua5.3

## ATS Shared Library
#
NAME		:= ats
MAJOR		:= 0
MINOR		:= 9
VERSION		:= $(MAJOR).$(MINOR)

## ATS Installation PATHs
#
LDIR		:= /usr/local/lib/lua/5.3
BINDIR		:= /usr/local/sbin
CONFDIR		:= /etc
SYSTEMDIR	:= /lib/systemd/system

# Compiller Options
#
CC		:= gcc
# In future, -march=armv8-a+simd+crypto+crc -ansi -Wno-long-long
CFLAGS		:= -march=armv8-a+crc -mtune=cortex-a72.cortex-a53 -fPIC -Wall -Werror -O3 -g -I$(IDIR) # Compiler Flags, armv8-a+crc, tune for Big.Litle a72+a53
TEST_CFLAGS     := -march=armv8-a+crc -mtune=cortex-a72.cortex-a53 -O3 -g -I$(IDIR)

LDFLAGS		:= -shared -Wl,-soname,$(NAME).so.$(MAJOR) -l$(DEPS) # Linker Flags
TEST_LDFLAGS	:= -L/usr/lib/aarch64-linux-gnu -l$(DEPS) -lm -ldl

## ATS source/headers.. Code Related
#
ATS_SRCS	:= ats.c
ATS_HDRS	:= debug.h $(ATS_SRCS:.c=.h)
DEBUG_SRCS	:= debug.c
DEBUG_HDRS	:= $(DEBUG_SRCS:.c=.h)

TEST_SRCS	:= test.c
TEST_HDRS	:= $(ATS_HDRS)


# Objects
#OBJS		:= $(SRCS:.c=.o)
ATS_OBJS	:= $(ATS_SRCS:.c=.o)
DEBUG_OBJS	:= $(DEBUG_SRCS:.c=.o)

TEST_OBJS	:= $(TEST_SRCS:.c=.o)


## Binaries
#TEST
TEST_BIN	:= main


# project c/h/lua paths
SRCS_PATH	:= src
HDRS_PATH	:= include

# Project c/h relative paths.to/file.name
ATS_SRCS	:= $(addprefix $(SRCS_PATH)/,$(ATS_SRCS))
ATS_HDRS	:= $(addprefix $(HDRS_PATH)/,$(ATS_HDRS))
DEBUG_SRCS	:= $(addprefix $(SRCS_PATH)/,$(DEBUG_SRCS))
DEBUG_HDRS	:= $(addprefix $(HDRS_PATH)/,$(DEBUG_HDRS))

TEST_HDRS	:= $(addprefix $(HDRS_PATH)/,$(TEST_HDRS))


# Project systemd service relative path
SERVICE_PATH	:= systemd
# Project config service relative path
CONFIG_PATH	:= etc

.PHONY: all
all   : $(NAME).so.$(VERSION)

#$(OBJS): $(SRCS) $(HDRS)
#	$(CC) -c $(CFLAGS) -o $@ $<

$(DEBUG_OBJS): $(DEBUG_SRCS) $(DEBUG_HDRS)
	$(CC) -c $(CFLAGS) -o $@ $<

$(ATS_OBJS): $(ATS_SRCS) $(ATS_HDRS)
	$(CC) -c $(CFLAGS) -o $@ $<

#$(NAME).so.$(VERSION): $(OBJS)
$(NAME).so.$(VERSION): $(DEBUG_OBJS) $(ATS_OBJS)
	$(CC) $(LDFLAGS) -o $@ $^

## For testing and debugging ATS
#  Not needed for end ATS Binary
.PHONY: test
test  : $(TEST_BIN)

$(TEST_OBJS): $(TEST_SRCS) $(TEST_HDRS)
	$(CC) -c $(TEST_CFLAGS) -o $@ $<

$(TEST_BIN): $(DEBUG_OBJS) $(ATS_OBJS) $(TEST_OBJS)
	$(CC)  -o $@ $^ $(TEST_LDFLAGS)

.PHONY:	install
install:
	@if [ -L "/var/run/systemd/units/invocation:ats.service" ] || [ -L "/var/run/systemd/units/invocation:fanctl.service" ] || [ -L "/sys/fs/cgroup/systemd/system.slice/ats.service/tasks" ];then	\
		systemctl stop ats;																					\
	fi
	@echo "Install ATS Tool ..................: ats in ${BINDIR}"
	@install --preserve-timestamps --owner=root --group=root --mode=750 --target-directory=${BINDIR} ${SRCS_PATH}/ats
	@echo "Install ATS Config ................: ats.config in ${CONFDIR}"
	@install --preserve-timestamps --owner=root --group=root --mode=640 --target-directory=${CONFDIR} ${CONFIG_PATH}/ats.conf
	@echo "Install ATS Service File ..........: ats.service in ${SERVICE_PATH}"
	@install --preserve-timestamps --owner=root --group=root --mode=640 --target-directory=${SYSTEMDIR} ${SERVICE_PATH}/ats.service
	@if [ ! -d $(LDIR) ];then																								\
		mkdir -pv $(LDIR);																								\
	else																											\
		if [ -L ${LDIR}/${NAME}.so ] || [ -f ${LDIR}/${NAME}.so.?.? ];then																		\
			echo "Remove previous ATS Library .......: ${NAME}.so.* from ${LDIR}";																	\
			rm -f ${LDIR}/${NAME}.so*;																						\
		fi;																										\
		if [ -L ${LDIR_OLD}/fanctl.so ] || [ -f ${LDIR_OLD}/fanctl.so.?.? ] || [ -L ${LDIR_OLD}/sleep.so ] || [ -f ${LDIR_OLD}/sleep.so.?.? ] || [ -L ${LDIR_OLD}/ats.so ] || [ -f ${LDIR_OLD}/ats.so.?.? ];then	\
			echo "V0.1.6 or older detected, Removing it from System..";																		\
			systemctl stop fanctl 1> /dev/null 2>&1;																				\
			systemctl disable fanctl 1> /dev/null 2>&1 && journalctl -u fanctl --rotate 1> /dev/null 2>&1;														\
			sleep 1 && sync && journalctl -u fanctl --vacuum-time=1s 1> /dev/null 2>&1;																\
			find /lib/systemd/system /usr/sbin ${LDIR_OLD} \( -name fanctl -o -name fanctl.so\* -o -name fanctl.service -o -name sleep.so\* -o -name ats -o -name ats.so\* \) -exec rm -v {} \;			\
		;fi																										\
	fi
	@echo "Install new ATS Library ...........: ${NAME}.so.${VERSION} in ${LDIR}"
	@install --preserve-timestamps --owner=root --group=root --mode=640 --target-directory=${LDIR} ${NAME}.so.${VERSION}
	@echo "Create soname symLink .............: ${NAME}.so in ${LDIR}"
	@ln -s ${LDIR}/${NAME}.so.${VERSION} ${LDIR}/${NAME}.so
	@systemctl enable ats
	@echo "Starting ATS Service.."
	@systemctl start ats
	@sleep 1
	@systemctl status ats


.PHONY:	clean
clean:
	@if [ -f ${DEBUG_OBJS} ];then		\
		rm -v ${DEBUG_OBJS};		\
	fi
	@if [ -f ${ATS_OBJS} ];then		\
		rm -v ${ATS_OBJS};		\
	fi
	@if [ -f ${NAME}.so.${VERSION} ];then	\
		rm -v ${NAME}.so.${VERSION};	\
	fi
	@if [ -f ${TEST_OBJS} ];then		\
		rm -v ${TEST_OBJS};		\
	fi
	@if [ -f $(TEST_BIN) ];then		\
		rm -v $(TEST_BIN);		\
	fi

.PHONY: purge
purge:
	cd / && rm -rf ${OLDPWD}/ats
