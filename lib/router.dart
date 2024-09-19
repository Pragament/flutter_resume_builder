import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:resume_builder_app/auth_provider.dart';
import 'package:resume_builder_app/error_screen.dart';
import 'package:resume_builder_app/routes.dart';

final routerProvider = Provider(
  (ref) {
    final auth = ref.watch(authProvider);
    return GoRouter(
      refreshListenable: auth,
      redirect: (context, state) => auth.redirect(state: state),
      errorPageBuilder: (context, state) =>
          const MaterialPage(child: ErrorScreen()),
      initialLocation: '/',
      routes: routes,
    );
  },
);
