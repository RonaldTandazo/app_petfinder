import 'package:app_petfinder/core/utils/image_url_helper.dart';
import 'package:app_petfinder/features/community/screens/post_detail_screen.dart';
import 'package:app_petfinder/features/community/screens/post_form_screen.dart';
import 'package:app_petfinder/models/community/community_author_model.dart';
import 'package:app_petfinder/models/community/post_image_model.dart';
import 'package:app_petfinder/models/community/post_model.dart';
import 'package:app_petfinder/widgets/images/app_full_screen_gallery.dart';
import 'package:go_router/go_router.dart';

class CommunityRoutes {
  static const String prefix = '/community';

  static const String postDetail = '$prefix/detail';
  static const String postCreate = '$prefix/create';
  static const String postEdit = '$prefix/edit';
  static const String postImageViewer = '$prefix/image-viewer';

  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: postDetail,
        builder: (context, state) {
          final extra =
              state.extra as (PostModel, CommunityAuthorModel?, void Function(PostModel)?)?;
          return PostDetailScreen(
            post: extra?.$1,
            me: extra?.$2,
            onPostChanged: extra?.$3,
          );
        },
      ),
      GoRoute(
        path: postCreate,
        builder: (context, state) => const PostFormScreen(),
      ),
      GoRoute(
        path: postEdit,
        builder: (context, state) => PostFormScreen(post: state.extra as PostModel?),
      ),
      GoRoute(
        path: postImageViewer,
        builder: (context, state) {
          final extra = state.extra as (List<PostImageModel>, int)?;
          final pictures = (extra?.$1 ?? const <PostImageModel>[])
              .map((image) => ImageUrlHelper.resolve(image.url ?? ''))
              .where((url) => url.isNotEmpty)
              .toList();
          final initialIndex = extra?.$2 ?? 0;

          return AppFullScreenGallery(
            pictures: pictures,
            initialIndex: pictures.isEmpty ? 0 : (initialIndex < pictures.length ? initialIndex : pictures.length - 1),
          );
        },
      ),
    ];
  }
}