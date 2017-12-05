#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <sys/time.h>

#define NUM_THREADS 2
//#define RAM_THREADS 4000000000L
// RAM size for each thread in bytes
#define RAM_THREADS 8000000L
// buffer size for each thread in bytes
//#define BUFFER_SIZE 8000000
#define BUFFER_SIZE 8000
#define FACTOR 4

typedef struct node_t {
    char *filename;
    unsigned long num_elems;
    unsigned short min;
    unsigned short max;
    unsigned int num_bkts;
    struct node_t **bkts;
} node_t;

typedef struct split_t {
    unsigned int tid;
    unsigned int num_files;
    FILE **files;
    node_t *root;
    unsigned long *sum;
} split_t;

typedef struct sort_t {
    unsigned int tid;
    unsigned int num_files;
    unsigned int *pos;
    char **files;
} sort_t;

void quick_fixx(char *, unsigned int);
void quick_sort(char *, unsigned int, unsigned int);
void *parallel_sort(void *);
void sort(node_t *);
void prepare_split(node_t *);
void *parallel_split(void *);
void split(node_t *);
unsigned long get_log(node_t *);
unsigned int get_num_files(node_t *);
void get_files(node_t *, char **, unsigned int *);
void free_tree(node_t *);

int main(int argc, char **argv)
{
    node_t *root;
    unsigned long filesize, elems, exectime;
    unsigned int i, step;
    char num[10];
    struct timeval start, end;

    // testing for proper number of arguments
    if (argc != 3) {
        printf("Arguments error!\n");
        return -1;
    }
    
    filesize = (unsigned long) atol(argv[2]);

    gettimeofday(&start, NULL);
    // initializing the root node
    root = (node_t *) malloc(sizeof(node_t));
    root->filename = strdup(argv[1]);
    root->num_elems = filesize / 100;
    root->min = 0;
    root->max = 0xFFFF;
    root->num_bkts = ((unsigned int) (filesize / RAM_THREADS)) * FACTOR;
    
    if (root->num_bkts > (unsigned int) (root->max - root->min)) {
        printf("Not enough RAM error!\n");
        return -3;
    }

    root->bkts = (node_t **) malloc(root->num_bkts * sizeof(node_t *));
    step = (root->max - root->min) / root->num_bkts;

    for (i = 0; i < root->num_bkts; i++) {
        sprintf(num, "%d", i);
        root->bkts[i] = (node_t *) malloc(sizeof(node_t));
        root->bkts[i]->filename = (char *) malloc(
                (strlen(root->filename) + strlen(num) + 1) * sizeof(char));
        strcpy(root->bkts[i]->filename, "");
        strcat(root->bkts[i]->filename, root->filename);
        strcat(root->bkts[i]->filename, "-");
        strcat(root->bkts[i]->filename, num);
        root->bkts[i]->num_elems = 0;
        if (i < (root->num_bkts - 1)) {
            root->bkts[i]->min = root->min + (step * i);
            root->bkts[i]->max = root->min + (step * (i + 1)) - 1;
        } else {
            root->bkts[i]->min = root->min + (step * i);
            root->bkts[i]->max = root->max;
        }
        root->bkts[i]->num_bkts = 0;
        root->bkts[i]->bkts = NULL;
    }

    // split the input into smaller buckets
    split(root);
    printf("Splitting finished!\n");

    // parallel sort the buckets
    sort(root);
    printf("Sorting finished!\n");
    gettimeofday(&end, NULL);
    exectime = (((long) end.tv_sec - (long) start.tv_sec) 
            * 1000000 + (end.tv_usec - start.tv_usec)) / 1000000;

    elems = get_log(root);
    free_tree(root);

    printf("Compute Time: %ld sec\n", exectime);
    printf("Data Read: %ld GB\n", (elems * 100 + filesize) / 1000000000);
    printf("Data Write: %ld GB\n", (elems * 100 + filesize) / 1000000000);

    return 0;
}

void quick_fixx(char *buffer, unsigned int n)
{
    unsigned int i, k;
    char temp[100];

    k = 0;
    for (i = 0; i < n; i += 100) {
        if (strncmp(&buffer[k], &buffer[i], 100) > 0) {
            memcpy(&temp[0], &buffer[k], 100);
            memcpy(&buffer[k], &buffer[i], 100);
            memcpy(&buffer[i], &temp[0], 100);
            k = i;
        }
    }
}

void quick_sort(char *buffer, unsigned int lo, unsigned int hi)
{
    unsigned int i, j, p;
    char temp[100];

    if ( lo + 100 == hi) {
        if (strncmp(&buffer[lo], &buffer[hi], 100) > 0) {
            memcpy(&temp[0], &buffer[lo], 100);
            memcpy(&buffer[lo], &buffer[hi], 100);
            memcpy(&buffer[hi], &temp[0], 100);
        }
        return;
    }

    if (lo >= hi) {
        return;
    }

    p = hi;
    j = p - 100;
    i = lo;

    while (i < j) {
        if (strncmp(&buffer[j], &buffer[p], 100) > 0) {
            memcpy(&temp[0], &buffer[p], 100);
            memcpy(&buffer[p], &buffer[j], 100);
            memcpy(&buffer[j], &temp[0], 100);
            p -= 100;
            j = p - 100;
            continue;
        }
        
        /*if (strncmp(&buffer[i], &buffer[p], 100) > 0) {
            memcpy(&temp[0], &buffer[j], 100);
            memcpy(&buffer[j], &buffer[i], 100);
            memcpy(&buffer[i], &temp[0], 100);
            i += 100;
            continue;
        }*/

        if (strncmp(&buffer[i], &buffer[p], 100) > 0) {
            memcpy(&temp[0], &buffer[p], 100);
            memcpy(&buffer[p], &buffer[i], 100);
            memcpy(&buffer[i], &buffer[j], 100);
            memcpy(&buffer[j], &temp[0], 100);
            p -= 100;
            j = p - 100;
            //i += 100;
            continue;
        }

        i += 100;
    }

    quick_sort(buffer, lo, p - 100);
    quick_sort(buffer, p, hi);
}

void *parallel_sort(void *args)
{
    sort_t *arg;
    FILE *fil;
    char *buffer;
    unsigned int pos, n;

    arg = (sort_t *) args;

    buffer = (char *) malloc(RAM_THREADS * sizeof(char));
    while ((pos = __sync_fetch_and_add(arg->pos, 1)) < arg->num_files) {
        fil = fopen(arg->files[pos], "rb");
        n = fread(buffer, sizeof(char), RAM_THREADS, fil);
        fclose(fil);

        if (n <= 0) {
            printf("Error reading while sorting\n");
            continue;
        }

        quick_sort(buffer, 0, n - 100);
        quick_fixx(buffer, n - 100);

        fil = fopen(arg->files[pos], "wb");
        n = fwrite(buffer, sizeof(char), n, fil);
        printf("Processed file %s\n", arg->files[pos]);
        fclose(fil);
    }
    free(buffer);

    pthread_exit(0);
}

void sort(node_t *root)
{
    unsigned int i, num_files, *pos;
    char **files;
    sort_t args[NUM_THREADS];
    pthread_t threads[NUM_THREADS];

    num_files = get_num_files(root);

    pos = (unsigned int *) malloc(sizeof(unsigned int));
    files = (char **) malloc(num_files * sizeof(char*));
    *pos = 0;
    get_files(root, files, pos);

    *pos = 0;
    for (i = 0; i < NUM_THREADS; i++) {
        args[i].tid = i;
        args[i].num_files = num_files;
        args[i].pos = pos;
        args[i].files = files;
    }

    for (i = 0; i < NUM_THREADS; i++) {
        pthread_create(&threads[i], NULL, parallel_sort, (void *) &args[i]);
    }

    for (i = 0; i < NUM_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }

    printf("Output files:\n");
    for (i = 0; i < num_files; i++) {
        printf("%s\n", files[i]);
    }

    free(pos);
    free(files);
}

void prepare_split(node_t *root)
{
    unsigned long filesize;
    unsigned int i, step;
    char num[10];
    
    filesize = root->num_elems * 100;

    root->num_bkts = ((unsigned int) (filesize / RAM_THREADS)) * FACTOR;
   
    if (root->num_bkts > (unsigned int) (root->max - root->min)) {
        printf("Not enough precission error!\n");
        return;
    }

    root->bkts = (node_t **) malloc(root->num_bkts * sizeof(node_t *));
    step = (root->max - root->min) / root->num_bkts;

    for (i = 0; i < root->num_bkts; i++) {
        sprintf(num, "%d", i);
        root->bkts[i] = (node_t *) malloc(sizeof(node_t));
        root->bkts[i]->filename = (char *) malloc(
                (strlen(root->filename) + strlen(num) + 1) * sizeof(char));
        strcpy(root->bkts[i]->filename, "");
        strcat(root->bkts[i]->filename, root->filename);
        strcat(root->bkts[i]->filename, "-");
        strcat(root->bkts[i]->filename, num);
        root->bkts[i]->num_elems = 0;
        if (i < (root->num_bkts - 1)) {
            root->bkts[i]->min = root->min + (step * i);
            root->bkts[i]->max = root->min + (step * (i + 1)) - 1;
        } else {
            root->bkts[i]->min = root->min + (step * i);
            root->bkts[i]->max = root->max;
        }
        root->bkts[i]->num_bkts = 0;
        root->bkts[i]->bkts = NULL;
    }
}

void *parallel_split(void *args)
{
    split_t *arg;
    FILE *fil;
    char buffer[BUFFER_SIZE];
    long pos;
    unsigned int i, step, j, n;
    unsigned long sum = 0;

    arg = (split_t *) args;
    step = (arg->root->max - arg->root->min) / arg->root->num_bkts;

    fil = fopen(arg->root->filename, "rb");
    pos = arg->tid * BUFFER_SIZE;
    fseek(fil, pos, 0);
    while((n = fread(buffer, sizeof(char), BUFFER_SIZE, fil)) > 0) {
        for (j = 0; j < n; j += 100) {
            i = (((unsigned int) buffer[j]) * 256 + (unsigned int) buffer[j+1]);
            i -= arg->root->min;
            i /= step;
            arg->root->bkts[i]->num_elems = __sync_add_and_fetch(
                    &arg->root->bkts[i]->num_elems, 1);
            fwrite(&buffer[j], sizeof(char), 100, arg->files[i]);
            *arg->sum = __sync_add_and_fetch(arg->sum, 100);
            if (arg->tid == 0 && (*arg->sum - sum > 100000000)) {
                printf("Processed: %lu Bytes\n", *arg->sum);
                sum = *arg->sum;
            }
        }
        pos += BUFFER_SIZE * NUM_THREADS;
        if (pos > arg->root->num_elems * 100) {
            break;
        }
        fseek(fil, pos, 0);
    }
    fclose(fil);

    pthread_exit(0);
}

void split(node_t *root)
{
    unsigned int i;
    FILE **files;
    split_t args[NUM_THREADS];
    pthread_t threads[NUM_THREADS];
    unsigned long *sum;
    
    sum = (unsigned long *) malloc(sizeof(unsigned long));
    *sum = 0;
    files = (FILE **) malloc(root->num_bkts * sizeof(FILE *));
    for (i = 0; i < root->num_bkts; i++) {
        files[i] = fopen(root->bkts[i]->filename, "wb");
    }

    for (i = 0; i < NUM_THREADS; i++) {
        args[i].tid = i;
        args[i].num_files = root->num_bkts;
        args[i].files = files;
        args[i].sum = sum;
        args[i].root = root;
    }

    for (i = 0; i < NUM_THREADS; i++) {
        pthread_create(&threads[i], NULL, parallel_split, (void *) &args[i]);
    }

    for (i = 0; i < NUM_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }

    for (i = 0; i < root->num_bkts; i++) {
        fclose(files[i]);
    }
    free(files);
    free(sum);

    for (i = 0; i < root->num_bkts; i++) {
        if ((root->bkts[i]->num_elems * 100) > RAM_THREADS) {
            if ((root->bkts[i]->max - root->bkts[i]->min) <= 1) {
                printf("Not enough precission error!\n");
                continue;
            }
            prepare_split(root->bkts[i]);
            split(root->bkts[i]);
        }
    }
}

unsigned long get_log(node_t *root) {
    unsigned int i;
    unsigned long sum = 0;

    if (root->num_bkts == 0) {
        return root->num_elems;
    }

    for (i = 0; i < root->num_bkts; i++) {
        sum += get_log(root->bkts[i]);
    }

    return sum + root->num_elems;
}

void free_tree(node_t *root)
{
    unsigned int i;

    if (root->num_bkts == 0) {
        free(root->filename);
        return;
    }

    for (i = 0; i < root->num_bkts; i++) {
        free_tree(root->bkts[i]);
        free(root->bkts[i]);
    }

    free(root->bkts);
    free(root->filename);
}

unsigned int get_num_files(node_t *root)
{
    unsigned int i, sum = 0;

    if (root->num_elems == 0) {
        return 0;
    }

    if (root->num_bkts == 0) {
        return 1;
    }

    for (i = 0; i < root->num_bkts; i++) {
        sum += get_num_files(root->bkts[i]);
    }

    return sum;
}

void get_files(node_t *root, char **files, unsigned int *pos)
{
    unsigned int i;

    if (root->num_elems == 0) {
        return;
    }

    if (root->num_bkts == 0) {
        files[*pos] = root->filename;
        *pos += 1;
        return;
    }

    for (i = 0; i < root->num_bkts; i++) {
        get_files(root->bkts[i], files, pos);
    }
}
