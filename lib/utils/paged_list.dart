import 'dart:collection';

/// List wrapper with an additional field used for notifying the user how many entries the back-end has.
/// Used mainly for pagination.
class PagedList<E> extends ListBase<E> {
  /// List data structure
  late List<E> _innerList;
  /// How many entries the back-end told us that it has
  late int _maxCount;
  /// How many pages the back-end told us that it has
  late int _maxPages;

  PagedList(List<E> list, int maxCount, int maxPages) {
    _innerList = list;
    _maxCount = maxCount;
    _maxPages = maxPages;
  }
  /// Getter for the max items count
  int get maxCount => _maxCount;
  /// Getter for the max pages count
  int get maxPages => _maxPages;

  @override
  int get length => _innerList.length;
  @override
  set length(int length) {
    _innerList.length = length;
  }

  @override
  void operator []=(int index, E value) {
    _innerList[index] = value;
  }

  @override
  E operator [](int index) => _innerList[index];

  @override
  void add(E value) => _innerList.add(value);

  @override
  void addAll(Iterable<E> all) => _innerList.addAll(all);
}
