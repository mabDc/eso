#include "quickjspp.hpp"
#include <iostream>


#define TYPES bool, int32_t, double, std::shared_ptr<test>, const std::shared_ptr<test>&, std::string, const std::string&

class base_test
{
public:
    std::vector<std::vector<int>> base_field;

    int base_method(int x)
    {
        std::swap(x, base_field[0][0]);
        return x;
    }
};

class test : public base_test
{
public:
    bool b;
    mutable int32_t i;
    double d = 7.;
    std::shared_ptr<test> spt;
    std::string s;

    test(int32_t i, TYPES) : i(i)
    { printf("ctor!\n"); }

    test(int32_t i) : i(i)
    { printf("ctor %d!\n", i); }

    test(const test&) = delete;

    ~test()
    { printf("dtor!\n"); }

    int32_t fi(TYPES) const { i++; return i; }
    bool fb(TYPES) noexcept { i++; return b; }
    double fd(TYPES) const noexcept { i++; return d; }
    const std::shared_ptr<test>& fspt(TYPES) { i++; return spt; }
    const std::string& fs(TYPES) { i++; return s; }
    void f(TYPES) { i++; }

    static void fstatic(TYPES) {}
};


void f(TYPES) {}

void qjs_glue(qjs::Context::Module& m) {
    m.function<&::f>("f"); // (bool, ::int32_t, double, ::std::shared_ptr<test>, ::std::shared_ptr<test> const &, ::std::string, ::std::string const &)
    m.class_<::base_test>("base_test")
            // implicit: .constructor<::base_test const &>()
            .constructor<>()
            .fun<&::base_test::base_method>("base_method") // (double)
            .fun<&::base_test::base_field>("base_field") // double
            ;

    m.class_<::test>("test")
            //.base<::base_test>()
            .constructor<::int32_t, bool, ::int32_t, double, ::std::shared_ptr<test>, ::std::shared_ptr<test> const &, ::std::string, ::std::string const &>("Test")
            .constructor<::int32_t>("TestSimple")
            .fun<&::test::fi>("fi") // (bool, ::int32_t, double, ::std::shared_ptr<test>, ::std::shared_ptr<test> const &, ::std::string, ::std::string const &)
            .fun<&::test::fb>("fb") // (bool, ::int32_t, double, ::std::shared_ptr<test>, ::std::shared_ptr<test> const &, ::std::string, ::std::string const &)
            .fun<&::test::fd>("fd") // (bool, ::int32_t, double, ::std::shared_ptr<test>, ::std::shared_ptr<test> const &, ::std::string, ::std::string const &)
            .fun<&::test::fspt>("fspt") // (bool, ::int32_t, double, ::std::shared_ptr<test>, ::std::shared_ptr<test> const&, ::std::string, ::std::string const &)
            .fun<&::test::fs>("fs") // (bool, ::int32_t, double, ::std::shared_ptr<test>, ::std::shared_ptr<test> const &, ::std::string, ::std::string const &)
            .fun<&::test::f>("f") // (bool, ::int32_t, double, ::std::shared_ptr<test>, ::std::shared_ptr<test> const &, ::std::string, ::std::string const &)
            .fun<&::test::fstatic>("fstatic") // (bool, ::int32_t, double, ::std::shared_ptr<test>, ::std::shared_ptr<test>const &, ::std::string, ::std::string const &)
            .fun<&::test::b>("b") // bool
            .fun<&::test::i>("i") // ::int32_t
            .fun<&::test::d>("d") // double
            .fun<&::test::spt>("spt") // ::std::shared_ptr<test>
            .fun<&::test::s>("s") // ::std::string
            ;
} // qjs_glue

int main()
{
    JSRuntime * rt;
    JSContext * ctx;
    using namespace qjs;

    Runtime runtime;
    rt = runtime.rt;

    Context context(runtime);
    ctx = context.ctx;

    try
    {
        qjs_glue(context.addModule("test"));

        js_std_init_handlers(rt);
        /* loader for ES6 modules */
        JS_SetModuleLoaderFunc(rt, nullptr, js_module_loader, nullptr);
        js_std_add_helpers(ctx, 0, nullptr);

        /* system modules */
        js_init_module_std(ctx, "std");
        js_init_module_os(ctx, "os");

        /* make 'std' and 'os' visible to non module code */
        const char * str = "import * as std from 'std';\n"
                           "import * as os from 'os';\n"
                           "import * as test from 'test';\n"
                           "globalThis.std = std;\n"
                           "globalThis.test = test;\n"
                           "globalThis.os = os;\n";
        context.eval(str, "<input>", JS_EVAL_TYPE_MODULE);


        context.global().add("assert", [](bool t) { if(!t) std::exit(2); });


        auto xxx = context.eval("\"use strict\";"
                                "var b = new test.base_test();"
                                "b.base_field = [[5],[1,2,3,4],[6]];"
                                "assert(b.base_field[1][3] === 4);"
                                "assert(b.base_method() === 5);"

                                "var t = new test.TestSimple(12);"
                                "var q = new test.Test(13, t.vb, t.vi, t.vd, t, t, t.vs, t.vs);"
                                "q.b = true;"
                                "q.d = 456.789;"
                                "q.s = \"STRING\";"
                                "q.spt = t;"
                                //"q.base_field = 105.5;"
                                "assert(q.b === q.fb(t.vb, t.vi, t.vd, t, t, t.vs, \"test\"));"
                                "assert(q.d === q.fd(t.vb, t.vi, t.vd, t, t, t.vs, \"test\"));"
                                "assert(q.s === q.fs(t.vb, t.vi, t.vd, t, t, \"test\", t.vs));"
                                //"assert(105.5 === q.base_method(5.1));"
                                //"assert(5.1 === q.base_field);"
                                "assert(q.spt !== q.fspt(t.vb, t.vi, t.vd, t, t, t.vs, \"test\"));" // different objects
                                "q.fi(t.vb, t.vi, t.vd, t, t, t.vs, \"test\")");
        assert((int)xxx == 18);
        auto yyy = context.eval("q.fi.bind(t)(t.vb, t.vi, t.vd, t, t, t.vs, \"test\")");
        assert((int)yyy == 13);

        auto f = context.eval("q.fi.bind(q)").as<std::function<int32_t(TYPES)>>();
        int zzz = f(false, 1, 0., context.eval("q").as<std::shared_ptr<test>>(),
                    context.eval("t").as<std::shared_ptr<test>>(), "test string", std::string{"test"});
        assert(zzz == 19);

    }
    catch(exception)
    {
        auto exc = context.getException();
        std::cerr << (exc.isError() ? "Error: " : "Throw: ") << (std::string)exc << std::endl;
        if((bool)exc["stack"])
            std::cerr << (std::string)exc["stack"] << std::endl;

        js_std_free_handlers(rt);
        return 1;
    }

    js_std_loop(ctx);

    js_std_free_handlers(rt);

    return 0;

}
