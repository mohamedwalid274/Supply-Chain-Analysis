--SECTION 1 — Executive Performance
--Q1 What is the total Gross Sales?
SELECT 
    SUM(Gross_Sales) AS Total_Gross_Sales
FROM Fact_Orders
--Q2 What is the total reported revenue?
SELECT 
    SUM([Revenue_generated]) AS Total_Revenue
FROM Fact_Orders
--Q3 What is the total cost?
SELECT 
    SUM(Costs) AS Total_Cost
FROM Fact_Orders
--Q4 What is the gross profit?
SELECT
    SUM(Gross_Sales) AS Gross_Sales,
    SUM(Costs) AS Total_Cost,
    SUM(Gross_Sales - Costs) AS Gross_Profit
FROM Fact_Orders
--Q5 What is the overall gross margin?
SELECT
    SUM(Gross_Sales - Costs) 
        / NULLIF(SUM(Gross_Sales),0) * 100 AS Gross_Margin_Percentage
FROM Fact_Orders
--Q6 How many units were sold?
select
SUM(Number_of_products_sold) as Total_units_sold 
from Fact_Orders
--Q7 What is the average selling price?
select
AVG(Price) as Averageg_price 
from Fact_Orders
--Q8 What is the average order quantity?
select 
AVG(Order_quantities) as Average_order_quantities
from Fact_Orders
--Q9 How much does Revenue Generated differ from Gross Sales?
SELECT
    SUM([Revenue_generated]) AS Reported_Revenue,
    SUM(Gross_Sales) AS Gross_Sales,
    SUM([Revenue_generated]) - SUM(Gross_Sales) AS Difference,
    (
        SUM([Revenue_generated]) - SUM(Gross_Sales)
    ) / NULLIF(SUM(Gross_Sales),0) * 100 AS Difference_Percentage
FROM Fact_Orders
--Q10 Which product category contributes most to sales?
SELECT
    [Product_type],
    SUM(Gross_Sales) AS Sales,
    SUM(Gross_Sales) * 100.0 /
        SUM(SUM(Gross_Sales)) OVER() AS Sales_Share
FROM Fact_Orders
GROUP BY [Product_type]
ORDER BY Sales DESC
--SECTION 2 — Product & SKU Intelligence
--Q11 Which product category generates the highest profit?
SELECT
    [Product_type],
    SUM(Gross_Sales) AS Sales,
    SUM(Costs) AS Costs,
    SUM(Gross_Sales - Costs) AS Profit
FROM Fact_Orders
GROUP BY [Product_type]
ORDER BY Profit DESC
--Q12 Which category has the highest margin?
SELECT
    [Product_type],
    SUM(Gross_Sales) AS Sales,
    SUM(Costs) AS Costs,
    SUM(Gross_Sales - Costs) AS Profit,
    SUM(Gross_Sales - Costs) * 100.0 /
        NULLIF(SUM(Gross_Sales),0) AS Margin
FROM Fact_Orders
GROUP BY [Product_type]
ORDER BY Margin DESC
--Q13 Which SKUs generate the most sales?
SELECT TOP 10
    SKU,
    [Product_type],
    Gross_Sales,
    Price,
    [Number_of_products_sold]
FROM Fact_Orders
ORDER BY Gross_Sales DESC
--Q14 Which SKUs have the worst profit margin?
SELECT
    SKU,
    [Product_type],
    Gross_Sales,
    Costs,
    Gross_Sales - Costs AS Profit,
    (Gross_Sales - Costs) * 100.0 /
        NULLIF(Gross_Sales,0) AS Margin
FROM Fact_Orders
ORDER BY Margin ASC
--Q15 Which SKUs are selling a lot but generating poor margins?
SELECT
    SKU,
    [Number_of_products_sold],
    Gross_Sales,
    Costs,
    (Gross_Sales - Costs) * 100.0 /
        NULLIF(Gross_Sales,0) AS Margin
FROM Fact_Orders
WHERE [Number_of_products_sold] > 500
  AND (Gross_Sales - Costs) / NULLIF(Gross_Sales,0) < 0.20
ORDER BY Margin
--Q16 Which products have high sales but low stock?
SELECT
    SKU,
    [Product_type],
    Gross_Sales,
    [Number_of_products_sold],
    [Stock_levels]
FROM Fact_Orders
WHERE Gross_Sales >
      (SELECT AVG(Gross_Sales) FROM Fact_Orders)
AND [Stock_levels] < 20
ORDER BY Gross_Sales DESC
--Q17 Which products have low sales but excessive inventory?
SELECT
    SKU,
    [Product_type],
    Gross_Sales,
    [Number_of_products_sold],
    [Stock_levels]
FROM Fact_Orders
WHERE Gross_Sales <
      (SELECT AVG(Gross_Sales) FROM Fact_Orders)
AND [Stock_levels] > 70
ORDER BY [Stock_levels] DESC
--Q18 Which SKUs have high defect rates?
SELECT
    SKU,
    [Product_type],
    [Defect_rates],
    [Inspection_results]
FROM Fact_Orders
WHERE [Defect_rates] > 
      (SELECT AVG([Defect_rates]) FROM Fact_Orders)
ORDER BY [Defect_rates] DESC
--Q19 Which products have both high defects and low margins?
SELECT
    SKU,
    [Product_type],
    [Defect_rates],
    [Inspection_results]
FROM Fact_Orders
WHERE [Defect_rates] > 
      (SELECT AVG([Defect_rates]) FROM Fact_Orders) AND (Gross_Sales - Costs) /
      NULLIF(Gross_Sales,0) < 0.50
ORDER BY [Defect_rates] DESC
--Q20 Which SKUs are the best overall performers?
SELECT
    SKU,
    [Product_type],
    Gross_Sales,
    Costs,
    Gross_Sales - Costs AS Profit,
    [Number_of_products_sold],
    [Defect_rates],
    [Stock_levels]
FROM Fact_Orders
ORDER BY
    (Gross_Sales - Costs) DESC
    --SECTION 3 — Customer Intelligence
    --Q21 Which demographic generates the most revenue?
    SELECT
    [Customer_demographics],
    SUM(Gross_Sales) AS Sales,
    SUM(Gross_Sales) * 100.0 /
        SUM(SUM(Gross_Sales)) OVER() AS Sales_Share
FROM Fact_Orders
GROUP BY [Customer_demographics]
ORDER BY Sales DESC
--Q22 Which demographic has the highest order quantity?
SELECT
    [Customer_demographics],
    AVG([Order_quantities]) AS Avg_Order_Quantity
FROM Fact_Orders
GROUP BY [Customer_demographics]
ORDER BY Avg_Order_Quantity DESC
--Q23 Which demographic has the highest margin?
SELECT
    [Customer_demographics],
    SUM(Gross_Sales) AS Sales,
    SUM(Costs) AS Costs,
    SUM(Gross_Sales - Costs) * 100.0 /
        NULLIF(SUM(Gross_Sales),0) AS Margin
FROM Fact_Orders
GROUP BY [Customer_demographics]
ORDER BY Margin DESC
--Q24 Which demographic has the highest defect exposure?
SELECT
    [Customer_demographics],
    AVG([Defect_rates]) AS Avg_Defect_Rate,
    SUM(CASE 
            WHEN [Inspection_results] = 'Fail'
            THEN 1 ELSE 0
        END) * 100.0 / COUNT(*) AS Failure_Rate
FROM Fact_Orders
GROUP BY [Customer_demographics]
ORDER BY Failure_Rate DESC
--Q25 Which demographic buys which category?
SELECT
    [Customer_demographics],
    [Product_type],
    SUM(Gross_Sales) AS Sales
FROM Fact_Orders
GROUP BY
    [Customer_demographics],
    [Product_type]
ORDER BY
    [Customer_demographics],
    Sales DESC
    --SECTION 4 — Supplier Intelligence
    --Q26 Which supplier generates the highest sales?
    SELECT
    [Supplier_name],
    SUM(Gross_Sales) AS Sales
FROM Fact_Orders
GROUP BY [Supplier_name]
ORDER BY Sales DESC
--Q27 Which supplier has the highest profit?
SELECT
    [Supplier_name],
    SUM(Gross_Sales) AS Sales,
    SUM(Costs) AS Costs,
    SUM(Gross_Sales - Costs) AS Profit
FROM Fact_Orders
GROUP BY [Supplier_name]
ORDER BY Profit DESC
--Q28 Which supplier has the highest failure rate?
SELECT
    [Supplier_name],
    COUNT(*) AS Orders,
    SUM(CASE
        WHEN [Inspection_results] = 'Fail'
        THEN 1 ELSE 0
    END) AS Failed_Orders,
    SUM(CASE
        WHEN [Inspection_results] = 'Fail'
        THEN 1 ELSE 0
    END) * 100.0 / COUNT(*) AS Failure_Rate
FROM Fact_Orders
GROUP BY [Supplier_name]
ORDER BY Failure_Rate DESC
--Q29 Which supplier has the highest defect rate?
SELECT
    [Supplier_name],
    AVG([Defect_rates]) AS Avg_Defect_Rate
FROM Fact_Orders
GROUP BY [Supplier_name]
ORDER BY Avg_Defect_Rate DESC
--Q30 Which supplier provides the best quality?
SELECT
    [Supplier_name],
    AVG([Defect_rates]) AS Avg_Defect_Rate,
    SUM(CASE WHEN [Inspection_results]='Pass'
        THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Pass_Rate
FROM Fact_Orders
GROUP BY [Supplier_name]
ORDER BY
    Pass_Rate DESC,
    Avg_Defect_Rate ASC
    --Q31 Which supplier has the worst combination of cost and quality?
    SELECT
    [Supplier_name],
    AVG(Costs) AS Avg_Cost,
    AVG([Defect_rates]) AS Avg_Defect,
    SUM(CASE WHEN [Inspection_results]='Fail'
        THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Failure_Rate
FROM Fact_Orders
GROUP BY [Supplier_name]
ORDER BY
    Failure_Rate DESC,
    Avg_Cost DESC
    --Q32 Which supplier has the longest lead time?
    SELECT
    [Supplier_name],
    AVG([Lead_time]) AS Avg_Lead_Time
FROM Fact_Orders
GROUP BY [Supplier_name]
ORDER BY Avg_Lead_Time DESC
--Q33 Which supplier has the highest production volume?
SELECT
    [Supplier_name],
    SUM([Production_volumes]) AS Production_Volume
FROM Fact_Orders
GROUP BY [Supplier_name]
ORDER BY Production_Volume DESC
--Q34 Which suppliers are business risks?
SELECT
    [Supplier_name],
     AVG([Defect_rates]) AS Avg_Defect,
     SUM(CASE WHEN [Inspection_results]='Fail'
        THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Failure_Rate,
     AVG([Lead_time]) AS Avg_Lead_Time,
     AVG(Costs) AS Avg_Cost
FROM Fact_Orders
GROUP BY [Supplier_name]
ORDER BY
    Failure_Rate DESC,
    Avg_Defect DESC,
    Avg_Lead_Time DESC
    --SECTION 5 — Logistics
    --Q35 Which shipping carrier generates most sales?
    SELECT
    [Shipping_carriers],
    SUM(Gross_Sales) AS Sales
FROM Fact_Orders
GROUP BY [Shipping_carriers]
ORDER BY Sales DESC
--Q36 Which carrier has the lowest shipping time?
SELECT
    [Shipping_carriers],
    AVG([Shipping_times]) AS Avg_Shipping_Time
FROM Fact_Orders
GROUP BY [Shipping_carriers]
ORDER BY Avg_Shipping_Time
--Q37 Which carrier has the highest shipping cost?
SELECT
    [Shipping_carriers],
    AVG([Shipping_costs]) AS Avg_Shipping_Cost
FROM Fact_Orders
GROUP BY [Shipping_carriers]
ORDER BY Avg_Shipping_Cost DESC
--Q38 Which carrier gives the best cost-speed tradeoff?
SELECT
    [Shipping_carriers],
    AVG([Shipping_times]) AS Avg_Shipping_Time,
    AVG([Shipping_costs]) AS Avg_Shipping_Cost
FROM Fact_Orders
GROUP BY [Shipping_carriers]
ORDER BY
    Avg_Shipping_Time ASC,
    Avg_Shipping_Cost ASC
--Q39 Which transportation mode is most profitable?
SELECT
    [Transportation_modes],
    SUM(Gross_Sales) AS Sales,
    SUM(Costs) AS Costs,
    SUM(Gross_Sales - Costs) AS Profit,
    SUM(Gross_Sales - Costs) * 100.0 /
        NULLIF(SUM(Gross_Sales),0) AS Margin
FROM Fact_Orders
GROUP BY [Transportation_modes]
ORDER BY Margin DESC
--Q40 Which transportation mode is slowest?
SELECT
    [Transportation_modes],
    AVG([Shipping_times]) AS Avg_Shipping_Time
FROM Fact_Orders
GROUP BY [Transportation_modes]
ORDER BY Avg_Shipping_Time DESC
--Q41 Which route is most expensive?
SELECT
    Routes,
    AVG(Costs) AS Avg_Cost
FROM Fact_Orders
GROUP BY Routes
ORDER BY Avg_Cost DESC
--Q42 Which location has the worst logistics performance?
SELECT
    Location,
    AVG([Lead_times]) AS Avg_Lead_Time,
    AVG([Shipping_times]) AS Avg_Shipping_Time,
    AVG([Shipping_costs]) AS Avg_Shipping_Cost
FROM Fact_Orders
GROUP BY Location
ORDER BY
    Avg_Lead_Time DESC,
    Avg_Shipping_Time DESC
--SECTION 6 — Quality & Operational Risk
--Q43 What percentage of orders fail inspection?
SELECT
    SUM(CASE
        WHEN [Inspection_results] = 'Fail'
        THEN 1 ELSE 0
    END) * 100.0 / COUNT(*) AS Failure_Rate
FROM Fact_Orders
--Q44 What percentage of inspections are pending?
SELECT
    SUM(CASE
        WHEN [Inspection_results] = 'Pending'
        THEN 1 ELSE 0
    END) * 100.0 / COUNT(*) AS Pending_Rate
FROM Fact_Orders
--Q45 Which locations have the highest quality problems?
SELECT
    Location,
    AVG([Defect_rates]) AS Avg_Defect_Rate,
    SUM(CASE WHEN [Inspection_results]='Fail'
        THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Failure_Rate
FROM Fact_Orders
GROUP BY Location
ORDER BY Failure_Rate DESC
--Q46 Does high defect rate relate to low profitability?
SELECT
    CASE
        WHEN [Defect_rates] < 2 THEN 'Low Defect'
        WHEN [Defect_rates] < 3.5 THEN 'Medium Defect'
        ELSE 'High Defect'
        END AS Defect_Category,
COUNT(*) AS Orders,
AVG(Gross_Sales) AS Avg_Sales,
AVG(Gross_Sales - Costs) AS Avg_Profit
FROM Fact_Orders
GROUP BY
    CASE
        WHEN [Defect_rates] < 2 THEN 'Low Defect'
        WHEN [Defect_rates] < 3.5 THEN 'Medium Defect'
        ELSE 'High Defect'
    END
--Q47 Which SKUs are at stock-out risk?
SELECT
    SKU,
    [Product_type],
    [Stock_levels],
    [Number_of_products_sold],
    Gross_Sales
FROM Fact_Orders
WHERE [Stock_levels] < 20
ORDER BY Gross_Sales DESC
--SECTION 7 — The Really Good Questions 
--Q48 Which products are "Cash Traps"?
SELECT
    SKU,
    [Product_type],
    [Stock_levels],
    [Number_of_products_sold],
    Gross_Sales,
    Costs,
    (Gross_Sales - Costs) * 100.0 /
        NULLIF(Gross_Sales,0) AS Margin
FROM Fact_Orders
WHERE [Stock_levels] > 70
AND [Number_of_products_sold] <
    (SELECT AVG([Number_of_products_sold])
     FROM Fact_Orders)
AND (Gross_Sales - Costs) /
    NULLIF(Gross_Sales,0) < 0.50
ORDER BY [Stock_levels] DESC
--Q49 Which suppliers/products should management prioritize?
SELECT
    [Supplier_name],
    AVG([Defect_rates]) AS Defect_Rate,
    SUM(CASE
        WHEN [Inspection_results]='Fail'
        THEN 1 ELSE 0
    END) * 100.0 / COUNT(*) AS Failure_Rate,
    AVG([Lead_time]) AS Lead_Time,
    SUM(Gross_Sales) AS Sales,
    SUM(Gross_Sales - Costs) AS Profit
FROM Fact_Orders
GROUP BY [Supplier_name]
ORDER BY
    Failure_Rate DESC,
    Defect_Rate DESC
--Q50 What is the overall business action plan?
SELECT
    SUM(Gross_Sales) AS Total_Sales,
    SUM(Costs) AS Total_Cost,
    SUM(Gross_Sales - Costs) AS Gross_Profit,
    SUM(Gross_Sales - Costs) * 100.0 /
        NULLIF(SUM(Gross_Sales),0) AS Gross_Margin,
    SUM([Number_of_products_sold]) AS Units_Sold,
    AVG([Defect_rates]) AS Avg_Defect_Rate,
    SUM(CASE
        WHEN [Inspection_results]='Fail'
        THEN 1 ELSE 0
    END) * 100.0 / COUNT(*) AS Failure_Rate,
    SUM(CASE
        WHEN [Stock_levels] < 20
        THEN 1 ELSE 0
    END) * 100.0 / COUNT(*) AS Low_Stock_Rate,
    AVG([Shipping_times]) AS Avg_Shipping_Time,
    AVG([Lead_times]) AS Avg_Lead_Time
FROM Fact_Orders