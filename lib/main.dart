import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_tag_editor/tag_editor.dart';
import 'package:nfc_vip/widget/tageditor_chip.dart';
import 'package:nfc_vip/api/nfcvip-api.dart';
import 'package:nfc_vip/nfc_handler.dart';
import 'package:nfc_vip/customer.dart';
import 'package:nfc_vip/settings.dart';
import 'package:nfc_vip/theme/constants.dart';
import 'preferences.dart';


void main() {
  runApp(const MaterialApp(
    home: CIDReader(),
  ));
}

class CIDReader extends StatefulWidget {
  const CIDReader({Key? key}) : super(key: key);

  @override
  State<CIDReader> createState() => _CIDReaderState();
}

class _CIDReaderState extends State<CIDReader> {
  // A timer to always check NFC availability and update availability status
  Timer nfcReaderCheckTimer = Timer.periodic(
      const Duration(seconds: 3), (Timer timer) {});

  // A timer to set time out for card detection when card read is selected
  Timer cardReadTimeoutTimer = Timer(const Duration(seconds: 5), () {});

  String cardID = '-';
  bool nfc_Available = false;
  bool nfc_Scanning = false;
  bool askForAddition = false;

  String avatarPath = 'assets/unknown.png';

  final txtCustomerNameController = TextEditingController();
  final txtPhoneController = TextEditingController();

  //List<String> _values = [];
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();

  Color? appBar_Color = AppColors.appBar_Normal;
  Color? button_Color = AppColors.readButton_Inactive;

  CardReader reader = CardReader();
  Customer customer = Customer();
  nfcvip_api api = nfcvip_api();

  void handleCheckNFCTimer(Timer timer) async {
    await CheckReader();
    //print('NFC check timer tick: ${DateTime.now()}');
  }

  void handleCardReadTimeoutTimer() {
    //print('Card detection time out tick: ${DateTime.now()}');
  }

  Future<void> CheckReader() async {
    await reader.isNFCAvailable();
    if (reader.nfc_Available) {
      if (!nfc_Scanning) {
        button_Color = AppColors.readButton_Active;
      }
    }
    else {
      button_Color = AppColors.readButton_Inactive;
    }

    setState(() {

    });
    nfc_Available = reader.nfc_Available;
  }

  Future<void> ReadCard() async {
    await reader.listenForNFCEvents();
    setState(() {

    });
  }

  void cardDetectedEventHandler(CardDetectedEventArgs? args) async {
    //print('Event Handler: card detected ${args?.cardID}');
    cardID = (args?.cardID).toString();
    nfc_Scanning = false;

    customer = await api.validateCustomer(cardID);
    askForAddition =
    !customer.IsValid & (AppPref.AddCustomerPermissionCode == '910547');
    setState(() {});
  }

  void scanningStoppedEventHandler(ScanningStoppedEventArgs? args) async {
    //print('Scanning timed out');
    nfc_Scanning = false;
    button_Color = AppColors.readButton_Active;
  }

  _onDelete(index) {
    setState(() {
      customer.CustomTags.removeAt(index);
    });
  }

  /// This is just an example for using `TextEditingController` to manipulate
  /// the the `TextField` just like a normal `TextField`.
  _onPressedModifyTextField() async {
    print(customer.CustomTags);
    if (customer.IsValid){
      await api.updateCustomerTags(customer.CardID, customer.CustomTags);
    }
  }

  Future<void> addNewCustomer(String cardID, String customerName,
      String phoneNo) async {
    customer = await api.addNewCustomer(cardID, customerName, phoneNo);
    setState(() {});
  }

  Future<void> showAddCustomerDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('Add New Customer', style: TextStyle(
                  color: Colors.blue.shade300,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0)),
              backgroundColor: Colors.grey.shade200,
              scrollable: true,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.blue.shade400),
              ),
              content:
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 20.0,),
                  Text('Customer Name',
                      style: TextStyle(color: Colors.blue
                          .shade300)),
                  TextField(controller: txtCustomerNameController),
                  const SizedBox(height: 40.0,),
                  Text('Phone Number',
                      style: TextStyle(color: Colors.blue
                          .shade300)),
                  TextField(
                    controller: txtPhoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 40.0,),
                  SizedBox(
                    child:
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              await addNewCustomer(customer.CardID,
                                  txtCustomerNameController.text,
                                  txtPhoneController.text);
                              if (customer.IsValid) {
                                askForAddition = false;
                                Navigator.pop(context);
                              }
                              else {
                                AlertDialog(
                                  content: Text(customer.Message),);
                              }
                            },
                            child: const Text('Add')
                        ),
                        const SizedBox(width: 20.0,),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel')
                        ),
                      ],
                    ),
                  )
                ],
              )
          );
        }
    );
  }

  @override
  void initState() {
    super.initState();
    AppPref.LoadSettings();
    //print('Check NFC Reader');
    CheckReader();

    nfcReaderCheckTimer =
        Timer.periodic(const Duration(seconds: 3), handleCheckNFCTimer);
    //CardReadTimeoutTimer = Timer(Duration(seconds: 5), handleCardReadTimeoutTimer);

    setState(() {}
    );

    reader.CardDetectedEvent.subscribe((args) {
      cardDetectedEventHandler(args);
    });
    reader.ScanningStoppedEvent.subscribe((args) {
      scanningStoppedEventHandler(args);
    });
  }

  void onMenuSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
      //print('go to settings page');
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        break;
    }
  }

  List<Widget> getCustomerCardWidget(){
    return <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child:
            CircleAvatar(
              backgroundImage: AssetImage(avatarPath),
              backgroundColor: Colors.grey[900],
              radius: 80.0,
            ),
          ),
          Text('Name: ', style: nfcvip_TextStyles.CardItemTitle),
          Text(customer.CustomerName,
              style: nfcvip_TextStyles.CardItemValue),
          const SizedBox(height: 20.0,),
          Text(
              'Phone No: ', style: nfcvip_TextStyles.CardItemTitle),
          Text(customer.PhoneNo,
              style: nfcvip_TextStyles.CardItemValue),
          const SizedBox(height: 20.0,),
          Text('Membership Date: ',
              style: nfcvip_TextStyles.CardItemTitle),
          Text(customer.MembershipDate,
              style: nfcvip_TextStyles.CardItemValue),
          const SizedBox(height: 20.0,),
          Text('Membership Level: ',
              style: nfcvip_TextStyles.CardItemTitle),
          Text('${customer.MembershipLevel}',
              style: nfcvip_TextStyles.CardItemValue),
          const SizedBox(height: 10.0,),
          Text('Notes', style: nfcvip_TextStyles.CardItemTitle),
          Container(
            height: 100,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade300, width: 2.0),
              color: Colors.grey.shade800,
            ),
          child:
            TagEditor(
              length: customer.CustomTags.length,
              controller: _textEditingController,
              focusNode: _focusNode,

              delimiters: [','],
              hasAddButton: true,
              resetTextOnSubmitted: true,
              // This is set to grey just to illustrate the `textStyle` prop
              textStyle: const TextStyle(color: Colors.grey),
              onSubmitted: (outstandingValue) {
                setState(() {
                  customer.CustomTags.add(outstandingValue);
                });
              },
              inputDecoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Add note here...',
                hintStyle: TextStyle(color: Colors.grey.shade600)
              ),
              onTagChanged: (newValue) {
                setState(() {
                  customer.CustomTags.add(newValue);
                });
              },
              tagBuilder: (context, index) => nfcvip_Chip(
                index: index,
                label: customer.CustomTags[index],
                onDeleted: _onDelete,
              ),
              // InputFormatters example, this disallow \ and /
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[/\\]'))
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _onPressedModifyTextField,
            child: const Text('Update Notes'),
          ),
          /*Text(
            'card id: $cardID',
            style: TextStyle(
              color: Colors.grey[600],
              letterSpacing: 2.0,
              //fontWeight: FontWeight.bold,
              fontSize: 12.0,
            ),
          ),*/
          const SizedBox(height: 20.0,),
          Center(
            child:
            (nfc_Scanning
                ? Image.asset('assets/nfc.gif', height: 150.0)
                : const SizedBox()
            ),
          ),
          Center(
            child:
            (!nfc_Scanning & !askForAddition & nfc_Available
                ? ElevatedButton(
              style: AppStyles.scanButtonStyle_Normal,
              child: Text(
                'Tap To Scan',
                style: nfcvip_TextStyles.ScanButton,
              ),
              onPressed: () async {
                if (nfc_Available) {
                  await ReadCard();
                  setState(() {
                    //print('clicked');
                    customer.reset();
                    nfc_Scanning = true;
                    button_Color = AppColors.readButton_Scanning;
                  });
                }
                else {
                  //print('NFC is not active');
                }
              },
            )
                : const SizedBox()
            ),
          ),
          const SizedBox(height: 20.0,),
          Center(
            child:
            askForAddition & !nfc_Scanning
                ? Container(
                decoration: BoxDecoration(color: Colors.grey[700],
                    boxShadow: [
                      BoxShadow(color: Colors.blue.shade300,
                          spreadRadius: 2.0,
                          blurRadius: 5.0)
                    ]),
                child:
                Column(
                  children: [
                    const SizedBox(height: 10,),
                    Text('Add new customer ?',
                        style: nfcvip_TextStyles
                            .ConfirmationMessage),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: AppStyles
                              .additionButtonStyle_Normal,
                          onPressed: () {
                            showAddCustomerDialog();
                          },
                          child:
                          Text('Yes', style: nfcvip_TextStyles
                              .ConfirmationButtons),
                        ),
                        const SizedBox(width: 50.0,),
                        ElevatedButton(
                          style: AppStyles
                              .additionButtonStyle_Normal,
                          onPressed: () {
                            askForAddition = false;
                            setState(() {});
                          },
                          child:
                          Text('No', style: nfcvip_TextStyles
                              .ConfirmationButtons),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                  ],
                )
            )
                : const SizedBox(),
          ),
          Center(
            child:
            (!nfc_Available) ?
                Container(
                    decoration: BoxDecoration(
                        color: Colors.red[300],border: Border.all(color: Colors.red, width: 2)
                    ),
                  width: 400,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text('NFC is not available'),
                )
                : const SizedBox()
          ),
        ],
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Customer ID'),
        centerTitle: true,
        backgroundColor: appBar_Color,
        elevation: 0.0,
        actions: [
          PopupMenuButton<int>(
              onSelected: (item) => onMenuSelected(context, item),
              itemBuilder: (context) =>
              [
                const PopupMenuItem<int>(
                  value:  0,
                  child: Text('Settings',),
                ),
              ])
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child:Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
                child:
                  Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: getCustomerCardWidget(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}