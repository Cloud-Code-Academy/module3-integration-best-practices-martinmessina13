/**
 * @description Scheduler class to run the exchange rate update on a schedule
 * Scheduling should be done in Salesforce Setup Apex Classes -> Schedule Apex
 */
public with sharing class ExchangeRateScheduler implements Schedulable {
  private String baseCurrency;

  public ExchangeRateScheduler(String baseCurrency) {
    this.baseCurrency = baseCurrency;
  }
  /**
   * @description Executes the scheduled job to update exchange rates
   * @param context The SchedulableContext
   */
  public void execute(SchedulableContext context) {
    // TODO: Implement the method to update exchange rates
    // 1. Call ExchangeRateService.updateExchangeRates()
    try {
      // 2. Add error handling
      ExchangeRateService.updateExchangeRates(this.baseCurrency);
    } catch (Exception e) {
      // 3. Consider adding logging if available
      Custom_Log__c log = new Custom_Log__c();
      log.Message__c = e.getMessage();
      log.Log_Level__c = 'Error';
      log.Stack_Trace__c = e.getStackTraceString();
      if (Schema.SObjectType.Custom_Log__c.isCreateable()) {
        insert as user log;
      }
    }
  }
}
