#include "quickjspp.hpp"
#include <iostream>

class MyClass
{
public:
    MyClass() {}

    void print_context(qjs::Value value) { std::cout << "Context: " << value.ctx << '\n'; }
};

void println(const std::string& str) { std::cout << str << std::endl; }

static void glue(qjs::Context::Module& module)
{
    module.function<&println>("println");
    module.class_<MyClass>("MyClass")
            .constructor<>()
            .fun<&MyClass::print_context>("print_context");
}


int main()
{
    qjs::Runtime runtime;
    qjs::Context context1(runtime);
    qjs::Context context2(runtime);
    try
    {
        // export classes as a module
        glue(context1.addModule("MyModule"));
        // evaluate js code
        context1.eval("import * as my from 'MyModule'; " "\n"
                      "(new my.MyClass()).print_context(undefined);" "\n"
                     , "<eval>", JS_EVAL_TYPE_MODULE
        );
    }
    catch(qjs::exception)
    {
        auto exc = context1.getException();
        std::cerr << (std::string) exc << std::endl;
        if((bool) exc["stack"])
            std::cerr << (std::string) exc["stack"] << std::endl;
        return 1;
    }
    try
    {
        glue(context2.addModule("MyModule"));
        context2.eval("import * as my from 'MyModule'; " "\n"
                      "(new my.MyClass()).print_context(undefined);" "\n"
                      ,"<eval>", JS_EVAL_TYPE_MODULE
        );
    }
    catch(qjs::exception)
    {
        auto exc = context2.getException();
        std::cerr << (std::string) exc << std::endl;
        if((bool) exc["stack"])
            std::cerr << (std::string) exc["stack"] << std::endl;
        return 1;
    }
}