import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mini_app/helper.dart';
import 'package:mini_app/model/contact_model.dart';
import 'package:mini_app/widgets/contact_list_item.dart';

class SampleApp3 extends StatefulWidget {
  const SampleApp3({super.key});

  @override
  State<SampleApp3> createState() => _SampleApp3State();
}

class _SampleApp3State extends State<SampleApp3> {
  html.MessagePort? port;
  late final String apiDomain;
  final url = "https://6695f99f0312447373c0957c.mockapi.io/api/v1/users";

  Future<List<Contact>> getContacts() async {
    http.Response? response;
    try {
      response = await http.get(
        Uri.parse(url),
        headers: {},
      );
    } on Exception catch (e) {
      throw Exception("Lỗi khi phân tích dữ liệu danh bạ: $e");
    }

    final List<dynamic> parsed = json.decode(response.body);

    return parsed.map((e) => Contact.fromJson(e)).toList();
  }

  @override
  void initState() {
    super.initState();
    html.window.onMessage.listen((event) {
      if (event.data is Map) {
        Map<String, dynamic> data = json.decode(event.data);
        final isValid = AppHelper.verifyDomainFromToken(
          payloadJson: data["payload"],
          signatureBase64: data["signature"],
        );

        if (isValid) {
          apiDomain = List<String>.from(data["payload"]['apiDomains']).first;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh bạ'),
      ),
      body: FutureBuilder<List<Contact>>(
          future: getContacts(),
          builder: (context, snapshot) {
            final data = snapshot.data;

            if (data != null && data.isNotEmpty) {
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return ContactListItem(contact: data[index]);
                },
              );
            } else if (data?.isEmpty == true) {
              return const Center(
                child: Text('Không có dữ liệu'),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Đã xảy ra lỗi khi tải danh bạ!',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
