#include "quickjspp.hpp"
#include <iostream>

struct A{};

int main()
{
    qjs::Runtime runtime;
    qjs::Context context(runtime);
    context.global().add("println", [](const std::string& s) { std::cout << s << std::endl; });

    context.registerClass<A>("A");
    context.registerClass<A>("A");

    try
    {
        auto obj = context.eval("Symbol.toPrimitive");
        std::cout << static_cast<int>(obj) << std::endl;
        assert(false);
    }
    catch(qjs::exception)
    {
        auto exc = context.getException();
        assert(exc.isError() && (std::string) exc == "TypeError: cannot convert symbol to number");
    }

    try
    {
        std::string big;
        big.resize((1 << 30) + 1);
        auto fun = context.eval("(function(a, b, c) { println(a); println(b); println(c); })").as<std::function<void(double, std::string, int)>>();
        fun(0, std::move(big), 0);
        assert(false);
    }
    catch(qjs::exception)
    {
        auto exc = context.getException();
        std::cout << (std::string) exc << '\n' << (std::string_view) exc["stack"];
    }

    try
    {
        //context.global().add("emptyf", [](JSValue v) {} );
        auto f = (std::function<void ()>) context.eval("(function() { +Symbol.toPrimitive })");
        f();
        assert(false);
    }
    catch(qjs::exception)
    {
        auto exc = context.getException();
        std::cout << (std::string) exc << '\n' << (std::string_view) exc["stack"];
    }

    try
    {
        qjs::Value function = context.eval("() => { let a = b; }", "<test>");
        auto native = function.as<std::function<qjs::Value()>>();
        qjs::Value result = native();
        assert(false);
    }
    catch(qjs::exception)
    {
        auto exc = context.getException();
        std::cerr << (exc.isError() ? "Error: " : "Throw: ") << (std::string)exc << std::endl;
        if((bool)exc["stack"])
            std::cerr << (std::string)exc["stack"] << std::endl;
    }

}
