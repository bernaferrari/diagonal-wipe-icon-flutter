import 'package:flutter/foundation.dart';

import 'src/material_symbol_name.dart';

MaterialSymbolName _requiredSymbolName(String catalogName) {
  try {
    return MaterialSymbolName.of(catalogName);
  } on ArgumentError {
    throw ArgumentError.value(
      catalogName,
      'catalogName',
      'Unknown Material symbol name in catalog',
    );
  }
}

@immutable
class MaterialWipeIconPair {
  final String label;
  final MaterialSymbolName enabledIcon;
  final MaterialSymbolName disabledIcon;
  final MaterialSymbolName? enabledCodeIcon;
  final MaterialSymbolName? disabledCodeIcon;

  MaterialWipeIconPair({
    required this.label,
    required String enabledIconName,
    required String disabledIconName,
    String? enabledCodeIconName,
    String? disabledCodeIconName,
  })  : enabledIcon = _requiredSymbolName(enabledIconName),
        disabledIcon = _requiredSymbolName(disabledIconName),
        enabledCodeIcon = enabledCodeIconName == null
            ? null
            : _requiredSymbolName(enabledCodeIconName),
        disabledCodeIcon = disabledCodeIconName == null
            ? null
            : _requiredSymbolName(disabledCodeIconName);

  MaterialWipeIconPair.symbols({
    required String label,
    required MaterialSymbolName enabledIcon,
    required MaterialSymbolName disabledIcon,
    MaterialSymbolName? enabledCodeIcon,
    MaterialSymbolName? disabledCodeIcon,
  }) : this(
          label: label,
          enabledIconName: enabledIcon.catalogName,
          disabledIconName: disabledIcon.catalogName,
          enabledCodeIconName: enabledCodeIcon?.catalogName,
          disabledCodeIconName: disabledCodeIcon?.catalogName,
        );

  String get enabledIconName => enabledIcon.catalogName;

  String get disabledIconName => disabledIcon.catalogName;

  String? get enabledCodeIconName => enabledCodeIcon?.catalogName;

  String? get disabledCodeIconName => disabledCodeIcon?.catalogName;
}

@immutable
class MaterialWipeIconSection {
  final String title;
  final String subtitle;
  final List<MaterialWipeIconPair> icons;

  const MaterialWipeIconSection({
    required this.title,
    required this.subtitle,
    required this.icons,
  });
}

final List<MaterialWipeIconPair> coreMaterialWipeIconCatalog = [
  MaterialWipeIconPair(
    label: "Account Circle",
    enabledIconName: "AccountCircle",
    disabledIconName: "AccountCircleOff",
  ),
  MaterialWipeIconPair(
    label: "Ad",
    enabledIconName: "Ad",
    disabledIconName: "AdOff",
  ),
  MaterialWipeIconPair(
    label: "Ad Group",
    enabledIconName: "AdGroup",
    disabledIconName: "AdGroupOff",
  ),
  MaterialWipeIconPair(
    label: "Adaptive Audio Mic",
    enabledIconName: "AdaptiveAudioMic",
    disabledIconName: "AdaptiveAudioMicOff",
  ),
  MaterialWipeIconPair(
    label: "Alarm",
    enabledIconName: "Alarm",
    disabledIconName: "AlarmOff",
  ),
  MaterialWipeIconPair(
    label: "Android Cell 4 Bar",
    enabledIconName: "AndroidCell4Bar",
    disabledIconName: "AndroidCell4BarOff",
  ),
  MaterialWipeIconPair(
    label: "Android Cell 5 Bar",
    enabledIconName: "AndroidCell5Bar",
    disabledIconName: "AndroidCell5BarOff",
  ),
  MaterialWipeIconPair(
    label: "Android Wifi 4 Bar",
    enabledIconName: "AndroidWifi4Bar",
    disabledIconName: "AndroidWifi4BarOff",
  ),
  MaterialWipeIconPair(
    label: "Attach File",
    enabledIconName: "AttachFile",
    disabledIconName: "AttachFileOff",
  ),
  MaterialWipeIconPair(
    label: "Auto Stories",
    enabledIconName: "AutoStories",
    disabledIconName: "AutoStoriesOff",
  ),
  MaterialWipeIconPair(
    label: "Backlight High",
    enabledIconName: "BacklightHigh",
    disabledIconName: "BacklightHighOff",
  ),
  MaterialWipeIconPair(
    label: "Bar Chart",
    enabledIconName: "BarChart",
    disabledIconName: "BarChartOff",
  ),
  MaterialWipeIconPair(
    label: "Bid Landscape",
    enabledIconName: "BidLandscape",
    disabledIconName: "BidLandscapeDisabled",
  ),
  MaterialWipeIconPair(
    label: "Bluetooth",
    enabledIconName: "Bluetooth",
    disabledIconName: "BluetoothDisabled",
  ),
  MaterialWipeIconPair(
    label: "Blur",
    enabledIconName: "BlurOn",
    disabledIconName: "BlurOff",
    enabledCodeIconName: "BlurOn",
    disabledCodeIconName: "BlurOff",
  ),
  MaterialWipeIconPair(
    label: "Chat Bubble",
    enabledIconName: "ChatBubble",
    disabledIconName: "ChatBubbleOff",
  ),
  MaterialWipeIconPair(
    label: "Comment",
    enabledIconName: "Comment",
    disabledIconName: "CommentsDisabled",
    enabledCodeIconName: "Comment",
    disabledCodeIconName: "CommentsDisabled",
  ),
  MaterialWipeIconPair(
    label: "Closed Caption",
    enabledIconName: "ClosedCaption",
    disabledIconName: "ClosedCaptionDisabled",
  ),
  MaterialWipeIconPair(
    label: "Cloud",
    enabledIconName: "Cloud",
    disabledIconName: "CloudOff",
  ),
  MaterialWipeIconPair(
    label: "Code",
    enabledIconName: "Code",
    disabledIconName: "CodeOff",
  ),
  MaterialWipeIconPair(
    label: "Contactless",
    enabledIconName: "Contactless",
    disabledIconName: "ContactlessOff",
  ),
  MaterialWipeIconPair(
    label: "Content Paste",
    enabledIconName: "ContentPaste",
    disabledIconName: "ContentPasteOff",
  ),
  MaterialWipeIconPair(
    label: "Conversion Path",
    enabledIconName: "ConversionPath",
    disabledIconName: "ConversionPathOff",
  ),
  MaterialWipeIconPair(
    label: "Cookie",
    enabledIconName: "Cookie",
    disabledIconName: "CookieOff",
  ),
  MaterialWipeIconPair(
    label: "Credit Card",
    enabledIconName: "CreditCard",
    disabledIconName: "CreditCardOff",
  ),
  MaterialWipeIconPair(
    label: "Database",
    enabledIconName: "Database",
    disabledIconName: "DatabaseOff",
  ),
  MaterialWipeIconPair(
    label: "Detection And Zone",
    enabledIconName: "DetectionAndZone",
    disabledIconName: "DetectionAndZoneOff",
  ),
  MaterialWipeIconPair(
    label: "Developer Board",
    enabledIconName: "DeveloperBoard",
    disabledIconName: "DeveloperBoardOff",
  ),
  MaterialWipeIconPair(
    label: "Devices",
    enabledIconName: "Devices",
    disabledIconName: "DevicesOff",
  ),
  MaterialWipeIconPair(
    label: "Directions",
    enabledIconName: "Directions",
    disabledIconName: "DirectionsOff",
  ),
  MaterialWipeIconPair(
    label: "Directions Alt",
    enabledIconName: "DirectionsAlt",
    disabledIconName: "DirectionsAltOff",
  ),
  MaterialWipeIconPair(
    label: "Do Not Disturb",
    enabledIconName: "DoNotDisturbOn",
    disabledIconName: "DoNotDisturbOff",
    enabledCodeIconName: "DoNotDisturbOn",
    disabledCodeIconName: "DoNotDisturbOff",
  ),
  MaterialWipeIconPair(
    label: "Domain",
    enabledIconName: "Domain",
    disabledIconName: "DomainDisabled",
  ),
  MaterialWipeIconPair(
    label: "Domain Verification",
    enabledIconName: "DomainVerification",
    disabledIconName: "DomainVerificationOff",
  ),
  MaterialWipeIconPair(
    label: "Edit",
    enabledIconName: "Edit",
    disabledIconName: "EditOff",
  ),
  MaterialWipeIconPair(
    label: "Emergency Share",
    enabledIconName: "EmergencyShare",
    disabledIconName: "EmergencyShareOff",
  ),
  MaterialWipeIconPair(
    label: "Encrypted",
    enabledIconName: "Encrypted",
    disabledIconName: "EncryptedOff",
  ),
  MaterialWipeIconPair(
    label: "Enterprise",
    enabledIconName: "Enterprise",
    disabledIconName: "EnterpriseOff",
  ),
  MaterialWipeIconPair(
    label: "Explore",
    enabledIconName: "Explore",
    disabledIconName: "ExploreOff",
  ),
  MaterialWipeIconPair(
    label: "Extension",
    enabledIconName: "Extension",
    disabledIconName: "ExtensionOff",
  ),
  MaterialWipeIconPair(
    label: "File Copy",
    enabledIconName: "FileCopy",
    disabledIconName: "FileCopyOff",
  ),
  MaterialWipeIconPair(
    label: "File Download",
    enabledIconName: "FileDownload",
    disabledIconName: "FileDownloadOff",
  ),
  MaterialWipeIconPair(
    label: "File Save",
    enabledIconName: "FileSave",
    disabledIconName: "FileSaveOff",
  ),
  MaterialWipeIconPair(
    label: "File Upload",
    enabledIconName: "FileUpload",
    disabledIconName: "FileUploadOff",
  ),
  MaterialWipeIconPair(
    label: "Filter Alt",
    enabledIconName: "FilterAlt",
    disabledIconName: "FilterAltOff",
  ),
  MaterialWipeIconPair(
    label: "Filter List",
    enabledIconName: "FilterList",
    disabledIconName: "FilterListOff",
  ),
  MaterialWipeIconPair(
    label: "Fingerprint",
    enabledIconName: "Fingerprint",
    disabledIconName: "FingerprintOff",
  ),
  MaterialWipeIconPair(
    label: "Flash",
    enabledIconName: "FlashOn",
    disabledIconName: "FlashOff",
    enabledCodeIconName: "FlashOn",
    disabledCodeIconName: "FlashOff",
  ),
  MaterialWipeIconPair(
    label: "Flashlight",
    enabledIconName: "FlashlightOn",
    disabledIconName: "FlashlightOff",
    enabledCodeIconName: "FlashlightOn",
    disabledCodeIconName: "FlashlightOff",
  ),
  MaterialWipeIconPair(
    label: "Folder",
    enabledIconName: "Folder",
    disabledIconName: "FolderOff",
  ),
  MaterialWipeIconPair(
    label: "Font Download",
    enabledIconName: "FontDownload",
    disabledIconName: "FontDownloadOff",
  ),
  MaterialWipeIconPair(
    label: "Format Paint",
    enabledIconName: "FormatPaint",
    disabledIconName: "FormatPaintOff",
  ),
  MaterialWipeIconPair(
    label: "Format Quote",
    enabledIconName: "FormatQuote",
    disabledIconName: "FormatQuoteOff",
  ),
  MaterialWipeIconPair(
    label: "Frame Person",
    enabledIconName: "FramePerson",
    disabledIconName: "FramePersonOff",
  ),
  MaterialWipeIconPair(
    label: "Graphic Eq",
    enabledIconName: "GraphicEq",
    disabledIconName: "GraphicEqOff",
  ),
  MaterialWipeIconPair(
    label: "Grid",
    enabledIconName: "GridOn",
    disabledIconName: "GridOff",
    enabledCodeIconName: "GridOn",
    disabledCodeIconName: "GridOff",
  ),
  MaterialWipeIconPair(
    label: "Grid 3x3",
    enabledIconName: "Grid3x3",
    disabledIconName: "Grid3x3Off",
  ),
  MaterialWipeIconPair(
    label: "Group",
    enabledIconName: "Group",
    disabledIconName: "GroupOff",
  ),
  MaterialWipeIconPair(
    label: "Hangout Video",
    enabledIconName: "HangoutVideo",
    disabledIconName: "HangoutVideoOff",
  ),
  MaterialWipeIconPair(
    label: "Hdr",
    enabledIconName: "HdrOn",
    disabledIconName: "HdrOff",
    enabledCodeIconName: "HdrOn",
    disabledCodeIconName: "HdrOff",
  ),
  MaterialWipeIconPair(
    label: "Hdr Plus",
    enabledIconName: "HdrPlus",
    disabledIconName: "HdrPlusOff",
    enabledCodeIconName: "HdrPlus",
    disabledCodeIconName: "HdrPlusOff",
  ),
  MaterialWipeIconPair(
    label: "Headset",
    enabledIconName: "HeadsetMic",
    disabledIconName: "HeadsetOff",
    enabledCodeIconName: "HeadsetMic",
    disabledCodeIconName: "HeadsetOff",
  ),
  MaterialWipeIconPair(
    label: "Hearing Aid Left",
    enabledIconName: "HearingAid",
    disabledIconName: "HearingAidDisabledLeft",
    enabledCodeIconName: "HearingAid",
    disabledCodeIconName: "HearingAidDisabledLeft",
  ),
  MaterialWipeIconPair(
    label: "Hls",
    enabledIconName: "Hls",
    disabledIconName: "HlsOff",
  ),
  MaterialWipeIconPair(
    label: "Hourglass",
    enabledIconName: "Hourglass",
    disabledIconName: "HourglassDisabled",
  ),
  MaterialWipeIconPair(
    label: "Invert Colors",
    enabledIconName: "InvertColors",
    disabledIconName: "InvertColorsOff",
  ),
  MaterialWipeIconPair(
    label: "Key",
    enabledIconName: "Key",
    disabledIconName: "KeyOff",
  ),
  MaterialWipeIconPair(
    label: "Label",
    enabledIconName: "Label",
    disabledIconName: "LabelOff",
  ),
  MaterialWipeIconPair(
    label: "Link",
    enabledIconName: "Link",
    disabledIconName: "LinkOff",
  ),
  MaterialWipeIconPair(
    label: "Lightbulb",
    enabledIconName: "Lightbulb",
    disabledIconName: "LightOff",
    enabledCodeIconName: "Lightbulb",
    disabledCodeIconName: "LightOff",
  ),
  MaterialWipeIconPair(
    label: "Location",
    enabledIconName: "LocationOn",
    disabledIconName: "LocationOff",
    enabledCodeIconName: "LocationOn",
    disabledCodeIconName: "LocationOff",
  ),
  MaterialWipeIconPair(
    label: "Location Searching",
    enabledIconName: "LocationSearching",
    disabledIconName: "LocationDisabled",
    enabledCodeIconName: "LocationSearching",
    disabledCodeIconName: "LocationDisabled",
  ),
  MaterialWipeIconPair(
    label: "Mail",
    enabledIconName: "Mail",
    disabledIconName: "MailOff",
  ),
  MaterialWipeIconPair(
    label: "Match Case",
    enabledIconName: "MatchCase",
    disabledIconName: "MatchCaseOff",
  ),
  MaterialWipeIconPair(
    label: "Media Output",
    enabledIconName: "MediaOutput",
    disabledIconName: "MediaOutputOff",
  ),
  MaterialWipeIconPair(
    label: "Mic External",
    enabledIconName: "MicExternalOn",
    disabledIconName: "MicExternalOff",
    enabledCodeIconName: "MicExternalOn",
    disabledCodeIconName: "MicExternalOff",
  ),
  MaterialWipeIconPair(
    label: "Music",
    enabledIconName: "MusicNote",
    disabledIconName: "MusicOff",
    enabledCodeIconName: "MusicNote",
    disabledCodeIconName: "MusicOff",
  ),
  MaterialWipeIconPair(
    label: "Mobile",
    enabledIconName: "Mobile",
    disabledIconName: "MobileOff",
  ),
  MaterialWipeIconPair(
    label: "Mobile Data Arrows",
    enabledIconName: "MobiledataArrows",
    disabledIconName: "MobiledataOff",
    enabledCodeIconName: "MobiledataArrows",
    disabledCodeIconName: "MobiledataOff",
  ),
  MaterialWipeIconPair(
    label: "Mobile Hand",
    enabledIconName: "MobileHand",
    disabledIconName: "MobileHandOff",
  ),
  MaterialWipeIconPair(
    label: "Mobile Hand Left",
    enabledIconName: "MobileHandLeft",
    disabledIconName: "MobileHandLeftOff",
  ),
  MaterialWipeIconPair(
    label: "Mobile Sound",
    enabledIconName: "MobileSound",
    disabledIconName: "MobileSoundOff",
  ),
  MaterialWipeIconPair(
    label: "Mode Cool",
    enabledIconName: "ModeCool",
    disabledIconName: "ModeCoolOff",
  ),
  MaterialWipeIconPair(
    label: "Mode Fan",
    enabledIconName: "ModeFan",
    disabledIconName: "ModeFanOff",
  ),
  MaterialWipeIconPair(
    label: "Noise Control",
    enabledIconName: "NoiseControlOn",
    disabledIconName: "NoiseControlOff",
    enabledCodeIconName: "NoiseControlOn",
    disabledCodeIconName: "NoiseControlOff",
  ),
  MaterialWipeIconPair(
    label: "Mouse Lock",
    enabledIconName: "MouseLock",
    disabledIconName: "MouseLockOff",
  ),
  MaterialWipeIconPair(
    label: "Movie",
    enabledIconName: "Movie",
    disabledIconName: "MovieOff",
  ),
  MaterialWipeIconPair(
    label: "Near Me",
    enabledIconName: "NearMe",
    disabledIconName: "NearMeDisabled",
  ),
  MaterialWipeIconPair(
    label: "Nearby",
    enabledIconName: "Nearby",
    disabledIconName: "NearbyOff",
  ),
  MaterialWipeIconPair(
    label: "Nfc",
    enabledIconName: "Nfc",
    disabledIconName: "NfcOff",
  ),
  MaterialWipeIconPair(
    label: "Night Sight Auto",
    enabledIconName: "NightSightAuto",
    disabledIconName: "NightSightAutoOff",
  ),
  MaterialWipeIconPair(
    label: "No Food",
    enabledIconName: "Fastfood",
    disabledIconName: "NoFood",
    enabledCodeIconName: "Fastfood",
    disabledCodeIconName: "NoFood",
  ),
  MaterialWipeIconPair(
    label: "No Accounts",
    enabledIconName: "AccountCircle",
    disabledIconName: "NoAccounts",
    enabledCodeIconName: "AccountCircle",
    disabledCodeIconName: "NoAccounts",
  ),
  MaterialWipeIconPair(
    label: "No Encryption",
    enabledIconName: "Lock",
    disabledIconName: "NoEncryption",
    enabledCodeIconName: "Lock",
    disabledCodeIconName: "NoEncryption",
  ),
  MaterialWipeIconPair(
    label: "No Luggage",
    enabledIconName: "Luggage",
    disabledIconName: "NoLuggage",
  ),
  MaterialWipeIconPair(
    label: "No Meals",
    enabledIconName: "Restaurant",
    disabledIconName: "NoMeals",
    enabledCodeIconName: "Restaurant",
    disabledCodeIconName: "NoMeals",
  ),
  MaterialWipeIconPair(
    label: "No Meeting Room",
    enabledIconName: "MeetingRoom",
    disabledIconName: "NoMeetingRoom",
  ),
  MaterialWipeIconPair(
    label: "No Photography",
    enabledIconName: "PhotoCamera",
    disabledIconName: "NoPhotography",
    enabledCodeIconName: "PhotoCamera",
    disabledCodeIconName: "NoPhotography",
  ),
  MaterialWipeIconPair(
    label: "No Stroller",
    enabledIconName: "Stroller",
    disabledIconName: "NoStroller",
  ),
  MaterialWipeIconPair(
    label: "No Transfer",
    enabledIconName: "DirectionsBus",
    disabledIconName: "NoTransfer",
    enabledCodeIconName: "DirectionsBus",
    disabledCodeIconName: "NoTransfer",
  ),
  MaterialWipeIconPair(
    label: "Notification Audio",
    enabledIconName: "NotificationAudio",
    disabledIconName: "NotificationAudioOff",
  ),
  MaterialWipeIconPair(
    label: "Notifications",
    enabledIconName: "Notifications",
    disabledIconName: "NotificationsOff",
  ),
  MaterialWipeIconPair(
    label: "Offline Pin",
    enabledIconName: "OfflinePin",
    disabledIconName: "OfflinePinOff",
  ),
  MaterialWipeIconPair(
    label: "Open In New",
    enabledIconName: "OpenInNew",
    disabledIconName: "OpenInNewOff",
  ),
  MaterialWipeIconPair(
    label: "Person",
    enabledIconName: "Person",
    disabledIconName: "PersonOff",
  ),
  MaterialWipeIconPair(
    label: "Person Add",
    enabledIconName: "PersonAdd",
    disabledIconName: "PersonAddDisabled",
  ),
  MaterialWipeIconPair(
    label: "Personal Bag",
    enabledIconName: "PersonalBag",
    disabledIconName: "PersonalBagOff",
  ),
  MaterialWipeIconPair(
    label: "Phone",
    enabledIconName: "PhoneEnabled",
    disabledIconName: "PhoneDisabled",
    enabledCodeIconName: "PhoneEnabled",
    disabledCodeIconName: "PhoneDisabled",
  ),
  MaterialWipeIconPair(
    label: "Piano",
    enabledIconName: "Piano",
    disabledIconName: "PianoOff",
  ),
  MaterialWipeIconPair(
    label: "Picture In Picture",
    enabledIconName: "PictureInPicture",
    disabledIconName: "PictureInPictureOff",
  ),
  MaterialWipeIconPair(
    label: "Pill",
    enabledIconName: "Pill",
    disabledIconName: "PillOff",
  ),
  MaterialWipeIconPair(
    label: "Play",
    enabledIconName: "PlayArrow",
    disabledIconName: "PlayDisabled",
    enabledCodeIconName: "PlayArrow",
    disabledCodeIconName: "PlayDisabled",
  ),
  MaterialWipeIconPair(
    label: "Power",
    enabledIconName: "Power",
    disabledIconName: "PowerOff",
  ),
  MaterialWipeIconPair(
    label: "Preview",
    enabledIconName: "Preview",
    disabledIconName: "PreviewOff",
  ),
  MaterialWipeIconPair(
    label: "Print",
    enabledIconName: "Print",
    disabledIconName: "PrintDisabled",
  ),
  MaterialWipeIconPair(
    label: "Public",
    enabledIconName: "Public",
    disabledIconName: "PublicOff",
  ),
  MaterialWipeIconPair(
    label: "Receipt Long",
    enabledIconName: "ReceiptLong",
    disabledIconName: "ReceiptLongOff",
  ),
  MaterialWipeIconPair(
    label: "Report",
    enabledIconName: "Report",
    disabledIconName: "ReportOff",
  ),
  MaterialWipeIconPair(
    label: "Raw",
    enabledIconName: "RawOn",
    disabledIconName: "RawOff",
    enabledCodeIconName: "RawOn",
    disabledCodeIconName: "RawOff",
  ),
  MaterialWipeIconPair(
    label: "Router",
    enabledIconName: "Router",
    disabledIconName: "RouterOff",
  ),
  MaterialWipeIconPair(
    label: "Safety Check",
    enabledIconName: "SafetyCheck",
    disabledIconName: "SafetyCheckOff",
  ),
  MaterialWipeIconPair(
    label: "Science",
    enabledIconName: "Science",
    disabledIconName: "ScienceOff",
  ),
  MaterialWipeIconPair(
    label: "Select Window",
    enabledIconName: "SelectWindow",
    disabledIconName: "SelectWindowOff",
  ),
  MaterialWipeIconPair(
    label: "Sensors",
    enabledIconName: "Sensors",
    disabledIconName: "SensorsOff",
  ),
  MaterialWipeIconPair(
    label: "Sensors Krx",
    enabledIconName: "SensorsKrx",
    disabledIconName: "SensorsKrxOff",
  ),
  MaterialWipeIconPair(
    label: "Shift Lock",
    enabledIconName: "ShiftLock",
    disabledIconName: "ShiftLockOff",
  ),
  MaterialWipeIconPair(
    label: "Shopping Cart",
    enabledIconName: "ShoppingCart",
    disabledIconName: "ShoppingCartOff",
  ),
  MaterialWipeIconPair(
    label: "Speaker Notes",
    enabledIconName: "SpeakerNotes",
    disabledIconName: "SpeakerNotesOff",
  ),
  MaterialWipeIconPair(
    label: "Stack",
    enabledIconName: "Stack",
    disabledIconName: "StackOff",
  ),
  MaterialWipeIconPair(
    label: "Subtitles",
    enabledIconName: "Subtitles",
    disabledIconName: "SubtitlesOff",
  ),
  MaterialWipeIconPair(
    label: "Supervised User Circle",
    enabledIconName: "SupervisedUserCircle",
    disabledIconName: "SupervisedUserCircleOff",
  ),
  MaterialWipeIconPair(
    label: "Sync",
    enabledIconName: "Sync",
    disabledIconName: "SyncDisabled",
  ),
  MaterialWipeIconPair(
    label: "Sync Saved Locally",
    enabledIconName: "SyncSavedLocally",
    disabledIconName: "SyncSavedLocallyOff",
  ),
  MaterialWipeIconPair(
    label: "Text Ad",
    enabledIconName: "TextAd",
    disabledIconName: "TextAdOff",
  ),
  MaterialWipeIconPair(
    label: "Timer",
    enabledIconName: "Timer",
    disabledIconName: "TimerOff",
  ),
  MaterialWipeIconPair(
    label: "Touchpad Mouse",
    enabledIconName: "TouchpadMouse",
    disabledIconName: "TouchpadMouseOff",
  ),
  MaterialWipeIconPair(
    label: "Tv",
    enabledIconName: "Tv",
    disabledIconName: "TvOff",
  ),
  MaterialWipeIconPair(
    label: "Update",
    enabledIconName: "Update",
    disabledIconName: "UpdateDisabled",
  ),
  MaterialWipeIconPair(
    label: "Usb",
    enabledIconName: "Usb",
    disabledIconName: "UsbOff",
  ),
  MaterialWipeIconPair(
    label: "Verified",
    enabledIconName: "Verified",
    disabledIconName: "VerifiedOff",
  ),
  MaterialWipeIconPair(
    label: "Video Camera Front",
    enabledIconName: "VideoCameraFront",
    disabledIconName: "VideoCameraFrontOff",
  ),
  MaterialWipeIconPair(
    label: "Videocam",
    enabledIconName: "Videocam",
    disabledIconName: "VideocamOff",
  ),
  MaterialWipeIconPair(
    label: "Videogame Asset",
    enabledIconName: "VideogameAsset",
    disabledIconName: "VideogameAssetOff",
  ),
  MaterialWipeIconPair(
    label: "View In AR",
    enabledIconName: "ViewInAr",
    disabledIconName: "ViewInArOff",
  ),
  MaterialWipeIconPair(
    label: "Visibility",
    enabledIconName: "Visibility",
    disabledIconName: "VisibilityOff",
  ),
  MaterialWipeIconPair(
    label: "Voice Chat",
    enabledIconName: "VoiceChat",
    disabledIconName: "VoiceChatOff",
  ),
  MaterialWipeIconPair(
    label: "Voice Selection",
    enabledIconName: "VoiceSelection",
    disabledIconName: "VoiceSelectionOff",
  ),
  MaterialWipeIconPair(
    label: "Volume",
    enabledIconName: "VolumeUp",
    disabledIconName: "VolumeOff",
    enabledCodeIconName: "VolumeUp",
    disabledCodeIconName: "VolumeOff",
  ),
  MaterialWipeIconPair(
    label: "Vpn Key",
    enabledIconName: "VpnKey",
    disabledIconName: "VpnKeyOff",
  ),
  MaterialWipeIconPair(
    label: "VR180 Create 2d",
    enabledIconName: "Vr180Create2d",
    disabledIconName: "Vr180Create2dOff",
  ),
  MaterialWipeIconPair(
    label: "Warning",
    enabledIconName: "Warning",
    disabledIconName: "WarningOff",
  ),
  MaterialWipeIconPair(
    label: "Watch",
    enabledIconName: "Watch",
    disabledIconName: "WatchOff",
  ),
  MaterialWipeIconPair(
    label: "Web Asset",
    enabledIconName: "WebAsset",
    disabledIconName: "WebAssetOff",
  ),
  MaterialWipeIconPair(
    label: "Wifi",
    enabledIconName: "Wifi",
    disabledIconName: "WifiOff",
  ),
];

final List<MaterialWipeIconPair> knownProblemsMaterialWipeIconCatalog = [
  MaterialWipeIconPair(
    label: "Android Wifi 3 Bar",
    enabledIconName: "AndroidWifi3Bar",
    disabledIconName: "AndroidWifi3BarOff",
  ),
  MaterialWipeIconPair(
    label: "Approval Delegation",
    enabledIconName: "ApprovalDelegation",
    disabledIconName: "ApprovalDelegationOff",
    enabledCodeIconName: "ApprovalDelegation",
    disabledCodeIconName: "ApprovalDelegationOff",
  ),
  MaterialWipeIconPair(
    label: "Bedtime",
    enabledIconName: "Bedtime",
    disabledIconName: "BedtimeOff",
  ),
  MaterialWipeIconPair(
    label: "Contrast",
    enabledIconName: "Contrast",
    disabledIconName: "ContrastRtlOff",
    enabledCodeIconName: "Contrast",
    disabledCodeIconName: "ContrastRtlOff",
  ),
  MaterialWipeIconPair(
    label: "Desktop Windows",
    enabledIconName: "DesktopWindows",
    disabledIconName: "DesktopAccessDisabled",
    enabledCodeIconName: "DesktopWindows",
    disabledCodeIconName: "DesktopAccessDisabled",
  ),
  MaterialWipeIconPair(
    label: "Hearing",
    enabledIconName: "Hearing",
    disabledIconName: "HearingDisabled",
    enabledCodeIconName: "Hearing",
    disabledCodeIconName: "HearingDisabled",
  ),
  MaterialWipeIconPair(
    label: "Hearing Aid",
    enabledIconName: "HearingAid",
    disabledIconName: "HearingAidDisabled",
    enabledCodeIconName: "HearingAid",
    disabledCodeIconName: "HearingAidDisabled",
  ),
  MaterialWipeIconPair(
    label: "Media Bluetooth",
    enabledIconName: "MediaBluetoothOn",
    disabledIconName: "MediaBluetoothOff",
    enabledCodeIconName: "MediaBluetoothOn",
    disabledCodeIconName: "MediaBluetoothOff",
  ),
  MaterialWipeIconPair(
    label: "Mic",
    enabledIconName: "Mic",
    disabledIconName: "MicOff",
  ),
  MaterialWipeIconPair(
    label: "Mode Heat",
    enabledIconName: "ModeHeat",
    disabledIconName: "ModeHeatOff",
    enabledCodeIconName: "ModeHeat",
    disabledCodeIconName: "ModeHeatOff",
  ),
  MaterialWipeIconPair(
    label: "Password 2",
    enabledIconName: "Password2",
    disabledIconName: "Password2Off",
  ),
  MaterialWipeIconPair(
    label: "Smart Card Reader",
    enabledIconName: "SmartCardReader",
    disabledIconName: "SmartCardReaderOff",
    enabledCodeIconName: "SmartCardReader",
    disabledCodeIconName: "SmartCardReaderOff",
  ),
  MaterialWipeIconPair(
    label: "Tamper Detection",
    enabledIconName: "TamperDetectionOn",
    disabledIconName: "TamperDetectionOff",
    enabledCodeIconName: "TamperDetectionOn",
    disabledCodeIconName: "TamperDetectionOff",
  ),
  MaterialWipeIconPair(
    label: "Wifi Tethering",
    enabledIconName: "WifiTethering",
    disabledIconName: "WifiTetheringOff",
  ),
];

final List<MaterialWipeIconSection> iconSections = [
  MaterialWipeIconSection(
    title: 'Ready to use',
    subtitle: 'These icon pairs morph seamlessly',
    icons: coreMaterialWipeIconCatalog,
  ),
  MaterialWipeIconSection(
    title: 'Needs refinement',
    subtitle: 'There are some size and rotation differences.',
    icons: knownProblemsMaterialWipeIconCatalog,
  ),
];

const String howItWorksPairLabel = 'Power';
