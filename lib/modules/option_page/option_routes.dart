import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:thingsboard_app/config/routes/router.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/modules/option_page/option_page.dart';

class OptionRoute extends TbRoutes {
  late var testingHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    var searchMode = params['search']?.first == 'true';
    return OptionPage(tbContext, searchMode: searchMode);
  });
  OptionRoute(TbContext tbContext) : super(tbContext);
  @override
  void doRegisterRoutes(router) {
    router.define("/option", handler: testingHandler);
  }
}
