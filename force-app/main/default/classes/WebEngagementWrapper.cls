
public class WebEngagementWrapper {

	public class UnifiedId {
		public Integer placeInOrder {get;set;} 
		public Integer typeCode {get;set;} 
		public String type_Z {get;set;} // in json: type

		public UnifiedId(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'placeInOrder') {
							placeInOrder = parser.getIntegerValue();
						} else if (text == 'typeCode') {
							typeCode = parser.getIntegerValue();
						} else if (text == 'type') {
							type_Z = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'UnifiedId consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public List<Data> data {get;set;} 
	public String startTime {get;set;} 
	public String endTime {get;set;} 
	public Integer rowCount {get;set;} 
	public String queryId {get;set;} 
	public Boolean done {get;set;} 
	public Metadata metadata {get;set;} 

	public WebEngagementWrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'data') {
						data = arrayOfData(parser);
					} else if (text == 'startTime') {
						startTime = parser.getText();
					} else if (text == 'endTime') {
						endTime = parser.getText();
					} else if (text == 'rowCount') {
						rowCount = parser.getIntegerValue();
					} else if (text == 'queryId') {
						queryId = parser.getText();
					} else if (text == 'done') {
						done = parser.getBooleanValue();
					} else if (text == 'metadata') {
						metadata = new Metadata(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'WebEngagementWrapper consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Metadata {
		public UnifiedId UnifiedId {get;set;} 
		public UnifiedId EngagementDevice {get;set;} 
		public UnifiedId ProductSKU {get;set;} 
		public UnifiedId Content {get;set;} 
		public UnifiedId EngagementChannel {get;set;} 
		public UnifiedId EngagementEvent {get;set;} 
		public UnifiedId EngagementTime {get;set;} 

		public Metadata(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'UnifiedId') {
							UnifiedId = new UnifiedId(parser);
						} else if (text == 'EngagementDevice') {
							EngagementDevice = new UnifiedId(parser);
						} else if (text == 'ProductSKU__c') {
							ProductSKU = new UnifiedId(parser);
						} else if (text == 'Content') {
							Content = new UnifiedId(parser);
						} else if (text == 'EngagementChannel') {
							EngagementChannel = new UnifiedId(parser);
						} else if (text == 'EngagementEvent') {
							EngagementEvent = new UnifiedId(parser);
						} else if (text == 'EngagementTime') {
							EngagementTime = new UnifiedId(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Metadata consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Data {
		public String UnifiedId {get;set;} 
		public String EngagementDevice {get;set;} 
		public String ProductSKU {get;set;} 
		public String Content {get;set;} 
		public String EngagementChannel {get;set;} 
		public String EngagementEvent {get;set;} 
		public String EngagementTime {get;set;} 

		public Data(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'UnifiedId') {
							UnifiedId = parser.getText();
						} else if (text == 'EngagementDevice') {
							EngagementDevice = parser.getText();
						} else if (text == 'ProductSKU__c') {
							ProductSKU = parser.getText();
						} else if (text == 'Content') {
							Content = parser.getText();
						} else if (text == 'EngagementChannel') {
							EngagementChannel = parser.getText();
						} else if (text == 'EngagementEvent') {
							EngagementEvent = parser.getText();
						} else if (text == 'EngagementTime') {
							EngagementTime = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Data consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static WebEngagementWrapper parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new WebEngagementWrapper(parser);
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
	

    private static List<Data> arrayOfData(System.JSONParser p) {
        List<Data> res = new List<Data>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Data(p));
        }
        return res;
    }

}