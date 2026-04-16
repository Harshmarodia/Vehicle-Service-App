import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

void registerVideoFactory(String viewType, String? videoId) {
  // ignore: undefined_prefixed_name
  ui_web.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) {
      final html.IFrameElement iframe = html.IFrameElement()
        ..width = '100%'
        ..height = '100%'
        ..src = 'https://www.youtube.com/embed/${videoId ?? "6m3p8Xf9-5A"}?autoplay=1&controls=1&modestbranding=1&rel=0&iv_load_policy=3'
        ..style.border = 'none'
        ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
        ..allowFullscreen = true;
      return iframe;
    },
  );
}
