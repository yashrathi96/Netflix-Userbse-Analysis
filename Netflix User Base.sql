create database netflix;

use netflix;

select * from netflixuserbase;

set sql_safe_updates =0;

alter table  netflixuserbase
add column new_join_date date;

alter table  netflixuserbase
add column new_last_payment_date date;

update netflixuserbase
set new_join_date = STR_TO_DATE(Join_Date, '%d/%m/%Y');

update netflixuserbase 
set new_last_payment_date = STR_TO_DATE(Last_Payment_Date, '%d/%m/%Y');


/*What is the overall monthly revenue trend?*/

select StartMonth, (CurrentMonth - PreviousMonth)/PreviousMonth as MonthlyTrend from
(select month(new_join_date) as StartMonth,
sum(Monthly_Revenue) as CurrentMonth,lag (sum(Monthly_Revenue))over(order by month(new_join_date)) as PreviousMonth
from netflixuserbase
group by 1
order by 1) MonthlyRevenue;



/*Which subscription types generate the most revenue?*/

select sum(Monthly_Revenue) as TotalRevenue, Subscription_Type
from netflixuserbase
Group by Subscription_Type
order by TotalRevenue desc;



/*How long do customers typically stay subscribed in relevance to Subscription Type(average plan duration)?*/

select avg(timestampdiff(month, new_join_date, new_last_payment_date)) as Averageplanduration, Subscription_Type
from netflixuserbase
group by 2;



/*Which countries have the highest revenue and user base?*/

Select sum(Monthly_Revenue) as CountryRevenue, count(User_ID) as NumberofUsers, Country
from netflixuserbase
group by Country;



/*What is the demographic breakdown of customers (age and gender)?*/

select Gender, count(User_ID) as NumberofUsers
from netflixuserbase
group by Gender;

select max(Age), Min(Age)
from netflixuserbase;

select 
  case
   when Age between 26 and 35 then '26-35'
   when Age between 36 and 45 then '36-45'
   when Age between 46 and 55 then '46-55'
 END as AgeRange,
 count(*) as count
 from netflixuserbase
 group by AgeRange
 order by AgeRange;
 
 
 
/*Which devices are most popular among customers?*/

select Device, count(User_ID) as NumberofUsers
from Netflixuserbase 
group by Device
order by Device desc;



/*Are there any patterns between the join date and monthly revenue?*/

select month(new_join_date), Monthly_Revenue, count( distinct User_ID)
from netflixuserbase
group by 1,2
order by 3 desc;



/*What is the distribution of monthly revenue based on plan duration?*/

select distinct Plan_Duration, sum(monthly_revenue)
from netflixuserbase
group by 1;



/*How does the monthly revenue vary by customer age group?*/

select 
  case
   when Age between 26 and 35 then '26-35'
   when Age between 36 and 45 then '36-45'
   when Age between 46 and 55 then '46-55'
 END as AgeRange,
 sum(Monthly_Revenue)
 from netflixuserbase
 group by AgeRange
 order by sum(Monthly_Revenue) desc;
 
 
 
/*What is the average time between last payments?*/

select
  User_ID, AVG(timestampdiff (DAY, new_join_date, new_last_Payment_Date)) as AvgTimeBetweenPayments
from 
( select user_ID, new_Last_Payment_Date, 
lag(new_last_Payment_Date) over (Partition by user_ID order by new_Last_Payment_Date) as previous_payment_date
from netflixuserbase ) 
as Subquery
where PrevPaymentDate is not null
group by User_ID;

/*How does the revenue vary seasonally or by specific months?*/

select
month(new_last_Payment_date) as Payment_Month, avg (Monthly_Revenue) as Avg_Revenue
from netflixuserbase
group by Payment_Month
order by  Payment_Month;

select timestampdiff(month,new_Join_Date,new_Last_Payment_date) as Payment_Month, avg (Monthly_Revenue) as Avg_Revenue
from netflixuserbase 
group by Payment_Month
Order by Payment_Month desc;



/*What is the lifetime value (LTV) of customers for each subscription type?*/

select Subscription_Type,
    avg(Monthly_Revenue) as AverageMonthlyRevenue,
    avg(Monthly_Revenue) * avg(datediff(new_last_payment_date, new_join_date)) as LifetimeValue
from netflixuserbase
group by Subscription_Type
order by Subscription_Type desc;



/*What is the ratio of active to inactive customers over time?*/

select
    date_format(new_last_payment_date, '%Y-%m') as month,
    sum(CASE WHEN new_last_payment_date >= curdate() - INTERVAL 1 MONTH THEN 1 ELSE 0 END) as ActiveCustomers,
    sum(case when new_last_payment_date < curdate() - INTERVAL 1 MONTH THEN 1 ELSE 0 END) as InactiveCustomers,
    ifnull(sum(case when new_Last_Payment_Date >= curdate() - INTERVAL 1 MONTH THEN 1 ELSE 0 END) /
           sum(case when new_Last_Payment_Date < curdate() - INTERVAL 1 MONTH THEN 1 ELSE 0 END), 0) as ActiveToInactiveRatio
from netflixuserbase
group by month
order by month;



/* Which country has the highest revenue according to the number of users*/

select Country,count(User_ID) AS UserCount, sum(Monthly_Revenue) AS TotalRevenue,
    sum(Monthly_Revenue) / count(User_ID) AS AverageRevenuePerUser
from netflixuserbase
group by Country
order by AverageRevenuePerUser desc;