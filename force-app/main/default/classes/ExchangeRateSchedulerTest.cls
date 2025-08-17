@SuppressWarnings('PMD.MethodNamingConventions')
/**
 * @description Test class for the ExchangeRateScheduler
 * This will be provided to students to test their scheduler implementation
 */
@isTest
private class ExchangeRateSchedulerTest {

    /**
     * @description Creates a standard user and assigns the 'ExchangeRate' permission set.
     * This setup runs once before all test methods in the class.
     */
    @TestSetup
    static void makeData() {
        TestDataFactory.createUserWithPermissionSets(new List<String>{'ExchangeRate', 'Exchange_Rate_Access', 'Custom_Log_Read_Create'});
    }
    
    /**
     * @description Tests the execute method of the scheduler
     */
    @isTest
    static void testExecute() {
        // Set up the mock
        Test.setMock(HttpCalloutMock.class, new ExchangeRateMock());
        
        // Create an instance of the scheduler
        ExchangeRateScheduler scheduler = new ExchangeRateScheduler('USD');
        
        // Call the execute method directly
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Alias = 'testusr'];
        System.runAs(testUser){
            scheduler.execute(null); // Passing null as the context is sufficient for testing
        }
        Test.stopTest();
        
        // Verify that exchange rates were created
        List<Exchange_Rate__c> rates = [
            SELECT Id, Base_Currency__c, Target_Currency__c, Rate__c
            FROM Exchange_Rate__c
        ];
        System.assertEquals(9, rates.size(), 'Should have 9 exchange rate records');
    }
    
    /**
     * @description Tests error handling in the execute method
     */
    @isTest
    static void testExecute_Error() {
        // Set up the mock for an error response
        Test.setMock(HttpCalloutMock.class, new ExchangeRateMock(true));
        
        // Create an instance of the scheduler
        ExchangeRateScheduler scheduler = new ExchangeRateScheduler('USD');
        
        // Call the execute method and ensure it handles errors gracefully
        Test.startTest();
        try {
            User testUser = [SELECT Id FROM User WHERE Alias = 'testusr'];
            System.runAs(testUser){
                scheduler.execute(null);
            }
            // The execute method should catch exceptions, so we should not assert failure here
        } catch (Exception e) {
            System.assert(false, 'The execute method should handle exceptions: ' + e.getMessage());
        }
        Test.stopTest();
        
        // Verify that no exchange rates were created (due to the error)
        List<Exchange_Rate__c> rates = [
            SELECT Id FROM Exchange_Rate__c
        ];
        System.assertEquals(0, rates.size(), 'Should have no exchange rate records due to error');
    }
}