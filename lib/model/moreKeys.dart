import 'dart:convert' show json;

T asT<T>(dynamic value) {
  if (value is T) {
    return value;
  }
  return null;
}

class ItemMoreKeys {
  ItemMoreKeys({this.list, this.isWrap});

  factory ItemMoreKeys.fromJson(Map<String, dynamic> jsonRes) {
    if (jsonRes == null) {
      return null;
    }

    final List<ListFilters> list =
        jsonRes['list'] is List ? <ListFilters>[] : null;

    final bool isWrap =
        jsonRes['isWrap'] is bool ? asT<bool>(jsonRes['isWrap']) : true;

    if (list != null) {
      for (final dynamic item in jsonRes['list']) {
        if (item != null) {
          list.add(ListFilters.fromJson(asT<Map<String, dynamic>>(item)));
        }
      }
    }
    return ItemMoreKeys(
      list: list,
      isWrap: isWrap,
    );
  }

  List<ListFilters> list;
  bool isWrap;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'list': list,
        'isWarp': isWrap,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}

RequestFilters getFilters(List<String> child, String keyName) {
  print("child:${child}");

  final items = child.map((v) {
    final d = v.split("::");
    print("d:${d.toString()}");
    return Items(title: d[0], value: d[1]);
  }).toList();
  return RequestFilters(key: keyName, items: items, value: items.first.value);
}

class ListFilters {
  ListFilters({
    this.title,
    this.requestFilters,
  });

  factory ListFilters.fromJson(Map<String, dynamic> jsonRes) {
    if (jsonRes == null) {
      return null;
    }
    final _requestFilters = jsonRes['requestFilters'];

    final List<RequestFilters> requestFilters =
        (_requestFilters is List) || (_requestFilters is String)
            ? <RequestFilters>[]
            : null;

    if (requestFilters != null) {
      if (_requestFilters is List) {
        for (final dynamic item in _requestFilters) {
          if (item != null) {
            requestFilters
                .add(RequestFilters.fromJson(asT<Map<String, dynamic>>(item)));
          }
        }
      } else if (_requestFilters is String) {
        List<String> s = _requestFilters.split("\n\n");

        bool hasSingle = false;
        if (s.isEmpty || !RegExp("\n\n").hasMatch(_requestFilters)) {
          hasSingle = true;
          s = _requestFilters.split("\n");
        }
        print("hasSingle:${hasSingle}");
        print("getFilters=${getFilters(s, "filter")}");

        requestFilters.addAll(hasSingle
            ? [getFilters(s, "filter")]
            : s.map((e) {
                final t = e.split("\n");
                final keyName = t.first;
                t.removeWhere((element) => element == keyName);
                return getFilters(t, keyName);
              }));
      }
    }
    return ListFilters(
      title: asT<String>(jsonRes['title']),
      requestFilters: requestFilters ?? [],
    );
  }

  String title;
  List<RequestFilters> requestFilters;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'requestFilters': requestFilters,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}

class RequestFilters {
  RequestFilters({
    this.items,
    this.key,
    this.value,
  });

  factory RequestFilters.fromJson(Map<String, dynamic> jsonRes) {
    if (jsonRes == null) {
      return null;
    }

    final List<Items> items = jsonRes['items'] is List ? <Items>[] : null;
    if (items != null) {
      for (final dynamic item in jsonRes['items']) {
        if (item != null) {
          items.add(Items.fromJson(asT<Map<String, dynamic>>(item)));
        }
      }
    }
    return RequestFilters(
      items: items,
      key: asT<String>(jsonRes['key']),
      //value: asT<String>(jsonRes['value']),
      value: items.first.value,
    );
  }

  List<Items> items;
  String key;
  String value;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'items': items,
        'key': key,
        'value': value,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}

class Items {
  Items({
    this.title,
    this.value,
  });

  factory Items.fromJson(Map<String, dynamic> jsonRes) => jsonRes == null
      ? null
      : Items(
          title: asT<String>(jsonRes['title']),
          value: asT<String>(jsonRes['value']) ??
              asT<int>(jsonRes['value']).toString() ??
              asT<double>(jsonRes['value']).toString(),

          // value: asT<String>(jsonRes['value'])
        );

  String title;
  String value;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'value': value,
      };
  @override
  String toString() {
    return json.encode(this);
  }
}
