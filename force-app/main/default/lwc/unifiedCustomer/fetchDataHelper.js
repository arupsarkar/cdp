// const recordMetadata = {
//     name: 'name',
//     email: 'email',
//     website: 'url',
//     amount: 'currency',
//     phone: 'phoneNumber',
//     closeAt: 'dateInFuture',
// };

const recordMetadata = {
    FirstName__c: 'First Name',
    LastName__c: 'Last Name'
};

export default function fetchDataHelper({ amountOfRecords }) {
    return fetch('/services/data/v50.0/query/?q=SELECT+FirstName__c+,+LastName__c+FROM+UnifiedIndividual__dlm+LIMIT+10', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=utf-8',
        },
        body: JSON.stringify({
            amountOfRecords,
            recordMetadata,
        }),
    }).then(response => response.json());
}


// String query = 'SELECT FirstName__c, LastName__c' + 
// ' FROM UnifiedIndividual__dlm' +
// ' WHERE LastName__c != LIMIT 10';
// String urlEncodedQuery = EncodingUtil.urlEncode(query, 'UTF-8');    

// String url = 'https://rcgcdp228.my.salesforce.com/services/data/v50.0/query/?q=' +
// 'SELECT+FirstName__c+,+LastName__c+FROM+UnifiedIndividual__dlm+WHERE+LastName__c+!=+null' +
// '+LIMIT+10';

// //String url = 'https://rcgcdp228.my.salesforce.com/services/data/v50.0/query/?q='+query;
// String urlEncodedURL = EncodingUtil.urlEncode(url, 'UTF-8');    
// System.debug(LoggingLevel.DEBUG, '>>> url ' + url);
// Http h = new Http();
// HttpRequest req = new HttpRequest(); 
// req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
// //req.setHeader('Content-Type', 'application/json;charset=UTF-8');
// req.setHeader('authorization', 'Bearer ' + UserInfo.getSessionId());
// req.setEndpoint(url);
// req.setMethod('GET');

// HttpResponse res = h.send(req);
// System.debug(LoggingLevel.DEBUG, '>>> output ' + res.getBody());