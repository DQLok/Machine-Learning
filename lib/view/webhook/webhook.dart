import 'package:flutter/material.dart';

class Webhook extends StatefulWidget {
  const Webhook({super.key});

  @override
  State<Webhook> createState() => _WebhookState();
}

class _WebhookState extends State<Webhook> {
  @override
  Widget build(BuildContext context) {
    return Placeholder(
      child: Scaffold(
          appBar: AppBar(title: Text("Webhook")),
          body: Center(
            child: Text("alo"),
          )),
    );
  }
}
