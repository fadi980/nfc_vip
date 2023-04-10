enum ActionResultType{
  none,
  success,
  failed
}

class ActionResult{
  ActionResultType resultType = ActionResultType.none;
  String Message = '';

  ActionResult(ActionResultType type, String message){
    resultType = type;
    Message = message;
  }
}