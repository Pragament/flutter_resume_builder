//
//
// class Routes{
//
//   static GoRouter getAppRoutes(BuildContext context){
//     final GoRouter _router = GoRouter(
//       routes: <RouteBase>[
//         GoRoute(
//           path: '/',
//           builder: (BuildContext context, GoRouterState state) {
//             return HomeScreen();
//           },
//           routes: <RouteBase>[
//             GoRoute(
//               path: RouteNames.chartScreen,
//               builder: (BuildContext context, GoRouterState state) {
//                 return ChartScreen();
//               },
//             ),
//           ],
//         ),
//       ],
//     );
//     return _router;
//   } 
// }
import 'package:flutter/material.dart';
import 'package:resume_builder_app/views/home_screen.dart'; // Import HomeScreen
import 'package:resume_builder_app/views/settings.dart';
import 'package:resume_builder_app/utils/routes/route_names.dart'; // Import SettingsScreen

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.homeScreen:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case RouteNames.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
