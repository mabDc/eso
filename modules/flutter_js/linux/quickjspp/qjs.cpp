#include "quickjspp.hpp"


#include <iostream>

int main(int argc, char ** argv)
{
    JSRuntime * rt;
    JSContext * ctx;
    using namespace qjs;

    Runtime runtime;
    rt = runtime.rt;

    Context context(runtime);
    ctx = context.ctx;

    js_std_init_handlers(rt);
    /* loader for ES6 modules */
    JS_SetModuleLoaderFunc(rt, nullptr, js_module_loader, nullptr);
    js_std_add_helpers(ctx, argc - 1, argv + 1);

    /* system modules */
    js_init_module_std(ctx, "std");
    js_init_module_os(ctx, "os");

    /* make 'std' and 'os' visible to non module code */
    const char * str = "import * as std from 'std';\n"
                       "import * as os from 'os';\n"
                       "globalThis.std = std;\n"
                       "globalThis.os = os;\n";
    context.eval(str, "<input>", JS_EVAL_TYPE_MODULE);

    try
    {
        if(argv[1])
            context.evalFile(argv[1], JS_EVAL_TYPE_MODULE);
    }
    catch(exception)
    {
        //js_std_dump_error(ctx);
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
