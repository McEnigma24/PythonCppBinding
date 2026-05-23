#include <pybind11/buffer_info.h>
#include <pybind11/numpy.h>
#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

#include "matrix.hpp"

namespace py = pybind11;

namespace
{

Matrix matrix_from_numpy_2d(py::array_t<double, py::array::c_style | py::array::forcecast> arr)
{
    py::buffer_info buf = arr.request();
    if (buf.ndim != 2)
    {
        throw std::runtime_error("Matrix: oczekiwano tablicy 2D (np.ndarray shape (rows, cols))");
    }
    const auto rows = static_cast<std::size_t>(buf.shape[0]);
    const auto cols = static_cast<std::size_t>(buf.shape[1]);
    Matrix m(rows, cols);
    const auto* src = static_cast<const double*>(buf.ptr);
    const auto row_stride = static_cast<std::size_t>(buf.strides[0] / static_cast<ssize_t>(sizeof(double)));
    const auto col_stride = static_cast<std::size_t>(buf.strides[1] / static_cast<ssize_t>(sizeof(double)));
    for (std::size_t i = 0; i < rows; ++i)
    {
        for (std::size_t j = 0; j < cols; ++j)
        {
            m.at(i, j) = src[i * row_stride + j * col_stride];
        }
    }
    return m;
}

double matrix_sum(const Matrix& m)
{
    double s = 0.0;
    for (std::size_t i = 0; i < m.rows(); ++i)
    {
        for (std::size_t j = 0; j < m.cols(); ++j)
        {
            s += m.at(i, j);
        }
    }
    return s;
}

} // namespace

PYBIND11_MODULE(python_cpp_binding, m)
{
    m.doc() = "Minimalny przykład obiektu C++ widocznego w Pythonie (macierz + numpy buffer).";

    m.def("add", &cpp_add);
    m.def("sub", &cpp_sub);
    m.def("matrix_sum", &matrix_sum, "Suma wszystkich elementów (przykład: funkcja przyjmuje Matrix z Pythona).");

    py::class_<Matrix>(m, "Matrix", py::buffer_protocol())
        .def(py::init<std::size_t, std::size_t>(), py::arg("rows"), py::arg("cols"), "Pusta macierz 0.0")
        .def(py::init<std::size_t, std::size_t, double>(),
             py::arg("rows"),
             py::arg("cols"),
             py::arg("fill_value"),
             "Macierz wypełniona stałą wartością")
        .def(py::init(&matrix_from_numpy_2d),
             py::arg("array"),
             "Kopia z numpy.ndarray dtype=float64, ndim=2")
        .def_buffer([](Matrix& mat) {
            return py::buffer_info(mat.data(),
                                   sizeof(double),
                                   py::format_descriptor<double>::format(),
                                   2,
                                   {static_cast<ssize_t>(mat.rows()), static_cast<ssize_t>(mat.cols())},
                                   {static_cast<ssize_t>(sizeof(double) * mat.cols()),
                                    static_cast<ssize_t>(sizeof(double))});
        })
        .def_property_readonly("shape", [](const Matrix& mat) { return py::make_tuple(mat.rows(), mat.cols()); })
        .def(
            "__getitem__",
            [](const Matrix& mat, py::tuple key) {
                if (py::len(key) != 2)
                {
                    throw std::runtime_error("Matrix: użyj indeksowania m[i, j] (krotka dwóch int)");
                }
                const auto i = key[0].cast<std::size_t>();
                const auto j = key[1].cast<std::size_t>();
                return mat.at(i, j);
            },
            py::arg("key"))
        .def(
            "__setitem__",
            [](Matrix& mat, py::tuple key, double value) {
                if (py::len(key) != 2)
                {
                    throw std::runtime_error("Matrix: użyj m[i, j] = wartość");
                }
                const auto i = key[0].cast<std::size_t>();
                const auto j = key[1].cast<std::size_t>();
                mat.at(i, j) = value;
            },
            py::arg("key"),
            py::arg("value"));
}
