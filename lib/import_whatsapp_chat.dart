import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:import_whatsapp_chat/ios/ios_utils.dart';
import 'package:share_handler/share_handler.dart';
import 'chat_analyzer/chat_analyzer.dart';
import 'models/chat_content.dart';
export 'models/models.dart';

///I used Duarte Silveira share package. See: https://github.com/d-silveira/flutter-share.
/// We could not use his package because we needed to perform changes and it wasn't sound null safety.
/// There is a credit to him and there will be throughout the whole package.

abstract class ReceiveWhatsappChat<T extends StatefulWidget> extends State<T> {
  /// Stream [stream] for listener
  static const stream = EventChannel('plugins.flutter.io/receiveshare');

  /// Method Channel [methodChannel] for analyzing the chat
  static const MethodChannel methodChannel =
      MethodChannel('com.whatsapp.chat/chat');

  /// Can Receive the chat or not
  bool shareReceiveEnabled = false;

  /// shared file name with extension
  String fileName = '';

  ///
  bool sharedMediaReceived = false;

  /// Save image paths
  bool _allowReceiveWithMedia = false;

  /// StreamSubscription [_shareReceiveSubscription] for listener
  StreamSubscription? _shareReceiveSubscription;

  ///
  late ShareHandlerPlatform handler;

  /// device is iOS
  bool get isIOS => !kIsWeb && Platform.isIOS;

  /// device is android
  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// We need to enable [shareReceiveEnabled] at first
  @override
  void initState() {
    if (!kIsWeb) {
      handler = ShareHandlerPlatform.instance;
      /// For sharing images coming from outside the app while the app is closed
      handler.getInitialSharedMedia().then(receiveSharedFile);
      //
      enableShareReceiving();
    }
    super.initState();
  }

  /// Enable [_allowReceiveWithMedia] to save the images paths
  void enableReceivingChatWithMedia() {
    if (mounted) setState(() => _allowReceiveWithMedia = true);
  }

  /// Update shared file name
  void updateSharedFileName(String path) {
    if (mounted) setState(() => fileName = path.split('/').last);
    debugPrint('Filename: $fileName');
  }

  /// Disable [_allowReceiveWithMedia] to not save images path
  void disableReceivingChatWithMedia() {
    if (mounted) setState(() => _allowReceiveWithMedia = false);
  }

  /// Enable [shareReceiveEnabled] and subscribe to sharedMediaStream
  void enableShareReceiving() {
    _shareReceiveSubscription ??=
        handler.sharedMediaStream.listen(receiveSharedFile, onError: (err) {
      debugPrint("Share intent error: $err");
    });
    if (mounted) setState(() => shareReceiveEnabled = true);
    debugPrint("enabled share receiving");
  }

  /// Disable [shareReceiveEnabled]
  void disableShareReceiving() {
    if (_shareReceiveSubscription != null) {
      _shareReceiveSubscription!.cancel();
      _shareReceiveSubscription = null;
    }
    shareReceiveEnabled = false;
    sharedMediaReceived = false;
    fileName = '';
    handler.resetInitialSharedMedia();
    debugPrint("disabled share receiving");
  }

  /// Receive the share whatsapp chat file
  ///
  /// IOS - we receive a zip file url: file:///private/var/mobile/Containers/Shared/AppGroup/40AE836A-A91D-4F36-AADF-8E141C12DA86/WhatsApp Chat - My 9mobile No.zip
  ///
  /// Android - we receive a content url: content://com.whatsapp.provider.media/export_chat/972537739211@s.whatsapp.net/e26757...
  void receiveSharedFile(SharedMedia? shared) {
    if (shared != null && !sharedMediaReceived) {
      if (mounted) setState(() => sharedMediaReceived = true);
      debugPrint(
          "Attachments path - ${shared.attachments?.map((e) => '{${e?.path}, ${e?.type.name}}').toList() ?? []}");
      if (shared.attachments != null && shared.attachments!.isNotEmpty) {
        extractSharedFile(shared.attachments!.first!.path);
      }
    }
  }

  /// WhatsApp sends us a zip file.
  /// We need to unzip the file, read it and send it to the [ChatAnalyzer.analyze]
  Future<void> extractSharedFile(String path) async {
    updateSharedFileName(path);
    // confirm if file is exported whatsapp chat
    final validUrl = isWhatsAppChatUrl(path);
    if (!validUrl) throw Exception("Not a WhatsApp chat file");
    // unzip file
    final unzipped = await IOSUtils.unzip(path);
    if (!unzipped) throw Exception("Unzip failed");
    // read extracted file
    List<String> chat = await IOSUtils.readFile(
        isAndroid ? fileName.replaceFirst('zip', 'txt') : '_chat.txt');
    // analyze chat
    final filename = isAndroid ? fileName.replaceFirst('zip', 'txt') : fileName;
    chat.insert(0, filename);
    receiveChatContent(ChatAnalyzer.analyze(chat, _getImagePaths(chat)), path);
  }

  List<String>? _getImagePaths(List<String> messages) {
    if (!_allowReceiveWithMedia) return [];
    List<String> ret = [];
    for (String message in messages) {
      if (message.endsWith(".jpg")) {
        ret.add(message);
      }
    }
    return ret;
  }

  /// Check if the url is a WhatsApp chat url
  bool isWhatsAppChatUrl(String url) {
    if (isAndroid) {
      return url.toLowerCase().contains('whatsapp chat');
      // .startsWith("content://com.whatsapp.provider.media/export_chat/");
    } else if (isIOS) {
      return url.startsWith("/private/var/mobile/Containers/Shared/AppGroup/");
    }
    return false;
  }

  /// Abstract function calling after we receive and analyze the chat
  void receiveChatContent(ChatContent chatContent, String filePath);
}
