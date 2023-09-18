

class Tag {
  String name;
  int valueCount = 0;
  int lastViewed;
  bool isSelected = false;

  Tag({
    required this.name, 
    this.valueCount = 0, 
    this.lastViewed = 0,
    this.isSelected = false,
  });

  @override
  String toString() {
    // TODO: implement toString
    return '<Tag: ${name}>';
  }

}