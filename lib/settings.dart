import 'package:flutter/material.dart';
import 'preferences.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final txtAddCustomerPermissionCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    txtAddCustomerPermissionCodeController.text =
        AppPref.AddCustomerPermissionCode;
    //print('loading settings');
    //print('[${AppPref.AddCustomerPermissionCode}]');
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text('Settings'),
          centerTitle: true,
          backgroundColor: Colors.grey.shade600,
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            30.0, 50.0, 30.0, 0.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text('Add Customer Permission Code',
                                  style: TextStyle(color: Colors.white60)),
                              TextFormField(
                                style: const TextStyle(color: Colors.white60),
                                controller: txtAddCustomerPermissionCodeController,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  AppPref.AddCustomerPermissionCode =
                                      txtAddCustomerPermissionCodeController
                                          .text;
                                  AppPref.LoadSettings();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (
                                            context) => const CIDReader()),
                                  );
                                },
                                child:
                                const Text('Save'),
                              ),
                            ]
                        )
                    )
                )
            );
          },
        ),
      );
}


