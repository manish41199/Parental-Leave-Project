--Parental Leave Portolio Project

Select *
From master..parental_leave$


--Spliting Industry Column into Two Columns
Alter Table master..parental_leave$
Add GeneralIndustry nvarchar(255)


Alter Table master..parental_leave$
Add IndustrySpecific nvarchar(255)

Update master..parental_leave$
set GeneralIndustry = PARSENAME(REPLACE(Industry,':', '.') , 2)


Update master..parental_leave$
set IndustrySpecific = PARSENAME(REPLACE(Industry,':', '.') , 1)




--Swapping Values if GeneralIndustry is NULL using SELF JOIN


select a.industry, a.GeneralIndustry, a.IndustrySpecific, b.GeneralIndustry, b.IndustrySpecific, 
ISNULL(a.GeneralIndustry, b.IndustrySpecific)
from master..parental_leave$ a, master..parental_leave$ b
where a.Company = b.Company
--and a.GeneralIndustry is null

Update A
set GeneralIndustry = ISNULL(a.GeneralIndustry, b.IndustrySpecific)
from master..parental_leave$ a, master..parental_leave$ b
where a.Company = b.Company


Update B
set IndustrySpecific = null
from master..parental_leave$ a, master..parental_leave$ b
where a.GeneralIndustry = b.IndustrySpecific



--Setting NULL Values on Leave Columns to Zero

Update master..parental_leave$
set [Unpaid Maternity Leave] = ISNULL([Unpaid Maternity Leave], 0)


Update master..parental_leave$
set [Paid Paternity Leave] = ISNULL([Paid Paternity Leave], 0)

Update master..parental_leave$
set [Unpaid Paternity Leave] = ISNULL([Unpaid Paternity Leave], 0)


--Adding new Columns for visualisation and comparison

Alter Table master..parental_leave$
Add TotalPaidLeave int

Update master..parental_leave$
set TotalPaidLeave = [Paid Paternity Leave] + [Paid Maternity Leave]


Alter Table master..parental_leave$
Add TotalUnPaidLeave int

Update master..parental_leave$
set TotalUnPaidLeave = [Unpaid Maternity Leave] + [Unpaid Paternity Leave]


Alter Table master..parental_leave$
Add TotalLeave int

Update master..parental_leave$
set TotalLeave = TotalPaidLeave + TotalUnpaidLeave


--***Top 10 Industries in general with Highest Total Leave  (Paid + Unpaid) ********************

With Industry_CTE as
(select *, SUM(TotalLeave) over (Partition by GeneralIndustry) as MaxLeavesbyIndustry
from parental_leave$
where GeneralIndustry not like 'N/A')
select top (10)
GeneralIndustry, MaxLeavesbyIndustry
from Industry_CTE
Group by GeneralIndustry, MaxLeavesbyIndustry
order by MaxLeavesbyIndustry desc



--*Top 5 Companies with Highest Total Leave  (Paid + Unpaid)********************

select top (5) Company, TotalPaidLeave, TotalUnPaidLeave, TotalLeave
from parental_leave$
where GeneralIndustry not like 'N/A'
order by TotalLeave desc, TotalPaidLeave desc, [Paid Maternity Leave] desc, [Paid Paternity Leave] desc, company


--*Top 5 Industries in general with Highest Total Maternity Leave (Paid + Unpaid)******************

Alter Table master..parental_leave$
Add TotalMaternityLeave int

Update master..parental_leave$
set TotalMaternityLeave = [Unpaid Maternity Leave] + [Paid Maternity Leave]


With MaternityLeave_CTE as
(select *, SUM(TotalMaternityLeave) over (Partition by GeneralIndustry) as MaxMaternityLeavesbyIndustry
from parental_leave$
where GeneralIndustry not like 'N/A')
select top (5)
GeneralIndustry, MaxMaternityLeavesbyIndustry
from MaternityLeave_CTE
Group by GeneralIndustry, MaxMaternityLeavesbyIndustry
order by MaxMaternityLeavesbyIndustry desc


--*Top 5 Industries in general with Highest Total Paternity Leave (Paid + Unpaid)******************

Alter Table master..parental_leave$
Add TotalPaternityLeave int

Update master..parental_leave$
set TotalPaternityLeave = [Unpaid Paternity Leave] + [Paid Paternity Leave]


With PaternityLeave_CTE as
(select *, SUM(TotalPaternityLeave) over (Partition by GeneralIndustry) as MaxPaternityLeavesbyIndustry
from parental_leave$
where GeneralIndustry not like 'N/A')
select top (5)
GeneralIndustry, MaxPaternityLeavesbyIndustry
from PaternityLeave_CTE
Group by GeneralIndustry, MaxPaternityLeavesbyIndustry
order by MaxPaternityLeavesbyIndustry desc



--**Top 5 Companies with Highest Total Maternity Leave (Paid + Unpaid)***************

select top (5) Company, [Paid Maternity Leave], [Unpaid Maternity Leave], TotalMaternityLeave
from parental_leave$
where GeneralIndustry not like 'N/A'
order by TotalMaternityLeave desc, [Paid Maternity Leave] desc, [Unpaid Maternity Leave] desc, company



--**Top 5 Companies with Highest Total Paternity Leave (Paid + Unpaid)***************

select top (5) Company, [Paid Paternity Leave], [Unpaid Paternity Leave], TotalPaternityLeave
from parental_leave$
where GeneralIndustry not like 'N/A'
order by TotalPaternityLeave desc, [Paid Paternity Leave] desc, [Unpaid Paternity Leave] desc, company

