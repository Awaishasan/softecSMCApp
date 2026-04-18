import 'package:get/get.dart';

import '../../views/auth_view/login_view.dart';

class AppRoute {

  static final LOGIN = '/login';
  static final SigUp = '/SigUp';
  static final Dashboard = '/DashBoard';


}

class pageRoute {
  static final pages =[
    GetPage(name: AppRoute.LOGIN, page: ()=> LoginView()),
  ];
}