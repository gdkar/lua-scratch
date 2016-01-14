#include <x86intrin.h>
#include <stdint.h>
#include <pthread.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
static double cached_cpufreq = 0;
static pthread_once_t cpufreq_once = PTHREAD_ONCE_INIT;
void cpufreq_init(void)
{
    FILE *fp = fopen("/proc/cpuinfo","r");
    char buffer[4096];
    ssize_t bytes_read = 0;
    size_t bytes_fill = 0;
    char  *match      = NULL;
    const char *needle = "cpu MHz";
    size_t needle_length = strlen(needle);
    double cpufreq = 0;
    do{
        bytes_read = fread( buffer + bytes_fill, 1, sizeof(buffer) - bytes_fill,fp);
        buffer[bytes_read + bytes_fill] = '\0';
        if((match = strstr(buffer, needle)))
        {
            sscanf(match,"cpu MHz : %lf",&cpufreq);
        }
        if ( bytes_read + bytes_fill > needle_length )
        {
            memmove(buffer,&buffer[bytes_read + bytes_fill - needle_length], needle_length);
            bytes_fill = needle_length;
        }
        else bytes_fill += bytes_read;
    }while(!cpufreq && bytes_read);
    cpufreq *= 1e6;
    fclose(fp);
    if ( cpufreq )
        cached_cpufreq = cpufreq;
}
double cpufreq(void)
{
    pthread_once(&cpufreq_once, &cpufreq_init);
    return cached_cpufreq;
}
int64_t rdtsc(void)
{
    return __rdtsc();
}
double getclock(void)
{
    return __rdtsc() / cpufreq();
}
