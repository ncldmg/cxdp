#include <stdio.h>
#include <unistd.h>
#include <getopt.h>
#include <bpf/bpf.h>
#include <bpf/libbpf.h>
// #include <xdp/libxdp.h>

int main(int argc, char **argv)
{
    int opt;
    while ((opt = getopt(argc, argv, "hv:o:")) != -1) {
        switch (opt) {
            case 'h':
                printf("Usage: %s [options]\n", argv[0]);
                printf("Options:\n");
                printf("  -h          Show this help message\n");
                printf("  -v          Show program version\n");
                printf("  -o <file>   Specify output file\n");
                return 0;
            case 'v':
                printf("%s version 1.0\n", argv[0]);
                return 0;
            case 'o':
                printf("Output file: %s\n", optarg);
                break;
            default:
                fprintf(stderr, "Usage: %s [-h] [-v] [-o <file>]\n", argv[0]);
                return 0;
        }
    }
    return 0;
}
