/* Лабораторна робота: профілювання програми.
   Програма множить дві матриці, потім сортує масив чисел. */
#include <stdio.h>
#include <stdlib.h>

#define N 1024        /* розмір матриць */
#define M 3000000     /* розмір масиву для сортування */

float A[N][N];
float B[N][N];
float C[N][N];

/* заповнюємо матриці випадковими числами */
void fill_matrices() {
    int i, j;
    for (i = 0; i < N; i++) {
        for (j = 0; j < N; j++) {
            A[i][j] = rand() % 100 / 10.0;
            B[i][j] = rand() % 100 / 10.0;
        }
    }
}

/* звичайне множення матриць (порядок циклів i, j, k) */
void mult_ijk() {
    int i, j, k;
    for (i = 0; i < N; i++) {
        for (j = 0; j < N; j++) {
            float sum = 0;
            for (k = 0; k < N; k++) {
                sum = sum + A[i][k] * B[k][j];
            }
            C[i][j] = sum;
        }
    }
}

/* оптимізоване множення: змінили порядок циклів на i, k, j,
   тоді ми читаємо B і C по рядках, а це швидше для кешу */
void mult_ikj() {
    int i, j, k;
    for (i = 0; i < N; i++) {
        for (j = 0; j < N; j++) {
            C[i][j] = 0;
        }
        for (k = 0; k < N; k++) {
            float a = A[i][k];
            for (j = 0; j < N; j++) {
                C[i][j] = C[i][j] + a * B[k][j];
            }
        }
    }
}

/* функція порівняння для qsort */
int compare(const void *a, const void *b) {
    return *(int *)a - *(int *)b;
}

/* створюємо масив випадкових чисел і сортуємо його */
int sort_array() {
    int *arr = malloc(M * sizeof(int));
    int i;
    for (i = 0; i < M; i++) {
        arr[i] = rand() % 1000000;
    }
    qsort(arr, M, sizeof(int), compare);
    int middle = arr[M / 2];
    free(arr);
    return middle;
}

/* сума всіх елементів матриці C (щоб перевірити, що результат правильний) */
double sum_matrix() {
    double s = 0;
    int i, j;
    for (i = 0; i < N; i++) {
        for (j = 0; j < N; j++) {
            s = s + C[i][j];
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
