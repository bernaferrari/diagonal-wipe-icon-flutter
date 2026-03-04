import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_symbols_icons/symbols_map.dart';
import 'src/material_symbol_name.dart';

class _MaterialSymbolLookup {
  const _MaterialSymbolLookup(this.iconData, this.iconCode);

  final IconData iconData;
  final String iconCode;
}

const _MaterialSymbolLookup _fallback = _MaterialSymbolLookup(
  Symbols.auto_awesome,
  'Symbols.auto_awesome',
);

String _toSymbolLookupKey(String symbolName) {
  final buffer = StringBuffer();

  for (var i = 0; i < symbolName.length; i++) {
    final char = symbolName[i];
    if (i > 0 &&
        char.codeUnitAt(0) >= 65 &&
        char.codeUnitAt(0) <= 90 &&
        symbolName[i - 1] != '_' &&
        (symbolName[i + 1 >= symbolName.length ? i : i + 1] != '_') &&
        (symbolName[i - 1].toLowerCase() == symbolName[i - 1] ||
            (i + 1 < symbolName.length &&
                symbolName[i + 1].toLowerCase() == symbolName[i + 1]))) {
      buffer.write('_');
    }
    buffer.write(char.toLowerCase());
  }

  return buffer.toString();
}

_MaterialSymbolLookup? _resolveBySymbolLookup(String symbolName) {
  final normalized = _toSymbolLookupKey(symbolName);
  final direct = materialSymbolsMap[normalized];
  if (direct != null) {
    return _MaterialSymbolLookup(direct, 'Symbols.$normalized');
  }

  const aliases = {
    'account_circle_off': 'account_circle_off',
    'format_paint_off': 'format_paint',
    'graphic_eq_off': 'graphic_eq',
    'text_ad_off': 'text_ad',
    'vr180_create2d_off': 'vr180_create2d',
    'grid_3x3_off': 'grid_3x3',
    'grid_3x3': 'grid_3x3',
  };
  for (final entry in aliases.entries) {
    if (normalized == entry.key) {
      final aliased = materialSymbolsMap[entry.value];
      if (aliased != null) {
        return _MaterialSymbolLookup(aliased, 'Symbols.${entry.value}');
      }
    }
  }

  return null;
}

const Map<String, _MaterialSymbolLookup> _materialSymbolIconMap = {
  'AccountCircle': _MaterialSymbolLookup(
    Symbols.account_circle,
    'Symbols.account_circle',
  ),
  'AccountCircleOff': _MaterialSymbolLookup(
    Symbols.account_circle_off,
    'Symbols.account_circle_off',
  ),
  'AutoStories': _MaterialSymbolLookup(
    Symbols.auto_stories,
    'Symbols.auto_stories',
  ),
  'BluetoothDisabled': _MaterialSymbolLookup(
    Symbols.bluetooth_disabled,
    'Symbols.bluetooth_disabled',
  ),
  'ContentCopy': _MaterialSymbolLookup(
    Symbols.content_copy,
    'Symbols.content_copy',
  ),
  'DirectionsBus': _MaterialSymbolLookup(
    Symbols.directions_bus,
    'Symbols.directions_bus',
  ),
  'DoNotDisturbOn': _MaterialSymbolLookup(
    Symbols.do_not_disturb_on,
    'Symbols.do_not_disturb_on',
  ),
  'DoNotDisturbOff': _MaterialSymbolLookup(
    Symbols.do_not_disturb_off,
    'Symbols.do_not_disturb_off',
  ),
  'DomainVerification': _MaterialSymbolLookup(
    Symbols.domain_verification,
    'Symbols.domain_verification',
  ),
  'Grid3x3': _MaterialSymbolLookup(
    Symbols.grid_3x3,
    'Symbols.grid_3x3',
  ),
  'Grid3x3Off': _MaterialSymbolLookup(
    Symbols.grid_3x3_off,
    'Symbols.grid_3x3_off',
  ),
  'FileDownload': _MaterialSymbolLookup(
    Symbols.file_download,
    'Symbols.file_download',
  ),
  'FlashlightOn': _MaterialSymbolLookup(
    Symbols.flashlight_on,
    'Symbols.flashlight_on',
  ),
  'FlashlightOff': _MaterialSymbolLookup(
    Symbols.flashlight_off,
    'Symbols.flashlight_off',
  ),
  'Hourglass': _MaterialSymbolLookup(
    Symbols.hourglass,
    'Symbols.hourglass',
  ),
  'HearingAidDisabledLeft': _MaterialSymbolLookup(
    Symbols.hearing_aid_disabled_left,
    'Symbols.hearing_aid_disabled_left',
  ),
  'HourglassDisabled': _MaterialSymbolLookup(
    Symbols.hourglass_disabled,
    'Symbols.hourglass_disabled',
  ),
  'InvertColors': _MaterialSymbolLookup(
    Symbols.invert_colors,
    'Symbols.invert_colors',
  ),
  'InvertColorsOff': _MaterialSymbolLookup(
    Symbols.invert_colors_off,
    'Symbols.invert_colors_off',
  ),
  'LocationOff': _MaterialSymbolLookup(
    Symbols.location_off,
    'Symbols.location_off',
  ),
  'LocationSearching': _MaterialSymbolLookup(
    Symbols.location_searching,
    'Symbols.location_searching',
  ),
  'MailOff': _MaterialSymbolLookup(
    Symbols.mail_off,
    'Symbols.mail_off',
  ),
  'NoMeetingRoom': _MaterialSymbolLookup(
    Symbols.no_meeting_room,
    'Symbols.no_meeting_room',
  ),
  'NoPhotography': _MaterialSymbolLookup(
    Symbols.no_photography,
    'Symbols.no_photography',
  ),
  'NotificationImportant': _MaterialSymbolLookup(
    Symbols.notification_important,
    'Symbols.notification_important',
  ),
  'NotificationAudioOff': _MaterialSymbolLookup(
    Symbols.notification_audio_off,
    'Symbols.notification_audio_off',
  ),
  'NotificationAudio': _MaterialSymbolLookup(
    Symbols.notification_audio,
    'Symbols.notification_audio',
  ),
  'Notifications': _MaterialSymbolLookup(
    Symbols.notifications,
    'Symbols.notifications',
  ),
  'NotificationsOff': _MaterialSymbolLookup(
    Symbols.notifications_off,
    'Symbols.notifications_off',
  ),
  'PersonAddDisabled': _MaterialSymbolLookup(
    Symbols.person_add_disabled,
    'Symbols.person_add_disabled',
  ),
  'PhoneEnabled': _MaterialSymbolLookup(
    Symbols.phone_enabled,
    'Symbols.phone_enabled',
  ),
  'PictureInPicture': _MaterialSymbolLookup(
    Symbols.picture_in_picture,
    'Symbols.picture_in_picture',
  ),
  'Power': _MaterialSymbolLookup(
    Symbols.power,
    'Symbols.power',
  ),
  'Password2': _MaterialSymbolLookup(
    Symbols.password_2,
    'Symbols.password_2',
  ),
  'Password2Off': _MaterialSymbolLookup(
    Symbols.password_2_off,
    'Symbols.password_2_off',
  ),
  'PrintDisabled': _MaterialSymbolLookup(
    Symbols.print_disabled,
    'Symbols.print_disabled',
  ),
  'ReceiptLong': _MaterialSymbolLookup(
    Symbols.receipt_long,
    'Symbols.receipt_long',
  ),
  'SelectWindow': _MaterialSymbolLookup(
    Symbols.select_window,
    'Symbols.select_window',
  ),
  'ShoppingCart': _MaterialSymbolLookup(
    Symbols.shopping_cart,
    'Symbols.shopping_cart',
  ),
  'SpeakerNotes': _MaterialSymbolLookup(
    Symbols.speaker_notes,
    'Symbols.speaker_notes',
  ),
  'SyncDisabled': _MaterialSymbolLookup(
    Symbols.sync_disabled,
    'Symbols.sync_disabled',
  ),
  'SyncSavedLocally': _MaterialSymbolLookup(
    Symbols.sync_saved_locally,
    'Symbols.sync_saved_locally',
  ),
  'SyncSavedLocallyOff': _MaterialSymbolLookup(
    Symbols.sync_saved_locally_off,
    'Symbols.sync_saved_locally_off',
  ),
  'UpdateDisabled': _MaterialSymbolLookup(
    Symbols.update_disabled,
    'Symbols.update_disabled',
  ),
  'VideoCameraFrontOff': _MaterialSymbolLookup(
    Symbols.video_camera_front_off,
    'Symbols.video_camera_front_off',
  ),
  'VideocamOff': _MaterialSymbolLookup(
    Symbols.videocam_off,
    'Symbols.videocam_off',
  ),
  'VideogameAsset': _MaterialSymbolLookup(
    Symbols.videogame_asset,
    'Symbols.videogame_asset',
  ),
  'VideogameAssetOff': _MaterialSymbolLookup(
    Symbols.videogame_asset_off,
    'Symbols.videogame_asset_off',
  ),
  'VisibilityOff': _MaterialSymbolLookup(
    Symbols.visibility_off,
    'Symbols.visibility_off',
  ),
  'VoiceSelectionOff': _MaterialSymbolLookup(
    Symbols.voice_selection_off,
    'Symbols.voice_selection_off',
  ),
  'Vr180Create2dOff': _MaterialSymbolLookup(
    Symbols.vr180_create2d_off,
    'Symbols.vr180_create2d_off',
  ),
  'WarningOff': _MaterialSymbolLookup(
    Symbols.warning_off,
    'Symbols.warning_off',
  ),
  'AdaptiveAudioMic': _MaterialSymbolLookup(
    Symbols.adaptive_audio_mic,
    'Symbols.adaptive_audio_mic',
  ),
  'AndroidCell4Bar': _MaterialSymbolLookup(
    Symbols.signal_cellular_4_bar,
    'Symbols.signal_cellular_4_bar',
  ),
  'AndroidCell4BarOff': _MaterialSymbolLookup(
    Symbols.signal_cellular_4_bar,
    'Symbols.signal_cellular_4_bar',
  ),
  'AndroidCell5Bar': _MaterialSymbolLookup(
    Symbols.signal_cellular_4_bar,
    'Symbols.signal_cellular_4_bar',
  ),
  'AndroidCell5BarOff': _MaterialSymbolLookup(
    Symbols.signal_cellular_4_bar,
    'Symbols.signal_cellular_4_bar',
  ),
  'AndroidWifi3Bar': _MaterialSymbolLookup(
    Symbols.signal_wifi_4_bar,
    'Symbols.signal_wifi_4_bar',
  ),
  'AndroidWifi3BarOff': _MaterialSymbolLookup(
    Symbols.signal_wifi_off,
    'Symbols.signal_wifi_off',
  ),
  'AndroidWifi4Bar': _MaterialSymbolLookup(
    Symbols.signal_wifi_4_bar,
    'Symbols.signal_wifi_4_bar',
  ),
  'AndroidWifi4BarOff': _MaterialSymbolLookup(
    Symbols.signal_wifi_off,
    'Symbols.signal_wifi_off',
  ),
  'ApprovalDelegation': _MaterialSymbolLookup(
    Symbols.approval_delegation,
    'Symbols.approval_delegation',
  ),
  'ApprovalDelegationOff': _MaterialSymbolLookup(
    Symbols.approval_delegation_off,
    'Symbols.approval_delegation_off',
  ),
  'AttachFileOff': _MaterialSymbolLookup(
    Symbols.attach_file_off,
    'Symbols.attach_file_off',
  ),
  'BacklightHighOff': _MaterialSymbolLookup(
    Symbols.backlight_high_off,
    'Symbols.backlight_high_off',
  ),
  'BidLandscapeDisabled': _MaterialSymbolLookup(
    Symbols.bid_landscape_disabled,
    'Symbols.bid_landscape_disabled',
  ),
  'ClosedCaption': _MaterialSymbolLookup(
    Symbols.closed_caption,
    'Symbols.closed_caption',
  ),
  'ClosedCaptionDisabled': _MaterialSymbolLookup(
    Symbols.closed_caption_disabled,
    'Symbols.closed_caption_disabled',
  ),
  'CommentsDisabled': _MaterialSymbolLookup(
    Symbols.comments_disabled,
    'Symbols.comments_disabled',
  ),
  'ContentPasteOff': _MaterialSymbolLookup(
    Symbols.content_paste_off,
    'Symbols.content_paste_off',
  ),
  'DesktopAccessDisabled': _MaterialSymbolLookup(
    Symbols.desktop_access_disabled,
    'Symbols.desktop_access_disabled',
  ),
  'DesktopWindows': _MaterialSymbolLookup(
    Symbols.desktop_windows,
    'Symbols.desktop_windows',
  ),
  'DetectionAndZone': _MaterialSymbolLookup(
    Symbols.detection_and_zone,
    'Symbols.detection_and_zone',
  ),
  'DetectionAndZoneOff': _MaterialSymbolLookup(
    Symbols.detection_and_zone_off,
    'Symbols.detection_and_zone_off',
  ),
  'DeveloperBoard': _MaterialSymbolLookup(
    Symbols.developer_board,
    'Symbols.developer_board',
  ),
  'DeveloperBoardOff': _MaterialSymbolLookup(
    Symbols.developer_board_off,
    'Symbols.developer_board_off',
  ),
  'DomainVerificationOff': _MaterialSymbolLookup(
    Symbols.domain_verification_off,
    'Symbols.domain_verification_off',
  ),
  'EmergencyShareOff': _MaterialSymbolLookup(
    Symbols.emergency_share_off,
    'Symbols.emergency_share_off',
  ),
  'ExtensionOff': _MaterialSymbolLookup(
    Symbols.extension_off,
    'Symbols.extension_off',
  ),
  'FileDownloadOff': _MaterialSymbolLookup(
    Symbols.file_download_off,
    'Symbols.file_download_off',
  ),
  'FontDownloadOff': _MaterialSymbolLookup(
    Symbols.font_download_off,
    'Symbols.font_download_off',
  ),
  'FormatPaintOff': _MaterialSymbolLookup(
    Symbols.format_paint,
    'Symbols.format_paint',
  ),
  'FormatQuoteOff': _MaterialSymbolLookup(
    Symbols.format_quote_off,
    'Symbols.format_quote_off',
  ),
  'HearingDisabled': _MaterialSymbolLookup(
    Symbols.hearing_disabled,
    'Symbols.hearing_disabled',
  ),
  'LocationDisabled': _MaterialSymbolLookup(
    Symbols.location_disabled,
    'Symbols.location_disabled',
  ),
  'MediaBluetoothOff': _MaterialSymbolLookup(
    Symbols.media_bluetooth_off,
    'Symbols.media_bluetooth_off',
  ),
  'MediaBluetoothOn': _MaterialSymbolLookup(
    Symbols.media_bluetooth_on,
    'Symbols.media_bluetooth_on',
  ),
  'Mobiledata': _MaterialSymbolLookup(
    Symbols.one_x_mobiledata,
    'Symbols.one_x_mobiledata',
  ),
  'MobiledataArrows': _MaterialSymbolLookup(
    Symbols.one_x_mobiledata,
    'Symbols.one_x_mobiledata',
  ),
  'MobiledataOff': _MaterialSymbolLookup(
    Symbols.mobiledata_off,
    'Symbols.mobiledata_off',
  ),
  'MicExternalOff': _MaterialSymbolLookup(
    Symbols.mic_external_off,
    'Symbols.mic_external_off',
  ),
  'MicExternalOn': _MaterialSymbolLookup(
    Symbols.mic_external_on,
    'Symbols.mic_external_on',
  ),
  'MobileHandLeftOff': _MaterialSymbolLookup(
    Symbols.mobile_hand_left_off,
    'Symbols.mobile_hand_left_off',
  ),
  'NoiseControlOff': _MaterialSymbolLookup(
    Symbols.noise_control_off,
    'Symbols.noise_control_off',
  ),
  'NoiseControlOn': _MaterialSymbolLookup(
    Symbols.noise_control_on,
    'Symbols.noise_control_on',
  ),
  'PictureInPictureOff': _MaterialSymbolLookup(
    Symbols.picture_in_picture_off,
    'Symbols.picture_in_picture_off',
  ),
  'ShoppingCartOff': _MaterialSymbolLookup(
    Symbols.shopping_cart_off,
    'Symbols.shopping_cart_off',
  ),
  'SpeakerNotesOff': _MaterialSymbolLookup(
    Symbols.speaker_notes_off,
    'Symbols.speaker_notes_off',
  ),
  'SupervisedUserCircle': _MaterialSymbolLookup(
    Symbols.supervised_user_circle,
    'Symbols.supervised_user_circle',
  ),
  'SupervisedUserCircleOff': _MaterialSymbolLookup(
    Symbols.supervised_user_circle_off,
    'Symbols.supervised_user_circle_off',
  ),
  'WifiTetheringOff': _MaterialSymbolLookup(
    Symbols.wifi_tethering_off,
    'Symbols.wifi_tethering_off',
  ),
};

final Map<MaterialSymbolName, _MaterialSymbolLookup> _materialSymbolIconByName =
    {
  for (final entry in _materialSymbolIconMap.entries)
    MaterialSymbolName.of(entry.key): entry.value,
};

_MaterialSymbolLookup _resolveSymbolIcon(MaterialSymbolName symbolName) {
  final normalized = symbolName.catalogName.trim();
  final direct = _materialSymbolIconByName[symbolName];
  if (direct != null) return direct;

  final directAlias = _materialSymbolIconMap[normalized];
  if (directAlias != null) return directAlias;

  final inferred = _resolveBySymbolLookup(normalized);
  if (inferred != null) {
    return inferred;
  }

  return _fallback;
}

_MaterialSymbolLookup _resolveSymbolIconByCatalogName(String catalogName) {
  return _resolveSymbolIcon(MaterialSymbolName.of(catalogName));
}

IconData materialSymbolIconData(MaterialSymbolName symbolName) {
  return _resolveSymbolIconByCatalogName(symbolName.catalogName).iconData;
}

String materialSymbolIconCode(MaterialSymbolName symbolName) {
  return _resolveSymbolIconByCatalogName(symbolName.catalogName).iconCode;
}

extension MaterialSymbolNameIconData on MaterialSymbolName {
  IconData get iconData => materialSymbolIconData(this);

  String get iconCode => materialSymbolIconCode(this);
}
