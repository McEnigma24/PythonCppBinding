#pragma once

#include "__preprocessor__.h"

#include <cstddef>
#include <stdexcept>
#include <string>
#include <vector>

/// Prosta macierz double, wierszowo (row-major), współdzielona z Pythonem przez pybind11 (buffer protocol).
class Matrix
{
public:
    Matrix(std::size_t rows, std::size_t cols, double fill_value = 0.0)
        : rows_(rows)
        , cols_(cols)
        , storage_(rows * cols, fill_value)
    {}

    std::size_t rows() const noexcept { return rows_; }
    std::size_t cols() const noexcept { return cols_; }

    double* data() noexcept { return storage_.data(); }
    const double* data() const noexcept { return storage_.data(); }

    double& at(std::size_t r, std::size_t c)
    {
        if (r >= rows_ || c >= cols_)
        {
            throw std::out_of_range("Matrix::at: indeks poza zakresem");
        }
        return storage_[r * cols_ + c];
    }

    const double& at(std::size_t r, std::size_t c) const
    {
        if (r >= rows_ || c >= cols_)
        {
            throw std::out_of_range("Matrix::at: indeks poza zakresem");
        }
        return storage_[r * cols_ + c];
    }

private:
    std::size_t rows_;
    std::size_t cols_;
    std::vector<double> storage_;
};

inline int cpp_add(int a, int b) { return a + b; }
inline int cpp_sub(int a, int b) { return a - b; }
