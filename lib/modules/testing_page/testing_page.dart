import 'dart:async';
import 'package:alarm/alarm.dart' as arlm;
import 'package:flutter/material.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_app/core/entity/entities_base.dart';
import 'package:thingsboard_app/modules/testing_page/ring.dart';
import 'package:thingsboard_app/widgets/tb_app_bar.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

class TestingPage extends TbPageWidget {
  final bool searchMode;

  TestingPage(TbContext tbContext, {this.searchMode = false})
      : super(tbContext);

  @override
  _TestingPageState createState() => _TestingPageState();
}

class _TestingPageState extends TbPageState<TestingPage> {
  final PageLinkController _pageLinkController = PageLinkController();
  late final ThingsboardClient tbClient;

  @override
  void initState() {
    super.initState();

    tbClient = widget.tbContext.tbClient;
    checkToken();
  }

  Future<void> navigateToRingScreen(arlm.AlarmSettings alarmSettings) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AlarmRingScreen(alarmSettings: alarmSettings),
        ));
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
      appBar = TbAppBar(tbContext, title: Text("Test"), actions: [
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
        body: FloatingActionButton(
          onPressed: () async {
            runAlarm();
          },
          backgroundColor: Colors.red,
          heroTag: null,
          child: const Text("RING NOW", textAlign: TextAlign.center),
        ));
  }

  void runAlarm() {
    final alarmSettings = arlm.AlarmSettings(
      id: 42,
      dateTime: DateTime.now(),
      assetAudioPath: 'assets/music/nokia.mp3',
    );
    arlm.Alarm.set(alarmSettings: alarmSettings);
    navigateToRingScreen(alarmSettings);
  }

  checkToken() async {
    await arlm.Alarm.init();
    // Specify the device ID for which you want to retrieve the latest telemetry data
    var deviceId = '1a2bf250-feca-11ed-9029-87706d0da53c';

    var entityId = DeviceId(deviceId);

    // Specify the keys of the timeseries data you want to retrieve
    var keys = ['WR', 'WL'];

// Use the getTelemetryService() method to access the TelemetryService
    var attributeService = tbClient.getAttributeService();
    webSocket();

// Keep the application running
    await Future.delayed(Duration(hours: 1));

    print('test: ${tbClient.getJwtToken()!}');
  }

  webSocket() {
    // Set up the entity filter to get all devices
    var entityFilter = EntityTypeFilter(entityType: EntityType.DEVICE);

    // Create the page link for entity data query
    var pageLink = EntityDataPageLink(pageSize: 10);

    // Create the entity query to fetch devices
    var devicesQuery =
        EntityDataQuery(entityFilter: entityFilter, pageLink: pageLink);
    tbClient
        .getEntityQueryService()
        .findEntityDataByQuery(devicesQuery)
        .then((devices) {
      // Check if there are any devices
      if (devices.data.isNotEmpty) {
        print(devices.data);

        // Calculate the time range for the last hour
        var currentTime = DateTime.now().millisecondsSinceEpoch;
        var timeWindow = Duration(hours: 1).inMilliseconds;

        // Create the time series command to get telemetry data
        var tsCmd = TimeSeriesCmd(
          keys: ['WR', 'WL', 'temperature'],
          startTs: currentTime - timeWindow,
          timeWindow: timeWindow,
        );

        // Create the entity data command with the entity query and time series command
        var cmd = EntityDataCmd(query: devicesQuery, tsCmd: tsCmd);

        // Get the telemetry service
        var telemetryService = tbClient.getTelemetryService();

        // Subscribe to entity updates
        var subscription = TelemetrySubscriber(telemetryService, [cmd]);
        telemetryService.subscribe(subscription);

        // Listen to entity data updates
        subscription.entityDataStream.listen((entityDataUpdate) {
          // Print the received entity data update
          try {
            print(
                'Received entity data update: ${entityDataUpdate.update![0].timeseries}');
            dynamic data = entityDataUpdate.update![0].timeseries;
            // Extract the "WR" value
            List<TsValue> wrValues = data["WR"];
            // Check if the "WR" value exists and is not empty
            if (wrValues != null && wrValues.isNotEmpty) {
              TsValue wrValue = wrValues.first;
              // Access the timestamp and value of "WR"
              int timestamp = wrValue.ts;
              dynamic value = wrValue.value;
              bool aktifAlarm = (value == 'true');
              print("Timestamp: $timestamp");
              if (aktifAlarm) {
                print("aktif alarm");
                runAlarm();
              }
            } else {
              print("No 'WR' value found");
            }
          } catch (e) {
            print(e);
          }
        });
      } else {
        print('No devices found.');
      }
    });
  }

  @override
  void dispose() {
    _pageLinkController.dispose();
    super.dispose();
  }
}
