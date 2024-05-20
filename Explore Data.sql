--q1 calculate total visit, pageview, transaction for Jan, Feb and March 2017 (order by month)
SELECT FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date))                         month,
       SUM(totals.visits)                                                     visits,
       SUM(totals.pageviews)                                                  pageviews,
       SUM(totals.transactions)                                               transactions 
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE _table_suffix BETWEEN '0101' AND '0331'
GROUP BY month
ORDER BY month;

-- q2 Bounce rate per traffic source in July 2017 (Bounce_rate = num_bounce/total_visit) (order by total_visit DESC)
SELECT trafficSource.source, 
       SUM(totals.visits)                                                      total_visits,
       SUM(totals.bounces)                                                     total_no_of_bounces,
       (SUM(totals.bounces)/SUM(totals.visits)) * 100.0                        bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
GROUP BY trafficSource.source
ORDER BY total_visits DESC;

--q3 Revenue by traffic source by week, by month in June 2017
SELECT 'Week'                                                                  time_type,
        FORMAT_DATE("%Y%W",PARSE_DATE('%Y%m%d',date))                          time,
        trafficSource.source                                                   source,
        SUM((product.productRevenue)/1000000)                                  revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
UNNEST (hits)                                                                  hits,
UNNEST (hits.product)                                                          product
GROUP BY time,trafficSource.source
UNION ALL
SELECT 'Month'                                                                 time_type,
        FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date))                         time,
        trafficSource.source                                                   source,
        SUM((product.productRevenue)/1000000)                                  revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
UNNEST (hits)                                                                  hits,
UNNEST (hits.product)                                                          product
GROUP BY time,trafficSource.source
ORDER BY revenue DESC;

--q4  Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017.
WITH ap_purchase AS ( 
    SELECT FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date))                      month,
          SUM(totals.pageviews) / COUNT(DISTINCT fullVisitorId)                avg_pageviews_purchase
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
    UNNEST (hits)                                                              hits,
    UNNEST (hits.product)                                                      product
    WHERE _table_suffix BETWEEN '0601' AND '0731' AND totals.transactions >=1 AND product.productRevenue IS NOT NULL 
    GROUP BY month ),
ap_non_purchase AS ( 
    SELECT FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date))                      month,
          SUM(totals.pageviews) / COUNT(DISTINCT fullVisitorId)                avg_pageviews_non_purchase
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
    UNNEST (hits)                                                              hits,
    UNNEST (hits.product)                                                      product
    WHERE _table_suffix BETWEEN '0601' AND '0731' AND totals.transactions IS NULL AND product.productRevenue IS NULL 
    GROUP BY month )
SELECT a.month,
       avg_pageviews_purchase,
       avg_pageviews_non_purchase 
FROM ap_purchase                  a
INNER JOIN ap_non_purchase        a_non ON a.month = a_non.month;

--q5 Average number of transactions per user that made a purchase in July 2017
SELECT FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date))                           month,
      SUM(totals.transactions) / COUNT(DISTINCT fullVisitorId)                  avg_pageviews_purchase
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
UNNEST (hits)                                                                   hits,
UNNEST (hits.product)                                                           product
WHERE totals.transactions >=1 AND product.productRevenue IS NOT NULL 
GROUP BY month; 

--q6 Average amount of money spent per session. Only include purchaser data in July 2017
SELECT FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date))                           month,
       (SUM(product.productRevenue)/COUNT(totals.visits))/1000000     avg_revenue_by_user_per_visit                                            
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
UNNEST (hits)                                                                   hits,
UNNEST (hits.product)                                                           product
WHERE totals.transactions IS NOT NULL AND product.productRevenue IS NOT NULL
GROUP BY month;

--q7 Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017. Output should show product name and the quantity was ordered.
WITH visitor_purchased_products AS (
SELECT fullVisitorId,
       product.v2ProductName                                             
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
UNNEST (hits)                                                                    hits,
UNNEST (hits.product)                                                            product
WHERE product.v2ProductName="YouTube Men's Vintage Henley" AND product.productRevenue IS NOT NULL
GROUP BY fullVisitorId,product.v2ProductName )
SELECT product.v2ProductName                                                     other_purchased_products,
       SUM(product.productQuantity)                                              quantity 
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*` t, 
UNNEST (hits)                                                                    hits,
UNNEST (hits.product)                                                            product
INNER JOIN visitor_purchased_products ON visitor_purchased_products.fullVisitorId = t.fullVisitorId
WHERE product.productRevenue IS NOT NULL AND product.v2ProductName NOT LIKE "YouTube Men's Vintage Henley"
GROUP BY other_purchased_products
ORDER BY quantity DESC;

--q8  Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017. For example, 100% product view then 40% add_to_cart and 10% purchase.
WITH product_view as (
  SELECT FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date))                           month,
       COUNT(product.v2ProductName)                                               num_product_view
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
  UNNEST (hits)                                                                   hits,
  UNNEST (hits.product)                                                           product
  WHERE _table_suffix BETWEEN '0101' AND '0331' AND eCommerceAction.action_type = '2'
  GROUP BY month ),
product_addtocart AS (
  SELECT FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date))                           month,
      COUNT(product.v2ProductName)                                                num_addtocart
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
  UNNEST (hits)                                                                   hits,
  UNNEST (hits.product)                                                           product
  WHERE _table_suffix BETWEEN '0101' AND '0331' AND eCommerceAction.action_type = '3'
  GROUP BY month),
product_purchase AS (
  SELECT FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d',date))                           month,
      COUNT(product.v2ProductName)                                                num_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
  UNNEST (hits)                                                                   hits,
  UNNEST (hits.product)                                                           product
  WHERE _table_suffix BETWEEN '0101' AND '0331' AND eCommerceAction.action_type = '6' AND product.productRevenue IS NOT NULL 
  GROUP BY month)
SELECT v.month,
       v.num_product_view                                                         num_product_view,
       a.num_addtocart                                                            num_addtocart,  
       p.num_purchase                                                             num_purchase,
       ROUND(((num_addtocart/num_product_view)*100.0),2)                          add_to_cart_rate,
       ROUND(((num_purchase/num_product_view)*100.0),2)                           purchase_rate                        
FROM product_view   v
INNER JOIN product_addtocart a ON v.month = a.month 
INNER JOIN product_purchase  p ON p.month = v.month
ORDER BY month;









