import 'package:stashmobile/routing/app_router.dart';

enum ConnectedApps { hypothesis }

class Model {
  List<MenuItem> menuItems = [
    MenuItem(
      'Hypothes.is',
      'https://geoffcain.com/blog/wp-content/uploads/2019/06/hypothesistwittercard-150x150.png',
      AppRoutes.hypothesisSync,
    )
  ];
}

class MenuItem {
  String title;
  String logoUrl;
  String route;

  MenuItem(this.title, this.logoUrl, this.route);
}
