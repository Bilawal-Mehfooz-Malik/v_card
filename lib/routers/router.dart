import 'package:go_router/go_router.dart';
import 'package:v_card/screens/details_screen.dart';
import 'package:v_card/screens/form_screen.dart';
import 'package:v_card/screens/home_screen.dart';
import 'package:v_card/screens/camera_screen.dart';
import 'package:v_card/screens/preview_screen.dart';
import 'package:v_card/screens/scanned_screen.dart';

final router = GoRouter(
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: HomeScreen.routeName,
      name: HomeScreen.routeName,
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: DetailsScreen.routeName,
          name: DetailsScreen.routeName,
          builder: (context, state) {
            final i = state.extra! as int;
            return DetailsScreen(id: i);
          },
        ),
        GoRoute(
          path: CameraScreen.routeName,
          name: CameraScreen.routeName,
          builder: (context, state) {
            return const CameraScreen();
          },
        ),
        GoRoute(
          name: PreviewScreen.routeName,
          path: PreviewScreen.routeName,
          builder: (context, state) {
            return const PreviewScreen();
          },
          routes: [
            GoRoute(
              name: ScannedScreen.routeName,
              path: ScannedScreen.routeName,
              builder: (context, state) {
                return const ScannedScreen();
              },
              routes: [
                GoRoute(
                  name: FormScreen.routeName,
                  path: FormScreen.routeName,
                  builder: (context, state) {
                    return const FormScreen();
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
