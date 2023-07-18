import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/development/network.dart';

class DevelopmentViewModel extends ChangeNotifier {
  late TestNetwork network;
  BuildContext context;
  DevelopmentViewModel(this.context) {
    network = context.read(testNetworkProvider);
    createCommands();
  }

  late List<CommandViewModel> commands;
  createCommands() {
    commands = [
      CommandViewModel('Fetch Users', () async {
        await network.fetchUsers();
        print(network.users.keys);
      }),
      CommandViewModel('Create Users', () async {
        await network.createUsers(count: 20);
        await network.saveUsers();
      }),
      CommandViewModel('Delete Users', () => network.deleteUsers()),
      CommandViewModel(
          'Fetch posts', () async => await network.fetchPublicPosts()),
      CommandViewModel(
          'Delete posts', () async => await network.deletePublicPosts()),
      CommandViewModel('Create posts', () async {
        await network.createUserPosts();
      }),
      CommandViewModel(
          'Print Collections', () => print(network.collections.values)),
      CommandViewModel('Create Collections', () async {
        await network.createCollections(count: 100);
        print(network.collections);
      }),
      CommandViewModel(
          'Save Collections', () async => await network.saveCollections()),
      CommandViewModel('Delete Collections', () => network.deleteCollections()),
      CommandViewModel('Print Categories', () async {
        print(network.categories.values);
      }),
      CommandViewModel('Create Categories', () async {
        await network.createCategories(count: 50);
        print(network.categories.values);
      }),
      CommandViewModel(
        'Save Categories',
        () async => await network.saveCategories(),
      ),
      CommandViewModel('Delete Categories', () async {
        await network.deleteCategories();
        print(network.categories.values);
      }),
    ];
  }
}

class CommandViewModel {
  String name;
  Function() function;

  CommandViewModel(this.name, this.function);
}
