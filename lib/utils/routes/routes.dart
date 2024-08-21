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