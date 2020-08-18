#include "quickjspp.hpp"
#include <iostream>
#include <cmath>

class Point
{
public:
    int x, y;
    Point(int x, int y) : x(x), y(y) {}

    double norm() const
    {
        return std::sqrt((double)x * x + double(y) * y);
    }
};


int main()
{
    qjs::Runtime runtime;
    qjs::Context context(runtime);
    try
    {
        // export classes as a module
        auto& module = context.addModule("MyModule");
        module.class_<Point>("Point")
                .constructor<int, int>()
                .fun<&Point::x>("x")
                .fun<&Point::y>("y")
                .fun<&Point::norm>("norm");
        // import module
        context.eval(R"xxx(
import { Point } from "MyModule";

function assert(b, str)
{
    if (b) {
        return;
    } else {
        throw Error("assertion failed: " + str);
    }
}

class ColorPoint extends Point {
    constructor(x, y, color) {
        super(x, y);
        this.color = color;
    }
    get_color() {
        return this.color;
    }
};

function main()
{
    var pt, pt2;

    pt = new Point(2, 3);
    assert(pt.x === 2);
    assert(pt.y === 3);
    pt.x = 4;
    assert(pt.x === 4);
    assert(pt.norm() == 5);

    pt2 = new ColorPoint(2, 3, 0xffffff);
    assert(pt2.x === 2);
    assert(pt2.color === 0xffffff);
    assert(pt2.get_color() === 0xffffff);
}

main();
)xxx", "<eval>", JS_EVAL_TYPE_MODULE);
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