global class JWTBearerFlow {
    global static string getAssertionValue(JWT jwt) {
        String assertion_token = jwt.issue();
        return assertion_token;
    }

    global static String getAccessToken(String tokenEndpoint, JWT jwt) {
        
        String jwt_issue = jwt.issue();
        System.debug(LoggingLevel.DEBUG, jwt_issue);
        System.debug(LoggingLevel.DEBUG, tokenEndpoint);
        String access_token = null;
        String body = 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=' + jwt_issue;
        HttpRequest req = new HttpRequest();                            
        req.setMethod('POST');
        req.setEndpoint(tokenEndpoint);
        req.setHeader('Content-type', 'application/x-www-form-urlencoded');
        req.setBody(body);
        Http http = new Http();               
        HTTPResponse res = http.send(req);
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

}