import '../lib/src/jpath.dart';

searchAll(input) {
  if (input is List) {
    List result = [];
    result.addAll(input);
    input.forEach((item) {
      result.addAll(searchAll(item));
    });
    return result;
  } else if (input is Map) {
    List result = [];
    result.addAll(input.values);
    input.values.forEach((item) {
      result.addAll(searchAll(item));
    });
    return result;
  }
  return [input];
}

searchOne(input, target) {
  List result = [];
  if (input is List) {
    input.forEach((item) {
      result.addAll(searchOne(item, target));
    });
  } else if (input is Map) {
    if (input.containsKey(target)) {
      result.add(input[target]);
    }
    input.values.forEach((item) {
      result.addAll(searchOne(item, target));
    });
    return result;
  }
  return result;
}

Map testMap = {
  "store": {
    "book": [
      {
        "category": "fiction",
        "author": "Evelyn Waugh",
        "title": "Sword of Honour",
        "price": 12.99,
        "attr": "category"
      },
      {
        "category": "fiction",
        "author": "Herman Melville",
        "title": "Moby Dick",
        "isbn": "0-553-21311-3",
        "price": 8.99,
        "attr": "author"
      },
      {
        "category": "fiction",
        "author": "J. R. R. Tolkien",
        "title": "The Lord of the Rings",
        "isbn": "0-395-19395-8",
        "price": 22.99,
      },
      {
        "category": "fiction",
        "author": "J. R. R. Tolkien REES",
        "title": "The Lord of the Rings",
        "isbn": "0-395-19395-8",
        "price": 22.99,
      },
      {
        "category": "fiction",
        "author": "J. R. R. Tolkien Rees",
        "title": "The Lord of the Rings",
        "isbn": "0-395-19395-8",
        "price": 22.99,
      }
    ],
    "bicycle": {"color": "red", "price": 19.95}
  },
  "expensive": 10
};

main() {
  var jPathList = [
    "\$.store.book[*].author",
    "\$..book[*].author",
    "\$..author",
    "\$..store.book",
    ".book[1]",
    ".book[6]",
    ".book[-1].author",
    ".book[0, 1, 2].title",
    ".book[0 , 1, 2].title",
    ".book[-1:3].title",
    ".book[-1:3:].price",
    ".book[:3:].author",
    ".book[3::-1].author",
    ".book[::-1].author",
    ".book[::].author",
    ".book[-1::].title",
    ".book[::].price",
    ".book['price', 'title']",
    ".book[*]['price', 'title']",
    ".book[*]['price']",
    ".book[(1 + 1 * 1)]['price']",
    "\$..book[?(@.price <= \$['expensive'] && @.price >= 6)]",
    "\$..book[?(!(@.price <= \$['expensive'] && @.price >= 6))]",
    ".book[*][(@.attr)]",
    "\$..book[?(@.author =~ /.*REES/)]",
    "\$..book[?(@.author =~ /.*REES/i)]",
    ".book[?(@.attr == 'price')]",
    ".book[?(@.attr empty)]",
    ".book[?(@.attr isNull)]",
    "\$..book[*]",
    "\$..book[*].title.substr(0,5)",
    "\$..book[*].title.length(0,5)",
    "\$..book.title.length()",
    "\$..book[*].title.length().sum()",
    "\$..book.price.sum()",
    "\$..book[1:2]",
    ".book[01,2,34,5]",
    ".book[:-1]",
    ".book[1:12]",
    ".book[\$1:12]",
    ".book[:]",
    ".book[,]",
    ".book['a','b',  'c'].value[0].link",
    "\$..book[?(@.price <= \$['expensive'])]",
    "\$..book[?(@.author =~ /.*REES/i)]",
    ".book[*].length()",
    "\$.store.book[*].author.substr(0,9)",
    ".book[*].length().substr().aaaa...",
    ".book[0].length()",
    "\$..book[?(@.price <= \$['expensive'] && @.price >= 6)]",
    ".book[?(((@.price >= 16 || @.price <= \$['expensive'] && @.price >= 6)))]",
    ".book[((@.price || @.price <= \$['expensive']) && (@.price >= 6))]",
    ".book[((@.price || @.price <= \$['expensive']) && (@.price >= 3 + 6))]",
  ];

  jPathList.forEach((_path) {
    try {
      JPath jPath = JPath.compile(_path);
      print(jPath.search(testMap));
    } catch (error) {
      print(error);
    }
  });
}
