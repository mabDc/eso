//JsonPath (点击链接测试)	结果
//$.store.book[*].author	获取json中store下book下的所有author值
//$..author	获取所有json中所有author的值
//$.store.*	所有的东西，书籍和自行车
//$.store..price	获取json中store下所有price的值
//$..book[2]	获取json中book数组的第3个值
//$..book[-2]	倒数的第二本书
//$..book[0,1]	前两本书
//$..book[:2]	从索引0（包括）到索引2（排除）的所有图书
//$..book[1:2]	从索引1（包括）到索引2（排除）的所有图书
//$..book[-2:]	获取json中book数组的最后两个值
//$..book[2:]	获取json中book数组的第3个到最后一个的区间值
//$..book[?(@.isbn)]	获取json中book数组中包含isbn的所有值
//$.store.book[?(@.price < 10)]	获取json中book数组中price<10的所有值
//$..book[?(@.price <= $['expensive'])]	获取json中book数组中price<=expensive的所有值
//$..book[?(@.author =~ /.*REES/i)]	获取json中book数组中的作者以REES结尾的所有值（REES不区分大小写）
//$..*	逐层列出json中的所有值，层级由外到内
//$..book.length()	获取json中book数组的长度

//Function	Description	Output
//min()	Provides the min value of an array of numbers	Double
//max()	Provides the max value of an array of numbers	Double
//avg()	Provides the average value of an array of numbers	Double
//stddev()	Provides the standard deviation value of an array of numbers	Double
//length()	Provides the length of an array	Integer
//sum()	Provides the sum value of an array of numbers	Double

//$	查询根元素。这将启动所有路径表达式。
//@	当前节点由过滤谓词处理。
//*	通配符，必要时可用任何地方的名称或数字。
//..	深层扫描。 必要时在任何地方可以使用名称。
//.<name>
//点，表示子节点
//['<name>' (, '<name>')]
//括号表示子项
//[<number> (, <number>)]
//数组索引或索引
//[start:end]
//数组切片操作
//[?(<expression>)]	过滤表达式。 表达式必须求值为一个布尔值。
//import './src/jpath.dart' show JPath;
export './src/jpath.dart' show JPath;