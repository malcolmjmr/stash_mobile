

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/services/search.dart';

final searchProvider = Provider<SearchServices>((ref) => SearchServices());