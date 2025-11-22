
import 'package:learning_english/main.dart';


speak(String text) async {
  flutterTts.setCompletionHandler(() {});
  await flutterTts.setLanguage("en-US");
  await flutterTts.setVolume(1.0);
  await flutterTts.setPitch(1);
  await flutterTts.speak(text);
}

initTTS() async {
  flutterTts.getVoices.then((value) {
    try {
      List<Map> voiceData= List<Map>.from(value);
      print("voiceData: ${voiceData}");
    } catch (e) {}
  }).onError((error, stackTrace) {
    print("Error: $error");
  });
}
