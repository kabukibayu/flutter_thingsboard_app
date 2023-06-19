import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/modules/main/main_page.dart';

class AlarmRingScreen extends StatelessWidget {
  final AlarmSettings alarmSettings;
  final TbContext tbContext;
  final String title;

  const AlarmRingScreen({Key? key, required this.alarmSettings, required this.tbContext, required this.title})
      : super(key: key);
      

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text("🔔", style: TextStyle(fontSize: 50)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RawMaterialButton(
                  onPressed: () {
                    Alarm.stop(alarmSettings.id)
                        .then((_) => Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => MainPage(tbContext, path: '/alarms'))));
                  },
                  child: Text(
                    "Alarm Page",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                RawMaterialButton(
                  onPressed: () {
                    Alarm.stop(alarmSettings.id)
                        .then((_) => Navigator.pop(context));
                  },
                  child: Text(
                    "Stop",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
