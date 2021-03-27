/// https://github.com/flame-engine/flame/blob/main/packages/flame/lib/src/memory_cache.dart

import 'dart:collection';

/// Simple class to cache values with size based eviction.
///
class MemoryCache<K, V> {
  final LinkedHashMap<K, V> _cache = LinkedHashMap();
  final int cacheSize;

  MemoryCache({this.cacheSize = 20}); // 大约足够一个章节

  void setValue(K key, V value) {
    if (!_cache.containsKey(key)) {
      _cache[key] = value;

      // 没必要每次都清理
      if (_cache.length > cacheSize + 4) {
        while (_cache.length > cacheSize) {
          final k = _cache.keys.first;
          _cache.remove(k);
        }
      }
    }
  }

  V? getValue(K key) => _cache[key];

  V? getValueOrSet(K key, V? Function() or) {
    var value = _cache[key];
    if (value == null) {
      value = or();
      if (value != null) setValue(key, value);
    }
    return value;
  }

  bool containsKey(K key) => _cache.containsKey(key);

  int get size => _cache.length;

  clear() => _cache.clear();
}
