class UserRepository {
  UserRepository._();

  static UserRepository? _instance;

  static UserRepository get instance => _instance ??= UserRepository._();

  // ..... VALUES ..............................................................
  String? token;

// ..... GETTERS/SETTERS .....................................................
}
