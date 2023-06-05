import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:thingsboard_app/config/routes/router.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/modules/testing_page/testing_page.dart';

class TestingRoute extends TbRoutes {
  late var testingHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    var searchMode = params['search']?.first == 'true';
    return TestingPage(tbContext, searchMode: searchMode);
  });
  TestingRoute(TbContext tbContext) : super(tbContext);
  @override
  void doRegisterRoutes(router) {
    router.define("/testing", handler: testingHandler);
  }
}
