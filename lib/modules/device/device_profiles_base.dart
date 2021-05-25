import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:thingsboard_app/constants/assets_path.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_app/core/entity/entities_base.dart';
import 'package:thingsboard_app/utils/services/device_profile_cache.dart';
import 'package:thingsboard_app/utils/services/entity_query_api.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

mixin DeviceProfilesBase on EntitiesBase<DeviceProfileInfo, PageLink> {

  final RefreshDeviceCounts refreshDeviceCounts = RefreshDeviceCounts();

  @override
  String get title => 'Devices';

  @override
  String get noItemsFoundText => 'No devices found';

  @override
  Future<PageData<DeviceProfileInfo>> fetchEntities(PageLink pageLink) {
    return DeviceProfileCache.getDeviceProfileInfos(tbClient, pageLink);
  }

  @override
  void onEntityTap(DeviceProfileInfo deviceProfile) {
    navigateTo('/deviceList?deviceType=${deviceProfile.name}');
  }

  @override
  Future<void> onRefresh() {
    if (refreshDeviceCounts.onRefresh != null) {
      return refreshDeviceCounts.onRefresh!();
    } else {
      return Future.value();
    }
  }

  @override
  Widget? buildHeading(BuildContext context) {
    return AllDevicesCard(tbContext, refreshDeviceCounts);
  }

  @override
  Widget buildEntityGridCard(BuildContext context, DeviceProfileInfo deviceProfile) {
    return DeviceProfileCard(tbContext, deviceProfile);
  }

}

class RefreshDeviceCounts {
  Future<void> Function()? onRefresh;
}

class AllDevicesCard extends TbContextWidget<AllDevicesCard, _AllDevicesCardState> {

  final RefreshDeviceCounts refreshDeviceCounts;

  AllDevicesCard(TbContext tbContext, this.refreshDeviceCounts) : super(tbContext);

  @override
  _AllDevicesCardState createState() => _AllDevicesCardState();

}

class _AllDevicesCardState extends TbContextState<AllDevicesCard, _AllDevicesCardState> {

  final StreamController<int?> _activeDevicesCount = StreamController.broadcast();
  final StreamController<int?> _inactiveDevicesCount = StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    widget.refreshDeviceCounts.onRefresh = _countDevices;
    _countDevices();
  }

  @override
  void dispose() {
    _activeDevicesCount.close();
    _inactiveDevicesCount.close();
    super.dispose();
  }

  Future<void> _countDevices() {
    _activeDevicesCount.add(null);
    _inactiveDevicesCount.add(null);
    Future<int> activeDevicesCount = EntityQueryApi.countDevices(tbClient, active: true);
    Future<int> inactiveDevicesCount = EntityQueryApi.countDevices(tbClient, active: false);
    Future<List<int>> countsFuture = Future.wait([activeDevicesCount, inactiveDevicesCount]);
    countsFuture.then((counts) {
      _activeDevicesCount.add(counts[0]);
      _inactiveDevicesCount.add(counts[1]);
    });
    return countsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return
      GestureDetector(
          behavior: HitTestBehavior.opaque,
          child:
          Container(
            child: Card(
                color: Theme.of(tbContext.currentState!.context).colorScheme.primary,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                child: Column(
                  children: [
                    Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('All devices',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  height: 20 / 14
                              )
                          ),
                          Icon(Icons.arrow_forward, color: Colors.white)
                        ],
                      )
                    ),
                    Padding(padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Flexible(fit: FlexFit.tight,
                              child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:  BorderRadius.circular(4),
                                      ),
                                      child: StreamBuilder<int?>(
                                        stream: _activeDevicesCount.stream,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            var deviceCount = snapshot.data!;
                                            return _buildDeviceCount(context, true, deviceCount, displayStatusText: true);
                                          } else {
                                            return Center(child:
                                            Container(height: 20, width: 20,
                                                child: CircularProgressIndicator(
                                                    valueColor: AlwaysStoppedAnimation(Theme.of(tbContext.currentState!.context).colorScheme.primary),
                                                    strokeWidth: 2.5)));
                                          }
                                        },
                                      )
                                  ),
                                  onTap: () {
                                    navigateTo('/deviceList?active=true');
                                  }
                              ),
                            ),
                            SizedBox(width: 4),
                            Flexible(fit: FlexFit.tight,
                              child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:  BorderRadius.circular(4),
                                      ),
                                      child: StreamBuilder<int?>(
                                        stream: _inactiveDevicesCount.stream,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            var deviceCount = snapshot.data!;
                                            return _buildDeviceCount(context, false, deviceCount, displayStatusText: true);
                                          } else {
                                            return Center(child:
                                            Container(height: 20, width: 20,
                                                child: CircularProgressIndicator(
                                                    valueColor: AlwaysStoppedAnimation(Theme.of(tbContext.currentState!.context).colorScheme.primary),
                                                    strokeWidth: 2.5)));
                                          }
                                        },
                                      )
                                  ),
                                  onTap: () {
                                    navigateTo('/deviceList?active=false');
                                  }
                              ),
                            )
                          ],
                        )
                    )
                  ],
                )
            ),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 10.0,
                    offset: Offset(0, 4)
                ),
                BoxShadow(
                    color: Colors.black.withAlpha(18),
                    blurRadius: 30.0,
                    offset: Offset(0, 10)
                ),
              ],
            ),
          ),
          onTap: () {
            navigateTo('/deviceList');
          }
      );
  }

}

class DeviceProfileCard extends TbContextWidget<DeviceProfileCard, _DeviceProfileCardState> {

  final DeviceProfileInfo deviceProfile;

  DeviceProfileCard(TbContext tbContext, this.deviceProfile) : super(tbContext);

  @override
  _DeviceProfileCardState createState() => _DeviceProfileCardState();

}

class _DeviceProfileCardState extends TbContextState<DeviceProfileCard, _DeviceProfileCardState> {

  late Future<int> activeDevicesCount;
  late Future<int> inactiveDevicesCount;

  @override
  void initState() {
    super.initState();
    _countDevices();
  }

  @override
  void didUpdateWidget(DeviceProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _countDevices();
  }

  _countDevices() {
    activeDevicesCount = EntityQueryApi.countDevices(tbClient, deviceType: widget.deviceProfile.name, active: true);
    inactiveDevicesCount = EntityQueryApi.countDevices(tbClient, deviceType: widget.deviceProfile.name, active: false);
  }

  @override
  Widget build(BuildContext context) {
    var entity = widget.deviceProfile;
    var hasImage = entity.image != null;
    Widget image;
    if (hasImage) {
      var uriData = UriData.parse(entity.image!);
      image = Image.memory(uriData.contentAsBytes());
    } else {
      image = Image.asset(ThingsboardImage.deviceProfilePlaceholder);
    }
    return
      ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: image,
                  )
              ),
              hasImage ? Positioned.fill(
                child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x00000000),
                              Color(0xb7000000)
                            ],
                            stops: [0.4219, 1]
                        )
                    )
                ),
              ) : Container(),
              Positioned(
                  bottom: 56,
                  left: 16,
                  right: 16,
                  child: AutoSizeText(entity.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    minFontSize: 8,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: hasImage ? Colors.white : Color(0xFF282828),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        height: 20 / 14
                    ),
                  )
              ),
              Positioned(
                  bottom: 4,
                  left: 4,
                  right: 4,
                  height: 40,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(fit: FlexFit.tight,
                        child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:  BorderRadius.circular(4),
                                ),
                                child: FutureBuilder<int>(
                                  future: activeDevicesCount,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                                      var deviceCount = snapshot.data!;
                                      return _buildDeviceCount(context, true, deviceCount);
                                    } else {
                                      return Center(child:
                                                Container(height: 20, width: 20,
                                                    child: CircularProgressIndicator(
                                                        valueColor: AlwaysStoppedAnimation(Theme.of(tbContext.currentState!.context).colorScheme.primary),
                                                        strokeWidth: 2.5)));
                                    }
                                  },
                                )
                            ),
                            onTap: () {
                               navigateTo('/deviceList?active=true&deviceType=${entity.name}');
                            }
                        ),
                      ),
                      SizedBox(width: 4),
                      Flexible(fit: FlexFit.tight,
                          child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:  BorderRadius.circular(4),
                                  ),
                                  child: FutureBuilder<int>(
                                    future: inactiveDevicesCount,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                                        var deviceCount = snapshot.data!;
                                        return _buildDeviceCount(context, false, deviceCount);
                                      } else {
                                        return Center(child:
                                        Container(height: 20, width: 20,
                                            child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation(Theme.of(tbContext.currentState!.context).colorScheme.primary),
                                                strokeWidth: 2.5)));
                                      }
                                    },
                                  )
                              ),
                              onTap: () {
                                navigateTo('/deviceList?active=false&deviceType=${entity.name}');
                              }
                          ),
                      ),
                    ],
                  )
              )
            ],
          )
      );
  }
}

Widget _buildDeviceCount(BuildContext context, bool active, int count, {bool displayStatusText = false}) {
  Color color = active ? Color(0xFF008A00) : Color(0xFFAFAFAF);
  return Padding(
    padding: EdgeInsets.all(12),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Stack(
              children: [
                Icon(Icons.devices_other, size: 16, color: color),
                if (!active) CustomPaint(
                  size: Size.square(16),
                  painter: StrikeThroughPainter(color: color, offset: 2),
                )
              ],
            ),
            if (displayStatusText)
              SizedBox(width: 8.67),
            if (displayStatusText)
              Text(active ? 'Active' : 'Inactive', style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 16 / 12,
                  color: color
              ))
          ],
        ),
        Text(count.toString(), style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 16 / 12,
            color: color
        ))
      ],
    ),
  );
}

class StrikeThroughPainter extends CustomPainter {

  final Color color;
  final double offset;

  StrikeThroughPainter({required this.color, this.offset = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    paint.strokeWidth = 1.5;
    canvas.drawLine(Offset(offset, offset), Offset(size.width - offset, size.height - offset), paint);
    paint.color = Colors.white;
    canvas.drawLine(Offset(2, 0), Offset(size.width + 2, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant StrikeThroughPainter oldDelegate) {
    return color != oldDelegate.color;
  }

}