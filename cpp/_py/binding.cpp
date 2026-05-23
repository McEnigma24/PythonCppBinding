#include <pybind11/pybind11.h>

namespace py = pybind11;

// Przykładowa funkcja C++ wywoływana z Pythona (tutaj dodajesz własną logikę / wygenerowany kod).
static int cpp_add(int a, int b) { return a + b; }
static int cpp_sub(int a, int b) { return a - b; }

PYBIND11_MODULE(python_cpp_binding, m)
{
    m.def("add", &cpp_add);


    m.def("sub", &cpp_sub);
}
