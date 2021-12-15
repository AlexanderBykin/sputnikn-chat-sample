extension ListExtension on List {
  int calculateItemsHash() {
    int result = 0;
    for (int i = 0; i < length; i++) {
      result += elementAt(i).hashCode;
    }
    return result;
  }
}
