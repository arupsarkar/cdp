public class C360AuthController {
    public String cdp_token;
    public static List<C360Auth__mdt> getAllRecords() {
        return [ SELECT DeveloperName, MasterLabel, jwt_aud__c, jwt_exp__c, jwt_iss__c,jwt_sub__c  
                	FROM C360Auth__mdt 
                	WHERE MasterLabel = 'C360 Auth Settings'
                	LIMIT 1];
    }

    public C360AuthController() {
        String token = getAccessToken();
        System.debug(LoggingLevel.DEBUG, token);
        String cdptoken = getCDPToken(token);
        this.cdp_token = cdptoken;
    }

    private string getCDPToken(string core_token) {
        String tokenEndPoint = 'https://rcgcdp228.my.salesforce.com/services/a360/token';
        String body1 = 'grant_type=' + EncodingUtil.urlEncode('urn:salesforce:grant-type:external:cdp', 'UTF-8');
        String body2 = '&subject_token=' + EncodingUtil.urlEncode(core_token, 'UTF-8');
        String body3 = '&subject_token_type=' + EncodingUtil.urlEncode('urn:ietf:params:oauth:token-type:access_token', 'UTF-8');
        String body = body1 + body2 + body3;
        
        System.debug(LoggingLevel.DEBUG, body);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(tokenEndpoint);
        req.setHeader('Content-type', 'application/x-www-form-urlencoded');
        req.setBody(body);
        Http http = new Http();               
        HTTPResponse res = http.send(req);
        String access_token;
        System.debug(LoggingLevel.DEBUG, ' response code ' + res.getStatusCode());
        System.debug(LoggingLevel.DEBUG, ' response body ' + res.getBody());  
        if ( res.getStatusCode() == 200 ) {
            System.JSONParser parser = System.JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                    parser.nextToken();
                    access_token = parser.getText();
                    break;
                }
            }
        }
        return access_token;                      
    }

    public string getAssertionToken() {
        String token, iss, sub, aud, exp, token_endpoint;
        List<C360Auth__mdt> eass =  getAllRecords();
        for(C360Auth__mdt eas : eass ) {
            if(eas.MasterLabel.equals('C360 Auth Settings')) {
                iss = eas.jwt_iss__c;
                sub = eas.jwt_sub__c;
                aud = eas.jwt_aud__c;
                exp = eas.jwt_exp__c;
            }
        }
        // Ignore the File upload part and "jwt.pkcs" if you used a Salesforce certificate to sign up 
        // for an Einstein Platform account
        ContentVersion base64Content = [SELECT Title, VersionData FROM ContentVersion where Title='server' ORDER BY Title LIMIT 1];
        String keyContents = base64Content.VersionData.tostring();
        keyContents = keyContents.replace('-----BEGIN RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');
        System.debug(LoggingLevel.DEBUG, keyContents);
        // Get a new token
        JWT jwt = new JWT('RS256');
        //jwt.cert = 'JWTCert'; // Uncomment this if you used a Salesforce certificate to sign up for an Einstein Platform account
        jwt.pkcs8 = keyContents; // Comment this if you are using jwt.cert
        //jwt.cert = keyContents;
        jwt.iss = iss;
        jwt.sub = sub;
        jwt.aud = aud;
        jwt.exp = exp;
        token_endpoint = aud;
        String assertion_token = JWTBearerFlow.getAssertionValue(jwt);
        return assertion_token;        
    }
    public string getAccessToken() {
        String token, iss, sub, aud, exp, token_endpoint;
        List<C360Auth__mdt> eass =  getAllRecords();
        for(C360Auth__mdt eas : eass ) {
            if(eas.MasterLabel.equals('C360 Auth Settings')) {
                iss = eas.jwt_iss__c;
                sub = eas.jwt_sub__c;
                aud = eas.jwt_aud__c;
                exp = eas.jwt_exp__c;
            }
        }
        // Ignore the File upload part and "jwt.pkcs" if you used a Salesforce certificate to sign up 
        // for an Einstein Platform account
        ContentVersion base64Content = [SELECT Title, VersionData FROM ContentVersion where Title='server' ORDER BY Title LIMIT 1];
        String keyContents = base64Content.VersionData.tostring();
        keyContents = keyContents.replace('-----BEGIN RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');
        System.debug(LoggingLevel.DEBUG, keyContents);
        // Get a new token
        JWT jwt = new JWT('RS256');
        //jwt.cert = 'JWTCert'; // Uncomment this if you used a Salesforce certificate to sign up for an Einstein Platform account
        jwt.pkcs8 = keyContents; // Comment this if you are using jwt.cert
        //jwt.cert = keyContents;
        jwt.iss = iss;
        jwt.sub = sub;
        jwt.aud = aud;
        jwt.exp = exp;
        token_endpoint = aud;
        String access_token = JWTBearerFlow.getAccessToken(token_endpoint, jwt);
    	System.debug(LoggingLevel.DEBUG, '---> access token ' + access_token);
        return access_token;
    }

}
