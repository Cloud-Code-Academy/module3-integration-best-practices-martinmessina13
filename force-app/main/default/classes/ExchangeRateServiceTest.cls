@SuppressWarnings('PMD.MethodNamingConventions')
/**
 * @description Test class for the ExchangeRateService
 * This will be provided to students to test their implementation
 * THIS TEST CLASS WILL NOT BE ABLE TO BE DEPLOYED UNTIL YOU IMPLEMENT THE WRAPPER CLASS
 */
@isTest
private class ExchangeRateServiceTest {
    
    /**
     * @description Tests the getLatestRates method with a successful response
     */
    @isTest
    static void testGetLatestRates_Success() {
        // Set up the mock for a successful response
        Test.setMock(HttpCalloutMock.class, new ExchangeRateMock());
        
        // Call the method to test
        Test.startTest();
        ExchangeRateWrapper wrapper = ExchangeRateService.getLatestRates('USD');
        Test.stopTest();
        
        // Verify the result
        Assert.areNotEqual(null, wrapper, 'Wrapper should not be null');
        Assert.areEqual('USD', wrapper.base_code, 'Base currency should be USD');
        Assert.areEqual(9, wrapper.conversion_rates.size(), 'Should have 9 rates');
        Assert.areEqual(0.9488, wrapper.conversion_rates.get('EUR'), 'EUR rate should match');
    }
    
    /**
     * @description Tests the getLatestRates method with an error response
     */
    @isTest
    static void testGetLatestRates_Error() {
        // Set up the mock for an error response
        Test.setMock(HttpCalloutMock.class, new ExchangeRateMock(true));
        
        // Call the method to test and expect an exception
        Test.startTest();
        try {
            ExchangeRateWrapper wrapper = ExchangeRateService.getLatestRates('USD');
            Assert.fail('Should have thrown an exception');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('Error'), 'Exception message should mention error');
        }
        Test.stopTest();
    }
    
    /**
     * @description Tests the processRates method
     */
    @isTest
    static void testProcessRates() {
        // Create a wrapper manually
        ExchangeRateWrapper wrapper = new ExchangeRateWrapper();
        wrapper.base_code = 'USD';
        wrapper.time_last_update_unix = '1740690001';
        
        // Add rates
        wrapper.conversion_rates = new Map<String, Decimal>{
            'EUR' => 0.9488,
            'GBP' => 0.8393,
            'JPY' => 136.57
        };
        
        // Process the rates
        Test.startTest();
        List<Exchange_Rate__c> rates = ExchangeRateService.processRates(wrapper);
        Test.stopTest();
        
        // Verify the results
        Assert.areEqual(3, rates.size(), 'Should have 3 exchange rate records');
        
        // Check that all rates have the correct fields
        for (Exchange_Rate__c rate : rates) {
            Assert.areEqual('USD', rate.Base_Currency__c, 'Base currency should be USD');
            Assert.areNotEqual(null, rate.Rate__c, 'Rate should not be null');
            Assert.areNotEqual(null, rate.Last_Updated__c, 'Last updated should not be null');
        }
        
        // Query to verify that records were inserted
        List<Exchange_Rate__c> insertedRates = [
            SELECT Id, Base_Currency__c, Target_Currency__c, Rate__c
            FROM Exchange_Rate__c
        ];
        Assert.areEqual(3, insertedRates.size(), 'Should have 3 records in the database');
    }
    
    /**
     * @description Tests the processRates method's exception block
     */
    @isTest
    static void testProcessRatesException() {
        try{
            // Process the rates
            Test.startTest();
            List<Exchange_Rate__c> rates = ExchangeRateService.processRates(null);
        }
        catch(Exception e){
            List<Custom_Log__c> logs = [
                SELECT 
                Id,
                Log_Level__c,
                Message__c 
                FROM Custom_Log__c
            ];
            Assert.areEqual(1, logs.size(), 'There should be only one log in the queried list');

            Custom_Log__c log = logs[0];
            Assert.areEqual('Error', log.Log_Level__c, 'Log Level is not error');
            Assert.areEqual(e.getMessage(), log.Message__c, 'Log Message is not correct');
            Assert.areEqual('System.NullPointerException', e.getTypeName(), 'Exception Type is not correct');
            Test.stopTest();
        }
    }
    
    /**
     * @description Tests the updateExchangeRates method
     */
    @isTest
    static void testUpdateExchangeRates() {
        // Set up the mock
        Test.setMock(HttpCalloutMock.class, new ExchangeRateMock());
        
        // Call the method to test
        Test.startTest();
        List<Exchange_Rate__c> rates = ExchangeRateService.updateExchangeRates('USD');
        Test.stopTest();
        
        // Verify the results
        Assert.areEqual(9, rates.size(), 'Should have 9 exchange rate records');
        
        // Query to verify that records were inserted
        List<Exchange_Rate__c> insertedRates = [
            SELECT Id, Base_Currency__c, Target_Currency__c, Rate__c
            FROM Exchange_Rate__c
        ];
        Assert.areEqual(9, insertedRates.size(), 'Should have 9 records in the database');
    }
}