#include "quickjspp.hpp"
#include <iostream>
#include <cstring>

int main()
{
    qjs::Runtime runtime;
    qjs::Context context(runtime);
    
    try
    {
        auto val1 = context.newValue(321);
        auto val2 = context.newValue(123);
        assert(val1 != val2);

        val1 = val2;
        assert(val1 == val2);

        val1 = context.newValue(123);
        assert(val1 == val2);

        val1 = std::move(val2);
        assert(val1 != val2);

        assert(val1.as<std::string>() == "123");

        assert((double) val1 == 123.0);

        val2 = context.newValue((std::string) "123");
        assert(val1 != val2);

        context.global()["val1"] = val1;
        context.global()["val2"] = val2;


        assert((bool) context.eval("val1 !== val2"));
        assert((bool) context.eval("val1 == val2"));

        //

        val1 = context.newObject();
        val1["a"] = "1";
        val2 = context.newObject();
        val2["a"] = "1";

        assert(val1 != val2);

        context.global()["val1"] = val1;
        context.global()["val2"] = val2;

        assert((bool) context.eval("val1 !== val2"));
        assert((bool) context.eval("val1 != val2"));
        assert((bool)context.eval("JSON.stringify(val1) === JSON.stringify(val2)"));

        qjs::Value one = val1["a"];
        assert((int)one == 1);
    }
    catch(qjs::exception)
    {
        auto exc = context.getException();
        std::cerr << (exc.isError() ? "Error: " : "Throw: ") << (std::string) exc << std::endl;
        if((bool) exc["stack"])
            std::cerr << (std::string) exc["stack"] << std::endl;
        return 1;
    }
}
