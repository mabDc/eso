final nodeTestWithPredicate = RegExp(r'(?<node>.+)\[(?<predicate>.+)\]');
final predicateLast = RegExp(r'last\(\s*\)');
final predicatePosition = RegExp(r'position\(\s*\)');
final predicateInt = RegExp(r'^(?<num>\d+)$');
final predicateChild =
    RegExp(r'(?<child>\w+)\s*(?<op><|<=|>|>=)\s*(?<num>\d+)');

final predicateSym = RegExp(r'\+|\-|\*|\/|\smod\s|\sdiv\s|%');

final simplePosition =
    RegExp(r'position\(\s*\)\s*(?<op><|<=|>|>=)\s*(?<num>\d+)');
final simpleLast = RegExp(r'last\(\s*\)\s*(?<op>\+|\-|\*|\/%\^)\s*(?<num>\d+)');
final simpleSingleLast = RegExp(r'last\(\s*\)');

final predicateEqual = RegExp(
    r'''(?<not>(?:not)?)\s*\(?\s*(?<function>@?[\w-]+\(?\s*\)?)\s*(?<op>=|~=|\|=|\^=|\$=|\*=|!=)\s*['"](?<value>.+?)['"]\)?''');
final functionNodeTest = RegExp(r'^(?<function>\w+)\(\s*\)$');

final functionPredicate = RegExp(
    r'''(?<not>(?:not)?)\s*\(?\s*(?<function>[\w-]{4,})\s*\(\s*(?<param1>.+?)\s*,\s*['"](?<param2>.+?)\s*['"]\s*\)\)?''');

final predicateReg = RegExp(r'\[(?<predicate>.+?)\]');

final xpathGroup =
    RegExp(r'\/{0,2}@?[\w\*-]+:{0,2}[\*\w]*(?:\[.+?\])*(?:\(\))?');
