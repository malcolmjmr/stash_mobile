class CustomFieldFields {
  CustomFieldFields({required this.instances});

  late List<String> instances;

  CustomFieldFields.fromJson(Map<String, dynamic> json) {
    instances = json['instances'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    return {
      'instances': instances,
    };
  }
}
