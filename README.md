# EXPLORE DATA E-COMMERCE
## 1. Introduction

This is a mini project about exploring data as well as better understanding SQL queries. Use Google Analytics Sample dataset, specifically the ga_sessions_2017 table, is an invaluable resource for anyone looking to delve into data exploration and SQL querying. Hosted on Google BigQuery, this dataset provides a realistic representation of web traffic data, mirroring the kind of information captured by Google Analytics on a hypothetical e-commerce website. By working with this data set, develop data analysis skills, understand user behavior, and master the intricacies of SQL. 

## 2. Available Data : 

**Tables**

Within each dataset, a table is imported for each day of export. Daily tables have the format "ga_sessions_YYYYMMDD".

Intraday data is imported at least three times a day. Intraday tables have the format "ga_sessions_intraday_YYYYMMDD". During the same day, each import of intraday data overwrites the previous import in the same table.

When the daily import is complete, the intraday table from the previous day is deleted. For the current day, until the first intraday import, there is no intraday table. If an intraday-table write fails, then the previous day's intraday table is preserved.

Data for the current day is not final until the daily import is complete. You may notice differences between intraday and daily data based on active user sessions that cross the time boundary of last intraday import.

**Rows**

Each row within a table corresponds to a session in Analytics 360.

**Columns**

* **sessionId**: A unique identifier for each user session.
* **visitNumber**: The sequence number of a session for a specific user.
* **visitId**: A unique identifier for each visit.
* **visitStartTime**: The timestamp marking the beginning of a session.
* **date**: The date when the session occurred.
* **totals**: Aggregated metrics for the session, including pageviews, time on site, and other engagement metrics.
* **trafficSource**: Information about where the user came from, including the source, medium, and campaign.
* **device**: Details about the user's device, such as the type, operating system, and browser.
* **geoNetwork**: Geographical information about the user, including country, region, and city.
* **customDimensions**: Custom-defined dimensions set up in Google Analytics.
* **hits**: Detailed records of user interactions within the session, such as page views and events.
  
**See more detailed data** in the following link : https://support.google.com/analytics/answer/3437719?hl=en

## 3. Case Study Question : 

**1. Query 01** Calculate total visit, pageview, transaction for Jan, Feb and March 2017 (order by month).    
**2. Query 02** Bounce rate per traffic source in July 2017 (Bounce_rate = num_bounce/total_visit) (order by total_visit DESC).     
**3. Query 03** Revenue by traffic source by week, by month in June 2017.    
**4. Query 04** Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017.  
**5. Query 05** Average number of transactions per user that made a purchase in July 2017.    
**6. Query 06** Average amount of money spent per session. Only include purchaser data in July 2017.    
**7. Query 07** Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017. Output should show product name and the quantity was ordered.  
**8. Query 08** Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017. For example, 100% product view then 40% add_to_cart and 10% purchase.

## 4. Answer (Summarize some steps in the answer)
1. - Using **SUM** function to calculate e total number of visits, pageviews, and transactions .
   - **Order by** month
   - Use **format_date** to format the date
2. - Use SUM and difference funcs to calculate
   - Bounce session is the session that user does not raise any click after landing on the website  
3. - Use **unnest** to separate each element inside the hits, product table
   - **UNION ALL** to combine results from two separate query parts  
4.  
   _1. **CTE ap_purchase:**_  
      - Calculates the average number of pageviews per product for sessions with transactions and non-null product revenue from June to July 2017.  
      - Uses FORMAT_DATE to convert the date column value to a year and month format.  
      - Unnests array structures from the hits and hits.product columns.  
      - Groups the results by month and calculates the average number of pageviews per purchaser.  
   _2. **CTE ap_non_purchase:**_  
      - Calculates the average number of pageviews per product for sessions without transactions and null product revenue.  
      - Similar steps are performed as in the ap_purchase CTE, but with appropriate conditions for non-purchasers.  
   _3. **Main Query:**_    
      - Combines the results from the **ap_purchase** and **ap_non_purchase** CTEs using an **INNER JOIN** based on the month column.  
      - The output is the average number of pageviews per product that purchasers and non-purchasers have made, **grouped by** month.
5. - **SUM** , **COUNT** , **WHERE**
   - purchaser: totals.transactions >=1; productRevenue is not null. fullVisitorId field is user id.
   - Add condition "product.productRevenue is not null" to calculate correctly
6. - Where clause must be include "totals.transactions IS NOT NULL" and "product.productRevenue is not null"
   -  **avg_spend_per_session = total revenue/ total visit**
   -  To shorten the result, productRevenue should be divided by 1000000
7. - Condition "product.productRevenue is not null" to calculate correctly
   - Using CTEs ,  Using productQuantity to calculate quantity.
8. - hits.eCommerceAction.action_type = '2' is view product page; hits.eCommerceAction.action_type = '3' is add to cart; hits.eCommerceAction.action_type = '6' is purchase
   - **Cohort map** is used to calculate the percentage of users engaging in each stage of the process, from viewing the product to adding it to the cart and making a purchase, in the months of January, February, and March 2017. Understanding of user behavior over time.
**See more detailed answer in Bigquery** : https://console.cloud.google.com/bigquery?sq=305479952005:9ef9fb0589a5484a8b767a94a97d2611 
## 5. Conclusion 
- These aggregation functions are used to calculate and summarize various metrics and statistics from the dataset, such as total visits, pageviews, transactions, bounce rate, and revenue. (SUM(), COUNT(), AVG(), ROUND(), ...)
- In addition, CTEs are also used for intermediate calculations, reducing the complexity of the answer.

Through the exploration of data using eight SQL queries on the Google Analytics Sample dataset, several insights have been gained into user behavior and website performance. These queries have allowed for a comprehensive analysis of various aspects such as traffic sources, user engagement, revenue generation, and customer purchasing patterns.

**Traffic Analysis:** Queries such as **Query 2** provided insights into **traffic sources**, helping to identify the most significant channels driving visitors to the website.

**User Engagement:** Analysis of metrics like **visits**, **pageviews**, and **bounce rates** **(Query 2)** shed light on user engagement levels and interaction patterns with the website.

**Revenue Generation:** Queries like **Query 3** and **Query 6** delved into revenue generation, revealing the impact of different traffic sources and user behavior on revenue.

**Customer Purchasing Patterns:** **Queries like Query 4** and **Query 7** provided valuable insights into **customer purchasing behavior**, including **average pageviews per purchase** and related **product** **recommendations** for specific purchases.

**Cohort Analysis:** The cohort analysis conducted in **Query 8** helped map the user journey from product view to add-to-cart to purchase, providing a deeper understanding of conversion rates and potential areas for improvement.

In conclusion, these SQL queries have proven to be effective tools for uncovering actionable insights from the dataset, aiding in data-driven decision-making and optimization of website performance for enhanced user experience and revenue generation. Further exploration and refinement of these queries could lead to even more profound insights and opportunities for improvement in the future.

**<3<3<3<3<3<3<3<3<3<3<3<3<3<3<3 THANK FOR WATCHING <3<3<3<3<3<3<3<3<3<3<3<3<3<3<3<3**  
![image](https://github.com/tcongnguyen123/Explore-data-e-commerce/assets/116703297/7dd5fb7c-526a-4d3e-87c0-0f339018bd41)
![image](https://github.com/tcongnguyen123/Explore-data-e-commerce/assets/116703297/dc7ec784-ddd7-4e7a-a8d7-3707601b3fc3)
![image](https://github.com/tcongnguyen123/Explore-data-e-commerce/assets/116703297/17677048-2cd4-46d3-885b-98fd157fdfcb)
![image](https://github.com/tcongnguyen123/Explore-data-e-commerce/assets/116703297/d72a195d-6362-43fb-a0d1-cdb5d384b729)
