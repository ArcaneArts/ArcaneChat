import 'dart:math';

class CacheRange<T> {
  final int from;
  final int to;
  final List<T> data = List<T>();

  CacheRange(this.from, this.to);

  static List<CacheRange> mergeAll(List<CacheRange> c) {
    List<CacheRange> cr = List<CacheRange>();
    List<int> taken = List<int>();
    int merged = 0;

    for (int i = 0; i < c.length; i++) {
      if (taken.contains(i)) {
        continue;
      }

      for (int j = 0; j < c.length; j++) {
        if (taken.contains(j)) {
          continue;
        }
        if (i == j) {
          continue;
        }

        if (c[i].isMergable(c[j])) {
          taken.add(i);
          taken.add(j);
          cr.add(CacheRange.merge(c[i], c[j]));
          merged++;
        }
      }
    }

    return merged > 0 ? mergeAll(cr) : cr;
  }

  static CacheRange merge(CacheRange a, CacheRange b) =>
      CacheRange(min(a.from, b.from), max(a.to, b.to))
        ..data.addAll(a.from <= b.from ? a.data : b.data)
        ..data.addAll(a.from >= b.from ? a.data : b.data);

  void fill(T t) {
    data.clear();
    for (int i = 0; i < inclusiveSize(); i++) {
      data.add(t);
    }
  }

  int indexFor(int block) => block - from;

  bool isMergable(CacheRange r) =>
      r.containsInclusive(from) ||
      r.containsInclusive(to) ||
      containsInclusive(r.from) ||
      containsInclusive(r.to);

  bool containsInclusive(int v) => v >= from && v <= to;

  int size() => to - from;

  int inclusiveSize() => size() + 1;
}

typedef CacheResolver<T>(int block);

class ArcaneCache<T> {
  List<CacheRange<T>> cache = List<CacheRange<T>>();
  int fragmentation = 3;
  ArcaneCache();

  void invalidateBlock(int block) {
    CacheRange<T> v = getRange(block);

    if (v != null) {
      try {
        v.data[v.indexFor(block)] = null;
      } catch (e) {}
    }
  }

  void invalidateAll() {
    cache.clear();
  }

  CacheRange<T> getRange(int block) =>
      cache.firstWhere((cr) => cr.containsInclusive(block), orElse: () => null);

  Future<T> compute(int block, CacheResolver<Future<T>> resolver) async =>
      getCached(block) ??
      resolver(block).then((v) {
        cacheDataSingle(v, block);
        return v;
      });

  T computeSync(int block, CacheResolver<T> resolver) {
    T t = getCached(block);

    if (t == null) {
      t = resolver(block);
      cacheDataSingle(t, block);
    }

    return t;
  }

  T getCached(int block) {
    CacheRange<T> c = getRange(block);

    if (c != null) {
      try {
        return c.data[c.indexFor(block)];
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  void cacheDataSingle(T data, int block) {
    CacheRange<T> crx = getRange(block);

    if (crx != null) {
      crx.data[crx.indexFor(block)] = data;
      return;
    }

    CacheRange<T> cr = CacheRange(block, block);
    cr.data.add(data);
    cleanup();
  }

  void cacheData(List<T> data, int startBlock, int endBlock) {
    CacheRange<T> cr = CacheRange(startBlock, endBlock);
    cr.data.addAll(data);
    cleanup();
  }

  void cleanup() {
    if (cache.length > fragmentation) {
      cache = CacheRange.mergeAll(cache);

      if (cache.length > fragmentation) {
        fragmentation += 3 + (fragmentation ~/ 7);
      }
    }
  }
}
