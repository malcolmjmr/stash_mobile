// // 1. Import this:
// import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:flutter/foundation.dart';
// import 'package:stashmobile/models/user/model.dart';

// // 2. Declare this:
// part 'session_state.freezed.dart';

// // 3. Annotate the class with @freezed
// @freezed
// // 4. Declare the class as abstract and add `with _$ClassName`
// abstract class SessionState with _$SessionState {
//   // 5. Create a `const factory` constructor for each valid state
//   const factory SessionState.loggedOut() = _LoggedOut;
//   const factory SessionState.loggedIn(User user) = _LoggedIn;
// }
