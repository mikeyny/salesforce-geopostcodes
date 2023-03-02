trigger UpdateAccountsWithGeoPostCode on Account (before insert, before update) {
    // collect all postcodes into a set
    Set<String> billingPostCodes = new Set<String>();
    for (Account acc : Trigger.new) {
        billingPostCodes.add(acc.BillingPostalCode);
    }
    
    // Query the GeoPostcodes custom object for matching records
    List<GeoPostcodes__c> matchingGeoPostcodes = [
        SELECT postcode__c, latitude__c, longitude__c
        FROM GeoPostcodes__c
        WHERE postcode__c IN :billingPostCodes
    ];
                        
    // Build a map of BillingPostCode to GeoPostcodes record
    Map<String, GeoPostcodes__c> geoPostcodesByBillingPostCode = new Map<String, GeoPostcodes__c>();
    for (GeoPostcodes__c geo : matchingGeoPostcodes) {
        geoPostcodesByBillingPostCode.put(geo.postcode__c, geo);
    }
    
    // Update the account records with the geo data
    for (Account acc : Trigger.new) {
        GeoPostcodes__c geo = geoPostcodesByBillingPostCode.get(acc.BillingPostalCode);
        if (geo != null) {
            acc.BillingLatitude = geo.latitude__c;
            acc.BillingLongitude = geo.longitude__c;
        }
    }
}