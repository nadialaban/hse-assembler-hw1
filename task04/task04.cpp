#include <iostream>
#include <ctime>
#include <omp.h>

class Matrix {
public:
    /**
     * Инициализирует квадратную матрицу заданного размера
     * и заполняет ее в диапазоне от MIN_VAL до MAX_VAL
     * @param size - размер матрицы
     */
    explicit Matrix(int size, bool empty = false) {
        this->size = size;
        matrix = new double* [size];
        for (int i = 0; i < size; ++i) {
            matrix[i] = new double [size];
            for (int j = 0; j < size; ++j) {
                matrix[i][j] = empty ? 0 : static_cast<double>(rand() % MAX_VAL + MIN_VAL);
            }
        }
    }

    /**
     * Считает k-ю строку в новой матрице
     * @param a - первая матрица в умножении
     * @param b - вторая матрица в умножении
     * @param k - номер строки
     * @return
     */
    void mul_rows(Matrix* a, Matrix* b, int from, int to) {
        for (int k = from; k < to; ++k) {
            for (int i = 0; i < size; ++i) {
                for (int j = 0; j < size; ++j) {
                    matrix[k][i] += a->matrix[k][j] * b->matrix[j][i];
                }
            }
        }
    }

    /**
     * Выводит матрицу в консоль
     */
    void display() {
        for (int i = 0; i < size; ++i) {
            for (int j = 0; j < size; ++j)
                std::cout << matrix[i][j] << "\t";
            std::cout << "\n";
        }
    }

    ~Matrix() {
        for (int i = 0; i < size; ++i) {
            delete [] matrix[i];
        }
    }
private:
    const int MAX_VAL = 10;         // Максимальная граница рандома.
    const int MIN_VAL = 0;          // Минимальная граница рандома.
    int size;                       // Размерность матрицы.
    double **matrix;                // Матрица.
};

struct thread_args {
    Matrix *a;                 // Первая матрица в умножении.
    Matrix *b;                 // Вторая матрица в умножении.
    Matrix *c;                 // Результирующая матрица.
    int from;                  // Строка с которой поток начинает.
    int to;                    // Строка, на которой поток заканчивает.
};

/**
 * Функция для потока.
 * @param arg - Аргументы потока.
 */
void thread_func(thread_args* arg) {
    arg->c->mul_rows(arg->a, arg->b, arg->from, arg->to);
}

/**
 * Считывает положительное целочисленное значение с клавиатуры
 * @param valName - наименование значения
 * @return целочисленное значение
 */
int getInteger(const std::string& valName) {
    int n;
    do {
        std::cout << "\nEnter " << valName << ": ";
        std::cin >> n;

        if (std::cin.fail())
        {
            std::cout << "Please, enter an integer!\n";
            std::cin.clear();
            std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
            continue;
        }

        if (n <= 0) {
            std::cout << "Value should be a positive integer! \n";
        }
    } while (n <= 0);
    return n;
}

int main() {
    std::srand(time(nullptr));
    setlocale(LC_ALL, "ru_RU.UTF-8");
    // Запрашиваем размерность матрицы.
    int size = getInteger("matrix dimension");

    // Инициализируем и выводим матрицы.
    auto a = new Matrix(size);
    auto b = new Matrix(size);
    std::cout << "Matrix A:\n";
    a->display();
    std::cout << "\nMatrix B:\n";
    b->display();

    // Матрица для результата.
    auto c = new Matrix(size, true);

    // Запрашиваем количество потоков.
    int threads_count = getInteger("threads count");
    omp_set_dynamic(0);
    // Сощдаем массив потоков и аргументов к ним.
    thread_args *args;

    args = (thread_args*) malloc(sizeof(thread_args) * threads_count);

    // Считаем количество строк, обрабатываемых одним потоком.
    int rows_per_thread = size / threads_count;
    int residue = size % threads_count;

    // Инициализируем аргументы для потоков.
    for (int i = 0; i < threads_count; i++) {
        args[i].a = a;
        args[i].b = b;
        args[i].c = c;
        args[i].from = rows_per_thread * i;
        args[i].to = (i + 1)*rows_per_thread;
    }
    args[threads_count - 1].to += residue;
#pragma omp parallel for num_threads(threads_count)
        for (int i = 0; i < threads_count; ++i) {
            thread_func(&args[i]);
        }


    // Выводим результат.
    std::cout << "\nResult:\n";
    c->display();

    return 0;
}