import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

enum RequestResource { camera, storage, microphone, locationWhenInUse }

class PermissionServices {
  static Future<void> openSettings() async {
    await openAppSettings();
  }

  static Future<bool> requestPermission(RequestResource requestResource) async {
    if (kIsWeb) return false;
    switch (requestResource) {
      case RequestResource.camera:
        return await checkPermission(Permission.camera);
      case RequestResource.storage:
        if (Platform.isIOS) {
          return await checkPermission(Permission.photos);
        } else if (Platform.isAndroid) {
          return await checkMultiPermission([Permission.storage, Permission.photos]);
        } else {
          throw UnimplementedError();
        }
      case RequestResource.microphone:
        return await checkPermission(Permission.microphone);
      case RequestResource.locationWhenInUse:
        return await checkPermission(Permission.locationWhenInUse);
    }
  }

  static Future<bool> checkPermission(Permission permission) async {
    return await processRequest(
      await permission.status,
      retry: () async => (await [permission].request()).values.first,
    );
  }

  static Future<bool> checkMultiPermission(List<Permission> permission) async {
    return await processRequest(
      combineStatus((await permission.request()).values),
      retry: () async => combineStatus((await permission.request()).values),
    );
  }

  static Future<bool> processRequest(
    PermissionStatus status, {
    FutureOr<PermissionStatus> Function()? retry,
  }) async {
    switch (status) {
      case PermissionStatus.granted:
        return true;

      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        return false;

      default:
        if (retry == null) {
          return false;
        } else {
          return await processRequest(await retry());
        }
    }
  }

  static PermissionStatus combineStatus(Iterable<PermissionStatus> status) {
    return status.reduce((value, element) {
      if (value == element) {
        return value;
      } else if (value == PermissionStatus.permanentlyDenied ||
          element == PermissionStatus.permanentlyDenied) {
        return PermissionStatus.permanentlyDenied;
      } else if (value == PermissionStatus.restricted || element == PermissionStatus.restricted) {
        return PermissionStatus.restricted;
      } else if (value == PermissionStatus.provisional || element == PermissionStatus.provisional) {
        return PermissionStatus.provisional;
      } else {
        return PermissionStatus.denied;
      }
    });
  }
}
