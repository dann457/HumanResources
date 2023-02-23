SELECT * FROM HumanResources..Employee;

--Number of employees in each department
SELECT  d.Department, COUNT(e.DeptId) AS "Number of employees" 
FROM HumanResources..Employee AS e JOIN HumanResources..Department AS d
	ON e.DeptID = d.DeptID
GROUP BY d.Department;

--Overall diversity profile of the organization
SELECT r.RaceDesc AS Race, COUNT(e.RaceId) AS "Number of employees", ROUND((COUNT(e.RaceId)*1.0)/(SELECT COUNT(*) FROM Employee), 3) AS "Percentage"
FROM HumanResources..Employee e JOIN HumanResources..Race r
	ON e.RaceId = r.RaceId
GROUP BY r.RaceDesc
ORDER BY COUNT(e.RaceId) DESC;

--Employee's Marital status
SELECT m.MaritalDesc, COUNT(e.EmpID) AS "Number of Employees"
FROM HumanResources..Employee e JOIN HumanResources..Marital_Status m
	ON e.MaritalStatusID = m.MaritalStatusID
GROUP BY m.MaritalDesc;

--Employee's Performance (Relationship between race and performance)
SELECT r.RaceDesc, p.PerformanceScore, COUNT(EmpID) AS "Number of Employees"
FROM HumanResources..Employee e JOIN HumanResources..Performance p 
	ON e.PerfScoreID = p.PerfScoreID
	JOIN HumanResources..Race r ON e.RaceId = r.RaceId
GROUP BY r.RaceDesc, p.PerformanceScore;

--Employee's Performance (Relationship between marital status and performance)
SELECT e.MarriedID,
	p.PerformanceScore, COUNT(EmpID) AS "Number of Employees"
FROM HumanResources..Employee e JOIN HumanResources..Performance p 
	ON e.PerfScoreID = p.PerfScoreID
GROUP BY MarriedID, p.PerformanceScore;

--Employee's Performance (Relationship between gender and performance)
SELECT g.Sex, p.PerformanceScore, COUNT(EmpID) AS "Number of Employees"
FROM HumanResources..Employee e JOIN HumanResources..Performance p 
	ON e.PerfScoreID = p.PerfScoreID
	JOIN HumanResources..Gender g ON e.GenderID = g.GenderID
GROUP BY g.Sex, p.PerformanceScore;

--Number of employees got hired each year
SELECT YEAR(DateofHire) AS "Year", COUNT(*) "Number of Employees got hired"
FROM HumanResources..Employee
GROUP BY YEAR(DateofHire)
ORDER BY YEAR(DateofHire);

--Year with the most employees got hired
SELECT TOP 1 YEAR(DateofHire) AS "Year", COUNT(*) "Number of Employees got hired"
FROM HumanResources..Employee
GROUP BY YEAR(DateofHire)
ORDER BY COUNT(*) DESC;

-- Top 3 recruiting sources that most of the employees got hired from
SELECT TOP 3 r.RecruitmentSource, COUNT(e.EmpID) AS "Number of employees"
FROM HumanResources..Employee e JOIN HumanResources..RecruitmentSource r
ON e.RecruitmentId = r.RecruitmentId
GROUP BY r.RecruitmentSource
ORDER BY COUNT(e.EmpID) DESC;

-- The best recruiting sources if the organization want to ensure a diverse organization
SELECT r.RecruitmentSource, COUNT(e.EmpID) AS "Number of employees", COUNT(DISTINCT e.RaceId) AS "Number of different ethnics"
FROM HumanResources..Employee e JOIN HumanResources..RecruitmentSource r
ON e.RecruitmentId = r.RecruitmentId
GROUP BY r.RecruitmentSource
ORDER BY COUNT(e.EmpID) DESC, COUNT(DISTINCT e.RaceId) DESC;

-- The ratio of employees that terminated
SELECT ROUND(CAST(Terminated AS FLOAT)/ (SELECT COUNT(*) FROM HumanResources..Employee), 3) AS Ratio
FROM
	(SELECT COUNT(*) AS "Terminated"
	FROM HumanResources..Employee
	WHERE Termd = 1) AS T;

--The number and ratio of male and female who terminated
SELECT Sex, COUNT(EmpID) AS "Count", ROUND(CAST(COUNT(EmpID) AS FLOAT)/ (SELECT COUNT(*) FROM HumanResources..Employee WHERE Termd = 1), 3) AS "Ratio"
FROM HumanResources..Employee e JOIN HumanResources..Gender g
	ON e.GenderID = g.GenderID
WHERE Termd = 1
GROUP BY Sex;

--Terminated Reason
SELECT TermReason, COUNT(*) AS "Count"
FROM HumanResources..Employee
WHERE DateofTermination IS NOT NULL
GROUP BY TermReason
ORDER BY COUNT(*) DESC;

--Reason that female employees terminated
SELECT TermReason, COUNT(*) AS "Count"
FROM HumanResources..Employee
WHERE Termd = 1 AND GenderID = 0
GROUP BY TermReason
ORDER BY COUNT(*) DESC;

--Reason that male employees terminated
SELECT TermReason, COUNT(*) AS "Count"
FROM HumanResources..Employee
WHERE Termd = 1 AND GenderID = 1
GROUP BY TermReason
ORDER BY COUNT(*) DESC;

--The satisfaction and number of absences of employees who terminated
SELECT Employee_Name, PerfScoreID, EmpSatisfaction, Absences, TermReason
FROM HumanResources..Employee
WHERE DateofTermination IS NOT NULL
ORDER BY Absences DESC, EmpSatisfaction DESC;

-- Years that the terminated employees worked for the organization
SELECT Employee_Name, YEAR(DateofTermination) - YEAR(DateofHire) AS "Years"
FROM HumanResources..Employee
WHERE DateofTermination IS NOT NULL
ORDER BY YEAR(DateofTermination) - YEAR(DateofHire) DESC;

--The employees that have been working for the organization more than 10 years
SELECT Employee_Name, YEAR(GETDATE()) - YEAR(DateofHire) AS "Years"
FROM HumanResources..Employee
WHERE YEAR(GETDATE()) - YEAR(DateofHire) >= 10 AND DateofTermination IS NULL;

--Employees having maximum and minimum salary working in different departments
WITH m1 AS
(SELECT MaxS.Department, Employee_Name, Salary 
FROM HumanResources..Employee e JOIN 
(SELECT e.DeptID, Department, MAX(Salary) AS MaxSalary
FROM HumanResources..Employee e JOIN HumanResources..Department d ON e.DeptID = d.DeptID
GROUP BY e.DeptID, Department) MaxS 
ON e.DeptID = MaxS.DeptID
WHERE Salary = MaxSalary),

m2 AS
(SELECT MinS.Department, Employee_Name, Salary 
FROM HumanResources..Employee e JOIN 
(SELECT e.DeptID, Department, MIN(Salary) AS MinSalary
FROM HumanResources..Employee e JOIN HumanResources..Department d ON e.DeptID = d.DeptID
GROUP BY e.DeptID, Department) MinS 
ON e.DeptID = MinS.DeptID
WHERE Salary = MinSalary)

SELECT DISTINCT m1.Department, m1.Employee_Name, m1.Salary AS MaxSalary, m2.Employee_Name, m2.Salary AS MinSalary
FROM m1 JOIN m2 ON m1.Department = m2.Department;

-- The average Salary of each department
SELECT d.Department, AVG(Salary) AS AvgSalary
FROM HumanResources..Employee e JOIN HumanResources..Department d
	ON e.DeptID = d.DeptID
GROUP BY d.Department;

