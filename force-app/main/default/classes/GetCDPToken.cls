public class GetCDPToken {
    @AuraEnabled public static string assertion{get; set;}

    public GetCDPToken() {

    }
    @InvocableMethod
    public static List<List<String>> GetAssertionToken() {

        C360AuthController authCtrl = new C360AuthController();
        String assert_token = authCtrl.getAssertionToken();
        List<String> new_token = new List<String>();
        new_token.add(assert_token);
        List<List<String>> values = new List<List<String>>();
        values.add(new_token);
        return values;
    }
}
