
import 'package:flutter/material.dart';


class AppColors{
  static Color? appBar_Normal = Colors.grey[850];
  static Color? appBar_NotVerified = Colors.red[400];
  static Color? appBar_Verified = Colors.green[300];

  static Color? AppBG = Colors.grey[900];

  static Color? readButton_Inactive = Colors.grey[900];
  static Color? readButton_Active = Colors.blue[200];
  static Color? readButton_Scanning = Colors.lightGreen[300];
}

class AppStyles{
  static final ButtonStyle scanButtonStyle_Normal = ElevatedButton.styleFrom(
    foregroundColor: Colors.blue,
    backgroundColor: Colors.grey[850],
    surfaceTintColor: Colors.green,
    fixedSize:Size(400.0, 200.0),
    side: BorderSide(color: Colors.blue, width: 2.0, style: BorderStyle.solid, strokeAlign: 5.0),
  );

  static final ButtonStyle additionButtonStyle_Normal = ElevatedButton.styleFrom(
    foregroundColor: Colors.blue,
    backgroundColor: Colors.blue[200],
    surfaceTintColor: Colors.green,
    fixedSize:Size(80.0, 20.0),
  );


}

class nfcvip_TextStyles{

  static final TextStyle CardItemTitle = TextStyle(
    color: Colors.grey,
    letterSpacing: 2.0,
    fontWeight: FontWeight.bold,
    fontSize: 16.0,
  );

  static final TextStyle CardItemValue = TextStyle(
  color: Colors.blue[300],
  letterSpacing: 2.0,
  fontWeight: FontWeight.bold,
  fontSize: 26.0,
  );

  static final TextStyle ConfirmationMessage = TextStyle(
    color: Colors.blue[300],
    letterSpacing: 2.0,
    fontSize: 24.0,
  );

  static final TextStyle ConfirmationButtons = TextStyle(
    color: Colors.grey[600],
    letterSpacing: 2.0,
    fontSize: 20.0,
  );

  static final TextStyle ScanButton = TextStyle(
    color: Colors.grey[600],
    letterSpacing: 2.0,
    fontSize: 20.0,
  );
}
