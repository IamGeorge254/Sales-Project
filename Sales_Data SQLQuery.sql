/*
 Sales_Data Data Explaratory

*/

--# Checking if our data has been imported sucessfully

select *
from SalesData..[sales_data_sample]


--# Checking unique values present in our columns

select distinct(STATUS)
from SalesData..[sales_data_sample]

select distinct(PRODUCTLINE)
from SalesData..[sales_data_sample]

select distinct(DEALSIZE)
from SalesData..[sales_data_sample]

select distinct(COUNTRY)
from SalesData..[sales_data_sample]

select distinct(TERRITORY)
from SalesData..[sales_data_sample]


--# Checking to see if they operated for the entire year

select distinct [YEAR_ID], [MONTH_ID]
from SalesData..[sales_data_sample]
where [YEAR_ID] = 2005
order by 2 

select distinct [YEAR_ID], [MONTH_ID]
from SalesData..[sales_data_sample]
where [YEAR_ID] = 2004
order by 2 

select distinct [YEAR_ID], [MONTH_ID]
from SalesData..[sales_data_sample]
where [YEAR_ID] = 2003
order by 2 

--# Cheking the number of sales for every month for each year

select [YEAR_ID], [MONTH_ID], max(SALES) as MaxSales
from SalesData..[sales_data_sample]
group by [YEAR_ID], [MONTH_ID]
order by 1,2


--# Checking the year with the most sales

select [YEAR_ID], sum(SALES) as TotalSales
from SalesData..[sales_data_sample]
group by [YEAR_ID]
order by 2 DESC


--# Checking the production line with the most sales

select [PRODUCTLINE], sum(SALES) as TotalSales
from SalesData..[sales_data_sample]
group by [PRODUCTLINE]
order by 2 DESC


--# Checking Countries with the highest Sales for each year

select [COUNTRY], [YEAR_ID], sum(SALES) as TotalSales
from SalesData..[sales_data_sample]
where [YEAR_ID] = 2005
group by [COUNTRY], [YEAR_ID]
order by 3 DESC

select [COUNTRY], [YEAR_ID], sum(SALES) as TotalSales
from SalesData..[sales_data_sample]
where [YEAR_ID] = 2004
group by [COUNTRY], [YEAR_ID]
order by 3 DESC

select [COUNTRY], [YEAR_ID], sum(SALES) as TotalSales
from SalesData..[sales_data_sample]
where [YEAR_ID] = 2003
group by [COUNTRY], [YEAR_ID]
order by 3 DESC


--# Best Month for sales per year

select distinct [MONTH_ID], count(ORDERNUMBER) as frequency, sum(SALES) as Total_Sales
from SalesData..[sales_data_sample]
where [YEAR_ID] = 2004 -- In here you change the year to see the rest
group by [MONTH_ID]
order by 3 DESC


--# Since November since to be the best month, which product do they sell in November

select [MONTH_ID], [PRODUCTLINE], count(ORDERNUMBER) as frequency, sum(SALES) as Total_Sales
from SalesData..[sales_data_sample]
where [YEAR_ID] = 2004 and [MONTH_ID] = 11
group by [MONTH_ID], [PRODUCTLINE]
order by 4 DESC


--# Checking who is the best customer using CTE

DROP TABLE if exists #rfm
;with rfm as
(
	select [CUSTOMERNAME], sum(SALES) as TotalSales, count(ORDERNUMBER) as frequency , max(ORDERDATE) as last_Orderdate, (
	select max(ORDERDATE) from SalesData..[sales_data_sample])  as Max_Orderdate,
	DATEDIFF(DAY, max(ORDERDATE), (select max(ORDERDATE) from SalesData..[sales_data_sample])) as NumofDays
	from SalesData..[sales_data_sample]
	group by [CUSTOMERNAME]
	--order by 2 DESC
),
rfm_calc as
(
	select *,
	NTILE(4) OVER (order by NumofDays) as rfm_recency,
	NTILE(4) OVER (order by frequency) as rfm_frequency,
	NTILE(4) OVER (order by TotalSales) as rfm_monetary_value
	from rfm
)
select *,  (rfm_recency + rfm_frequency + rfm_monetary_value) as rfm_cell,
cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetary_value as varchar) rfm_cellstring
into #rfm
from rfm_calc

select [CUSTOMERNAME], rfm_recency, rfm_frequency, rfm_monetary_value, rfm_cell,
case
when rfm_cell > 8 then 'High_Value_Customers'
when rfm_cell < 8 then 'Low_Value_Customers'
when rfm_cell = 8 then 'Loyal_Customers'
end rfm_segment
from #rfm