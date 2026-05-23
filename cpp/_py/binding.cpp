#include <pybind11/pybind11.h>
#include "matrix.hpp"

namespace py = pybind11;


PYBIND11_MODULE(python_cpp_binding, m)
{
    m.def("add", &cpp_add);


    m.def("sub", &cpp_sub);
}
