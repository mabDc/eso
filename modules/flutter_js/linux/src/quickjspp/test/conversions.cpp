#include "quickjspp.hpp"
#include <iostream>
#include <numeric>

template <typename T>
void test_conv(qjs::Context& context, T x)
{
    auto jsx = context.newValue(x);

    auto x2 = static_cast<T>(jsx);

    if(!(x2 == x))
        throw std::exception();

    if constexpr (std::is_integral_v<T> && !std::is_same_v<T, uint64_t>)
    {
        auto x3 = static_cast<int64_t>(jsx);
        if(!(x3 == x))
            throw std::exception();
    }
}

template <typename T>
void test_num(qjs::Context& context)
{
    test_conv(context, std::numeric_limits<T>::min()+1);
    test_conv(context, std::numeric_limits<T>::max()-1);
    test_conv(context, std::numeric_limits<T>::min());
    test_conv(context, std::numeric_limits<T>::max());

}

int main()
{
    qjs::Runtime runtime;
    qjs::Context context(runtime);
    try
    {
        test_num<int16_t>(context);
        test_num<int32_t>(context);
        test_num<uint32_t>(context);

        // int64 is represented as double...
        test_conv<int64_t>(context, -(1ll << 52));
        test_conv<int64_t>(context, -(1ll << 52) + 1);
        test_conv<int64_t>(context, (1ll << 52));
        test_conv<int64_t>(context, (1ll << 52) - 1);
        test_conv<uint64_t>(context, (1ll << 52));
        test_conv<uint64_t>(context, (1ll << 52) - 1);


        test_num<double>(context);
        //test_num<float>(context);

    }
    catch(qjs::exception)
    {
        auto exc = context.getException();
        std::cerr << (std::string) exc << std::endl;
        if((bool) exc["stack"])
            std::cerr << (std::string) exc["stack"] << std::endl;
        return 1;
    }
}