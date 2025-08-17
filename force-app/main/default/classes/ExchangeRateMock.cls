/**
 * @description Mock HTTP class for testing the Exchange Rate API integration
 * This class will be provided to students
 */
@isTest
public class ExchangeRateMock implements HttpCalloutMock {
  // Flag to simulate an error response
  private Boolean simulateError;

  /**
   * @description Constructor
   * @param simulateError Whether to simulate an error response
   */
  public ExchangeRateMock(Boolean simulateError) {
    this.simulateError = simulateError;
  }

  /**
   * @description Default constructor - no error simulation
   */
  public ExchangeRateMock() {
    this(false);
  }

  /**
   * @description Implements the HttpCalloutMock interface to respond with mock data
   * @param request The HTTP request
   * @return HttpResponse The mocked HTTP response
   */
  public HttpResponse respond(HttpRequest request) {
    // Create a mock response
    HttpResponse response = new HttpResponse();

    // Set the response status and body based on error flag
    if (simulateError) {
      response.setStatusCode(500);
      response.setStatus('Error');
      response.setBody('{"error": "Internal Server Error"}');
    } else {
      response.setStatusCode(200);
      response.setBody(getSuccessfulResponse());
    }

    response.setHeader('Content-Type', 'application/json');
    return response;
  }

  /**
   * @description Returns a successful mock response body
   * @return String The JSON response body
   */
  private String getSuccessfulResponse() {
    return '{' +
      '"base_code": "USD",' +
      '"time_last_update_unix": 1740690001,' +
      '"conversion_rates": {' +
      '  "EUR": 0.9488,' +
      '  "GBP": 0.8393,' +
      '  "JPY": 136.57,' +
      '  "CAD": 1.3594,' +
      '  "AUD": 1.4915,' +
      '  "CNY": 6.9571,' +
      '  "INR": 82.7275,' +
      '  "BRL": 5.2094,' +
      '  "MXN": 18.2985' +
      '}' +
      '}';
  }

  /**
   * @description Returns a JSON response with empty rates
   * @return String The JSON response body with empty rates
   */
  public static String getEmptyRatesResponse() {
    return '{' +
      '"base_code": "USD",' +
      '"time_last_update_unix": 1740690001,' +
      '"conversion_rates": {}' +
      '}';
  }

  /**
   * @description Returns a JSON response with invalid data
   * @return String An invalid JSON response
   */
  public static String getInvalidResponse() {
    return '{This is not valid JSON}';
  }
}
