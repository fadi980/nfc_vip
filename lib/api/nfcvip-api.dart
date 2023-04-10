import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:nfc_vip/general.dart';
import 'package:nfc_vip/customer.dart';

class nfcvip_api {

  final String apiurl_ValidateCustomer = 'https://f92rwf1lb0.execute-api.us-west-1.amazonaws.com/test1';
  final String apiurl_AddNewCustoer = 'https://ymn78qylyi.execute-api.us-west-1.amazonaws.com/test1';
  final String apiurl_UpdateCustoerTags = 'https://l6gai6a56g.execute-api.us-west-1.amazonaws.com/test1';

  Future<Customer> validateCustomer(String TagID) async {
    String body = jsonEncode(<String, String>{'TagID': TagID});
    http.Response res = await sendPOST(apiurl_ValidateCustomer, body );

    Customer customer = Customer();
    customer.CardID = TagID;
    var obj = jsonDecode(res.body)["body"];
    if (obj["result"] == 'valid') {
      var c = jsonDecode(obj["customer"]);
      customer.CustomerName = c["CustomerName"];
      customer.PhoneNo = c["PhoneNo"];
      customer.MembershipDate = c["MembershipDate"];
      customer.MembershipLevel = 1;
      customer.CustomTags = c["tags"].toString().split(",");
      customer.IsValid = true;
      print(c);
    }
    return customer;
  }

  Future<Customer> addNewCustomer(String TagID, String CustomerName, String PhoneNo) async {
    String body = jsonEncode(<String, String>{'TagID': TagID, 'customername' : CustomerName, "PhoneNo" : PhoneNo});
    http.Response res = await sendPOST(apiurl_AddNewCustoer, body );

    //print(res.body);
    Customer customer = Customer();

    var obj = jsonDecode(res.body)["body"];
    if (obj == 'done') {
      customer.CardID = TagID;
      customer.CustomerName = CustomerName;
      customer.PhoneNo = PhoneNo;
      customer.IsValid = true;
    }
    else{
      customer.Message = "Unable to add customer";
    }
    return customer;
  }

  Future<ActionResult> updateCustomerTags(String TagID, List<String> tags) async {
    ActionResult result = ActionResult(ActionResultType.none, '');
    String body = jsonEncode(<String, String>{'TagID': TagID, 'tags' : tags.join(',')});
    http.Response res = await sendPOST(apiurl_UpdateCustoerTags, body );
    var obj = jsonDecode(res.body)["body"];
    if (obj["result"] == 'done') {
      result.resultType = ActionResultType.success;
    }
    else{
      result.resultType = ActionResultType.failed;
    }
    return result;
  }

  Future<http.Response> sendPOST(String url, String request_body) {
    return http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: request_body,
    );
  }
}
