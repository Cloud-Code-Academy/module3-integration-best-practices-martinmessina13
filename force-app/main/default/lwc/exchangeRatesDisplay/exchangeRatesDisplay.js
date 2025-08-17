import { LightningElement, wire } from "lwc";
import { gql, graphql } from "lightning/uiGraphQLApi";
import { reduceErrors } from "c/ldsUtils";

import BASE_OPTIONS from "./currencyOptions";

const COLUMNS = [
  {
    label: "Target Currency",
    fieldName: "targetCurrency",
    hideDefaultActions: true
  },
  {
    label: "Rate",
    fieldName: "rate",
    hideDefaultActions: true
  }
];

const QUERY = gql`
  query ExchangeRates($pageSize: Int!, $cursor: String, $baseCurrency: String) {
    uiapi {
      query {
        Exchange_Rate__c(
          first: $pageSize
          after: $cursor
          where: { Base_Currency__c: { eq: $baseCurrency } }
          orderBy: { LastModifiedDate: { order: ASC } }
        ) {
          edges {
            node {
              Id
              Base_Currency__c {
                value
                displayValue
              }
              Rate__c {
                value
                displayValue
              }
              Target_Currency__c {
                value
                displayValue
              }
              LastModifiedDate {
                value
              }
            }
            cursor
          }
          pageInfo {
            hasNextPage
            endCursor
          }
          totalCount
        }
      }
    }
  }
`;

export default class ExchangeRatesDisplay extends LightningElement {
  data = [];
  errors;
  columns = COLUMNS;

  pageSize = 10;
  cursor;
  loading = false;
  hasNext = false;

  baseCurrency = "ARS";

  baseOptions = BASE_OPTIONS;

  // pagination state from GraphQL
  endCursor;
  hasNextPage = false;

  isLoading = true;

  get variables() {
    return {
      pageSize: this.pageSize,
      cursor: this.cursor,
      baseCurrency: this.baseCurrency
    };
  }

  // implementing GraphQL wire adapter to avoid writing Apex
  @wire(graphql, { query: QUERY, variables: "$variables" })
  wiredRates({ data, errors }) {
    this.isLoading = false;
    if (errors) {
      // handle errors appropriately
      this.data = null;
      this.errors = reduceErrors(errors);
      return;
    }
    if (data) {
      const resp = data.uiapi.query.Exchange_Rate__c;
      const pageRows = resp.edges.map((e) => {
        const n = e.node;
        return {
          id: n.Id,
          rate: n.Rate__c?.displayValue ?? n.Rate__c?.value,
          targetCurrency:
            n.Target_Currency__c?.displayValue ?? n.Target_Currency__c?.value
        };
      });
      this.data = pageRows;
      this.errors = null;
      this.hasNext = resp.pageInfo?.hasNextPage;
      this.endCursor = resp.pageInfo?.endCursor;
    }
  }

  loadMore() {
    this.isLoading = true;
    if (!this.hasNext) {
      this.cursor = undefined;
      return;
    }
    // updating the tracked cursor triggers the wire to fetch next page
    this.cursor = this.endCursor;
  }

  handleChange(event) {
    // reset adapter
    this.isLoading = true;
    this.cursor = undefined;
    this.baseCurrency = event.detail.value;
  }
}
