.PHONY: dependencies
dependencies:
	[ -z "$(dpkg -l \| grep clang)" ] && apt install clang && \
	[ -z "$(dpkg -l \| grep llvm)" ] && apt install llvm && \
	[ -z "$(dpkg -l \| grep libelf-dev)" ] && apt install libelf-dev && \
	[ -z "$(dpkg -l \| grep libbpf-dev)" ] && apt install libbpf-dev && \
	[ -z "$(dpkg -l \| grep libxdp-dev)" ] && apt install libxdp-dev && \
	[ -z "$(dpkg -l \| grep linux-tools-$(KERNEL_VERSION))" ] && apt install linux-tools-$(KERNEL_VERSION)

# clang compile flags
CC = clang
CFLAGS = -O2
DEBUG_FLAGS = -g
WARN_FLAGS = -Wall -Werror

# Directories
SRC_DIR = basic
OBJ_DIR = bin

# Source files
SRCS = $(wildcard $(SRC_DIR)/*.c)

# Object files and Executable files
OBJS = $(patsubst $(SRC_DIR)/%.c, $(OBJ_DIR)/%.o, $(SRCS))

# Executable files
EXES = $(patsubst $(SRC_DIR)/%.c, $(OBJ_DIR)/%, $(SRCS))

# Compile source files into object files and create executables
$(OBJ_DIR)/%: $(SRC_DIR)/%.c
	@mkdir -p $(OBJ_DIR)
	@if echo $< | grep -q '_kern'; then \
		$(CC) $(CFLAGS) $(WARN_FLAGS) -target bpf -o $@ -c $<; \
	else \
		$(CC) $(CFLAGS) $(WARN_FLAGS) -o $@ $<; \
	fi

# Clean up build files
clean:
	rm -f $(EXES) $(OBJS)

# Build debug
debug: CFLAGS += $(DEBUG_FLAGS)
debug: clean all

# Build release
all: clean $(EXES)

# Dump bpf object files
dump:
	@if [ -n "$(prefix)" ]; then \
		echo "Dumping files with prefix: $(prefix)"; \
		files=$$(find $(OBJ_DIR) -type f -name "$(prefix)*_kern*"); \
	else \
		echo "Dumping all files containing '_kern'"; \
		files=$$(find $(OBJ_DIR) -type f -name "*_kern*"); \
	fi; \
	for file in $$files; do \
		echo "Dumping: $$file"; \
		llvm-objdump -S $$file; \
	done
