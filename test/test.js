@js:

function notthesame() {
    window.current_page_content_temp = result;
    return result;
}

(() => {
    // 这个是正则判断终止
    // if(/../.test(String(result))) return []
    // 这里也可以最后一页判断
    // var all_page = String(result).match(/xx/)
    // if(page >= all_page) return [];
    // else return result;
    print(String(window.current_page_content_temp))
    if (window.current_page_content_temp === undefined) {
        // 判断变量存在，不需要依赖外部变量
        return notthesame();
    }
    // 找不同
    // 1、类型
    if (typeof (window.current_page_content_temp) !== typeof (result)) {
        return notthesame();
    }
    // 2、转字符层
    if (String(window.current_page_content_temp) !== String(result)) {
        return notthesame();
    }
    // 3、长度不同
    if (result["length"] !== window.current_page_content_temp["length"]) {
        return notthesame();
    }
    // 4、数组不同
    if (result["length"]) {
        var len = result["length"];
        if (typeof (result) === "object" && Array.isArray(result) && Array.isArray(window.current_page_content_temp)) {
            for (let index = 0; index < len; index++) {
                if (String(result[index]) !== String(window.current_page_content_temp[index])) {
                    return notthesame();
                }
                if (result[index] !== window.current_page_content_temp[index]) {
                    return notthesame();
                }
            }
        }
    }
    // 5、自己看需求补充
    // 完全相同返回空内容即可
    return [];
})()