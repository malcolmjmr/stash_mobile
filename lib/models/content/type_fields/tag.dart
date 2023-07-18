class TagFields {
  late List<String> instances;

  TagFields({required this.instances});

  TagFields.fromJson(Map<String, dynamic> json) {
    instances = json['instances'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    return {
      'instances': instances,
    };
  }
}
