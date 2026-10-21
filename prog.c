#include <stdio.h>
#include <stdlib.h>

#define N 1024
#define M 3000000

float A[N][N];
float B[N][N];
float C[N][N];

void fill_matrices() {
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            A[i][j] = (rand() % 100) / 10.0f;
            B[i][j] = (rand() % 100) / 10.0f;
        }
    }
}

void mult_ijk() {
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            float sum = 0.0f;
            for (int k = 0; k < N; k++) {
                sum += A[i][k] * B[k][j];
            }
            C[i][j] = sum;
        }
    }
}

void mult_ikj() {
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            C[i][j] = 0.0f;
        }
        for (int k = 0; k < N; k++) {
            float a = A[i][k];
            for (int j = 0; j < N; j++) {
                C[i][j] += a * B[k][j];
            }
        }
    }
}

int compare(const void *a, const void *b) {
    return (*(int *)a - *(int *)b);
}

int sort_array() {
    int *arr = malloc(M * sizeof(int));
    for (int i = 0; i < M; i++) {
        arr[i] = rand() % 1000000;
    }
    qsort(arr, M, sizeof(int), compare);
    int middle = arr[M / 2];
    free(arr);
    return middle;
}

double sum_matrix() {
    double s = 0.0;
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            s += C[i][j];
        }
    }
    return s;
}

int main() {
    srand(1);
    fill_matrices();

#ifdef OPT
    mult_ikj();
#else
    mult_ijk();
#endif

    int middle = sort_array();
    double s = sum_matrix();
    printf("sum = %.2f, middle = %d\n", s, middle);
    return 0;
}