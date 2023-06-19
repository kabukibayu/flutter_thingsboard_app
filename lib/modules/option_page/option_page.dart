
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_app/core/entity/entities_base.dart';

import 'package:thingsboard_app/widgets/tb_app_bar.dart';
import 'package:thingsboard_client/thingsboard_client.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class OptionPage extends TbPageWidget {
  final bool searchMode;

  OptionPage(TbContext tbContext, {this.searchMode = false})
      : super(tbContext);

  @override
  _OptionPageState createState() => _OptionPageState();
}

class _OptionPageState extends TbPageState<OptionPage> {
  final PageLinkController _pageLinkController = PageLinkController();
  late final ThingsboardClient tbClient;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
  bool alarmPintu = true;
  bool alarmJendela = true;
  bool visibleWarning = false;


  @override
  void initState() {
    super.initState();
    getData();
    tbClient = widget.tbContext.tbClient;
  }

  

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget appBar;
    if (widget.searchMode) {
      appBar = TbAppSearchBar(
        tbContext,
        onSearch: (searchText) => _pageLinkController.onSearchText(searchText),
      );
    } else {
      appBar = TbAppBar(tbContext, title: Text("Pengaturan Alarm"), actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            navigateTo('/assets?search=true');
          },
        )
      ]);
    }
    return Scaffold(
        appBar: appBar,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Alarm Aktif', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Alarm Jendela'),
                          Switch(
                            value: alarmJendela,
                            activeColor: Color.fromRGBO(74, 134, 232, 1),
                            onChanged: (bool value) async {
                              setState(() {
                                alarmJendela = value;
                                visibleWarning = true;
                                setData(0, value);
                              });
                            },
                          )
                        ],
                      ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Alarm Pintu'),
                          Switch(
                            value: alarmPintu,
                            activeColor: Color.fromRGBO(74, 134, 232, 1),
                            onChanged: (bool value) async {
                              setState(() {
                                alarmPintu = value;
                                visibleWarning = true;
                                setData(1, value);
                              });
                            },
                          )
                        ],
                      ),
            ),
            visibleWarning ? Text("Silahkan restart aplikasi setelah melakukan perubahan pengaturan", style: TextStyle(color: Colors.red),) : SizedBox()
            ],
          ),
        ),
        );
  }

  



  @override
  void dispose() {
    _pageLinkController.dispose();
    super.dispose();
  }
  
  Future<void> getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      alarmJendela = (prefs.getBool('alarmJendela') ?? true);
      alarmPintu = (prefs.getBool('alarmPintu') ?? true);
    });  
  }

  Future<void> setData(int data, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (data){
      case 0: prefs.setBool('alarmJendela', value);
      break;
      case 1: prefs.setBool('alarmPintu', value);
      break;
    }
  }
}
