
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>
//#include <stdatomic.h>

typedef struct Vec {
    size_t  item_size;
    size_t  fill;
    size_t  size;
    void   *data;
} Vec;


int  vec_create(Vec *v, size_t item_size, size_t initial_size);
void vec_destroy(Vec *v);
int  vec_reserve(Vec *v, size_t n);
int  vec_resize (Vec *v, size_t n);

typedef struct FList {
    int     size;
    int     fill;
    int     head;
    int    *data;
} FList;

int  flist_create(FList *v, int initial_size);
void flist_destroy(FList*v);
int  flist_get(FList *v);
int  flist_put(FList*v, int i);

int vec_create(Vec *v, size_t item_size, size_t initial_size)
{
    v->item_size = item_size;
    v->fill      = 0;
    v->size      = initial_size;
    if ( initial_size != 0) {
        v->data = malloc(initial_size * item_size);
        if(!v->data)
            return -errno;
    } else {
        v->data = NULL;
    }
    return 0;
}
void vec_destroy(Vec *v)
{
    free(v->data);
    v->data = NULL;
    v->size = 0;
    v->fill = 0;
}

int vec_reserve(Vec *v, size_t n)
{
    if ( n <= v->size )
        return 0;
    if(v->data) {
        void *data = realloc(v->data, n * v->item_size);
        if ( data ) {
            v->data = data;
            v->size = n;
            return 0;
        }
    } else {
        v->data = malloc( n * v->item_size );
        if(v->data) {
            v->size = n;
            return 0;
        }
    }
    return -errno;
}

int vec_resize(Vec *v, size_t n)
{
    if( n > v->size) {
        size_t size = 1 + (v->size * 3) / 2;
        if(size < n) size  = n;
        int r = vec_reserve(v, size);
        if( r < 0 )
            return r;
    }
    if ( n > v->fill ) {
        memset(v->data + v->fill * v->item_size, 0, ( n - v->fill ) * v->item_size);
    }
    v->fill = n;
    return 0;
}

int flist_create(FList *v, int initial_size)
{
    v->size      = initial_size;
    v->head      = -1;
    v->fill      =  0;
    if ( initial_size != 0) {
        v->data = malloc(initial_size *sizeof(*v->data));
        memset(v->data,0,initial_size * sizeof(*v->data));
        if(!v->data)
            return -errno;
//        for(int i = 1; i < initial_size - 1; i++) {
//            v->data[i-1] = i+1;
//        }
    } else {
        v->data = NULL;
    }
    return 0;
}
void flist_destroy(FList *v)
{
    free(v->data);
    v->data = NULL;
    v->size = 0;
    v->fill = 0;
}

int flist_get(FList *v)
{
    int head = v->head;
    int fill = v->fill;
    if ( head > 0 && head <= v->fill ) {
        v->head = v->data[head - 1];
        return head;
    } else {
        v->fill = v->fill + 1;
        if( v->fill >= v->size ) {
            size_t size = 1 + (v->fill * 3) / 2;
            int *data = realloc(v->data, size * sizeof(*data));
            if( data ) {
                v->data = data;
                v->size = size;
            } else {
                return -errno;
            }
        }
        v->data[v->fill - 1] = 0;
        return v->fill;
    }
}

int flist_put(FList *v, int n)
{
    if ( n < 1 || n > v->size )
        return -EINVAL;

    v->data[n - 1] = v->head;
    v->head        = n;
    return 0;
}
