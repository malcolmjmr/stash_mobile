class ContentLinks {
  ContentLinks({
    this.back,
    this.forward,
  });

  List<String>? back;
  addBackLinkId(String id) {
    if (back == null) back = [];
    if (!back!.contains(id)) back!.add(id);
  }

  List<UserLinks>? allBackLinks;

  List<String>? forward;
  addForwardLinkId(String id) {
    if (forward == null) forward = [];
    if (!forward!.contains(id)) forward!.add(id);
  }

  List<UserLinks>? allForwardLinks;

  List<CustomLink>? custom;
  String? currentCustomLink;

  ContentLinks.fromJson(Map<String, dynamic> json) {
    back = json['back'] != null ? json['back'].cast<String>() : null;
    forward = json['forward'] != null ? json['forward'].cast<String>() : null;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'back': back,
      'forward': forward,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }
}

class CustomLink {
  String name;
  CustomLink({required this.name});

  List<String>? back;
  List<UserLinks>? allBackLinks;
  List<String>? forward;
  List<UserLinks>? allForwardLinks;
}

class UserLinks {}
