import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SuperbetAuto extends StatefulWidget {
  const SuperbetAuto({super.key});

  @override
  State<SuperbetAuto> createState() => _SuperbetAutoState();
}

class _SuperbetAutoState extends State<SuperbetAuto> {
  final _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse('https://superbet.ro/'));

  void _clickButton() async {
    await _controller.clearCache();
    await _controller.reload();
    // await _controller.runJavaScript(
    //     'document.querySelector("button.mobile-header-account-section__btn").click();'); // <button data-v-5d1431d6="" data-v-0a85cf8d="" type="submit" class="mobile-header-account-section__btn e2e-login capitalize btn btn--primary-yellow btn--md"> intră în cont </button>
    // await _controller.runJavaScript(
    //     'document.querySelector(\'input.input__field[data-gtm-form-interact-field-id="8"]\').value = "teoClimber;'); // <input name="" class="input__field" data-gtm-form-interact-field-id="8">
    // await _controller.runJavaScript(
    //     'document.querySelectorAll(".input__field")[0].value = "teoClimber"');
    // <input name="" class="input__field" data-gtm-form-interact-field-id="12">

    // <input name="" class="input__field" data-gtm-form-interact-field-id="12">
    // await _controller.runJavaScript(
    //     'document.querySelectorAll(".input__field")[1].value = "#Superbet69"');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Superbet automation')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 500,
              child: WebViewWidget(
                controller: _controller,
              ),
            ),
            TextButton(
              onPressed: _clickButton,
              child: const Text('Press "Intra in cont button"'),
            ),
          ],
        ),
      ),
    );
  }
}
