import 'dart:io';
import 'package:flutter/foundation.dart';

/// When WhatsApp export a chat it will export the special messages in different languages.
/// I added support for those languages. If you have a language that is not supported,
/// please sent it to me and I will add it. Thanks!

class Languages {
  static const List<String> youDeletedThisMessage = [
    'You deleted this message', // English
    '<You deleted this message>',
    'מחקת את ההודעה הזו', // Hebrew
    'Вы удалили это сообщение', // Russian
    'Vous avez supprimé ce message', // French
    'Hai eliminato questo messaggio', // Italian
    'Você eliminou este mensagem', // Portuguese
    'Borraste este mensaje', // Spanish
    'Διαγράψατε αυτό το μήνυμα', // Greek
    'Ви видали це повідомлення', // Ukrainian
    'Sie haben diese Nachricht gelöscht', // German
    'أنت حذفت هذه الرسالة', // Arabic
  ];

  static const List<String> missedVideoCall = [
    'Missed video call', // English
  ];

  static const List<String> missedAudioCall = [
    'Missed audio call', // English
  ];

  static const List<String> attachment = [
    'file attached', // English
    'null',
    'image omitted',
    'video omitted',
  ];

  static const List<String> mediaOmitted = [
    '<Media omitted>', // English
    'Media omitted',
    '<המדיה הוסרה>', // Hebrew
    '<המדיה לא נכללה>', // Hebrew
    '<Без медиафайлов>', // Russian
    '<Média manquante>', // French
    '<Media mancante>', // Italian
    '<Mídia omitida>', // Portuguese
    '<Media omitida>', // Spanish
    '<Αποχρεωτική παραλαβή μέσων>', // Greek
    '<Медіа відсутня>', // Ukrainian
    '<Medien fehlen>', // German
    '<ملفات مفقودة>', // Arabic
  ];

  static const List<String> thisMessageWasDeleted = [
    'This message was deleted', // English
    '<This message was deleted>',
    'הודעה זו נמחקה', // Hebrew
    'Данное сообщение удалено', // Russian
    'Ce message a été supprimé', // French
    'Questo messaggio è stato cancellato', // Italian
    'Este mensagem foi apagado', // Portuguese
    'Este mensagem foi apagado', // Spanish
    'Αυτό το μήνυμα διαγράφηκε', // Greek
    'Це повідомлення видалено', // Ukrainian
    'Diese Nachricht wurde gelöscht', // German
    'هذه الرسالة تم حذفها', // Arabic
  ];

  static bool hasMatchForAll(String text) {
    /// In iOS message is a little bit different
    if (!kIsWeb && Platform.isIOS) {
      text = text.replaceAll('.', '');
      text = text.replaceRange(0, 1, '');
    }
    text = text.replaceAll('<This message was edited>', '');
    text = text.replaceAll('This message was edited', '');
    //
    return hasMatch(text, youDeletedThisMessage) ||
        hasMatch(text, mediaOmitted) ||
        hasMatch(text, thisMessageWasDeleted) ||
        hasMatch(text, missedAudioCall) ||
        hasMatch(text, missedVideoCall) ||
        hasMatch(text, attachment);
  }

  static bool hasMatch(String text, List<String> list) {
    for (String item in list) {
      if (text == item) {
        return true;
      }
    }
    return false;
  }
}
