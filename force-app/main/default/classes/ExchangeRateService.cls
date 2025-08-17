/**
 * @description Service class that handles API callouts to the Exchange Rate API
 * Students will implement the methods to make callouts and process responses
 */
public with sharing class ExchangeRateService {
  // The named credential to use for the callout
  private static final String NAMED_CREDENTIAL = 'callout:ExchangeRate_API';

  // The base currency to use for exchange rates
  // private static final String BASE_CURRENCY = 'USD';

  /**
   * @description Makes a callout to the Exchange Rate API to get the latest exchange rates
   * @param baseCurrency The base currency to use for exchange rates
   * @return ExchangeRateWrapper containing the response data
   */
  public static ExchangeRateWrapper getLatestRates(String baseCurrency) {
    HttpRequest request = new HttpRequest();
    request.setEndpoint(NAMED_CREDENTIAL + '/latest/' + baseCurrency);
    request.setMethod('GET');
    Http http = new Http();
    try {
      HttpResponse response = http.send(request);
      if (response.getStatusCode() == 200) {
        return ExchangeRateWrapper.parse(response.getBody());
      }
      throw new ExchangeRateException(response.getStatus());
    } catch (Exception e) {
      // Logging errors to log object
      Custom_Log__c log = new Custom_Log__c();
      log.Message__c = e.getMessage();
      log.Log_Level__c = 'Error';
      log.Stack_Trace__c = e.getStackTraceString();
      if (Schema.SObjectType.Custom_Log__c.isCreateable()) {
        insert as user log;
      }
      throw e;
    }
  }

  /**
   * @description Processes the exchange rate data and creates or updates records
   * @param rateData The wrapper containing exchange rate data
   * @return List<Exchange_Rate__c> The list of records created or updated
   */
  public static List<Exchange_Rate__c> processRates(
    ExchangeRateWrapper rateData
  ) {
    // TODO: Implement the method to process rates and create/update records
    try {
      List<Exchange_Rate__c> rates = rateData.toExchangeRates();
      if (
        !Schema.SObjectType.Exchange_Rate__c.isCreateable() &&
        !Schema.SObjectType.Exchange_Rate__c.isUpdateable()
      ) {
        throw new ExchangeRateException(
          'No Exchange Rate records insert or update permission'
        );
      }
      upsert as user rates External_Id__c; // Update through External Id field
      return rates;
    } catch (Exception e) {
      // Logging errors to log object
      Custom_Log__c log = new Custom_Log__c();
      log.Message__c = e.getMessage();
      log.Log_Level__c = 'Error';
      log.Stack_Trace__c = e.getStackTraceString();
      if (Schema.SObjectType.Custom_Log__c.isCreateable()) {
        insert as user log;
      }
      throw e;
    }
  }

  /**
   * @description Combines getting and processing rates into a single operation
   * @param baseCurrency The base currency to use for exchange rates
   * @return List<Exchange_Rate__c> The list of records created or updated
   */
  public static List<Exchange_Rate__c> updateExchangeRates(
    String baseCurrency
  ) {
    // 1. Call getLatestRates to retrieve the data
    ExchangeRateWrapper rateData = getLatestRates(baseCurrency);
    // 2. Call processRates to create/update records
    List<Exchange_Rate__c> rates = processRates(rateData);
    // 3. Return the processed records
    return rates;
  }

  public class ExchangeRateException extends Exception {
  }
}
