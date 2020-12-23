
public class UnifiedIndividualAddressParser {

	public Integer totalSize {get;set;} 
	public Boolean done {get;set;} 
	public List<Records> records {get;set;} 

	public UnifiedIndividualAddressParser(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'totalSize') {
						totalSize = parser.getIntegerValue();
					} else if (text == 'done') {
						done = parser.getBooleanValue();
					} else if (text == 'records') {
						records = arrayOfRecords(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'UnifiedIndividualAddressParser consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Attributes {
		public String type_Z {get;set;} // in json: type
		public String url {get;set;} 

		public Attributes(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type_Z = parser.getText();
						} else if (text == 'url') {
							url = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Attributes consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Records {
		public Attributes attributes {get;set;} 
		public String Id {get;set;} 
		public String PartyId {get;set;} 
		public String AddressLine1 {get;set;} 
		public Object AddressLine2 {get;set;} 
		public String CityName {get;set;} 
		public String StateProvinceName {get;set;} 
		public Object CountryName {get;set;} 
		public String PostalCodeText {get;set;} 

		public Records(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'attributes') {
							attributes = new Attributes(parser);
						} else if (text == 'Id__c') {
							Id = parser.getText();
						} else if (text == 'PartyId__c') {
							PartyId = parser.getText();
						} else if (text == 'AddressLine1__c') {
							AddressLine1 = parser.getText();
						} else if (text == 'AddressLine2__c') {
							AddressLine2 = parser.readValueAs(Object.class);
						} else if (text == 'CityName__c') {
							CityName = parser.getText();
						} else if (text == 'StateProvinceName__c') {
							StateProvinceName = parser.getText();
						} else if (text == 'CountryName__c') {
							CountryName = parser.readValueAs(Object.class);
						} else if (text == 'PostalCodeText__c') {
							PostalCodeText = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Records consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static UnifiedIndividualAddressParser parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new UnifiedIndividualAddressParser(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	








    private static List<Records> arrayOfRecords(System.JSONParser p) {
        List<Records> res = new List<Records>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Records(p));
        }
        return res;
    }


}