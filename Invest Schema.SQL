USE invest;

SELECT z.ticker, z.date, (z.p1-z.p0)/z.p0 as returns_d
FROM
(
SELECT ticker, date, value as p1, LAG(value, 1) OVER(
                                                        PARTITION BY ticker
                                                        ORDER BY date
                                                        ) as p0
FROM pricing_daily_new
WHERE price_type = 'Adjusted' AND 
        ticker IN ('TSLA', 'GLD', 'AGG', 'SPY') AND
        date > '2021-09-01') z;

-- You can find the full project below
USE invest;
-- Finding Paul Bistre's Client ID
SELECT*
FROM customer_details
WHERE full_name='Paul Bistre';
-- Finding Paul Bistre's account ids
SELECT*
FROM account_dim
WHERE client_id='148';
-- Paul Bistre has three account IDs (28, 2801, 2802)
-- Market Value of Paul Bistre's holdings
SELECT *, value*quantity AS market_value
FROM holdings_current
WHERE account_id IN ('28', '2801', '2802');
-- Diversification of Paul Bistre's portfolio
SELECT *
FROM security_masterlist
WHERE ticker IN (SELECT DISTINCT ticker
FROM holdings_current
WHERE account_id IN ('28', '2801', '2802'));
-- Using joins to view important information about Paul Bistre
SELECT
 c.customer_id,
 c.full_name,
 a.account_id,
 s.ticker,
 s.security_name,
 s.minor_asset_class,
 s.major_asset_class,
 h.quantity,
 p.value AS price_value,
 h.quantity * p.value AS total_value
FROM
 customer_details c
 INNER JOIN account_dim a ON c.customer_id = a.client_id
 INNER JOIN holdings_current h ON a.account_id = h.account_id
 INNER JOIN security_masterlist s ON h.ticker = s.ticker
 INNER JOIN pricing_daily_new p ON h.ticker = p.ticker AND h.date = p.date AND
p.price_type = 'Adjusted'
WHERE
 c.customer_id = 148;
-- View of Paul Bistre's Daily Returns for all his 67 tickers (last two years)
CREATE VIEW Nimrod_Paul_Bistre AS
SELECT ticker, date, p1,p0, (p1-p0)/p0 AS Daily_Returns
FROM
(SELECT p.ticker, p.date, p.value as p1, LAG (p.value,1) OVER (
 PARTITION BY p.ticker
 ORDER by p.date
) as p0
FROM customer_details c
INNER JOIN account_dim a
ON c.customer_id=a.client_id
INNER JOIN holdings_current h
ON a.account_id=h.account_id
INNER JOIN security_masterlist s
ON h.ticker=s.ticker
INNER JOIN pricing_daily_new p
ON s.ticker=p.ticker
WHERE p.price_type='Adjusted' AND
p.date>'2020-09-01' AND
 c.customer_id=148
) z;
-- Paul Bistre's last 12-month returns for all his 67 tickers
SELECT ticker, SUM(Daily_Returns) AS 12month_returns
FROM Nimrod_Paul_Bistre
WHERE date>'2021-09-01'
GROUP BY ticker;
-- Paul Bistre's last 18-month returns for all his 67 tickers
SELECT ticker, SUM(Daily_Returns) AS 18month_returns
FROM Nimrod_Paul_Bistre
WHERE date>'2021-03-01'
GROUP BY ticker;
-- Paul Bistre's last 24-month returns for all his 67 tickers
SELECT ticker, SUM(Daily_Returns) AS 24month_returns
FROM Nimrod_Paul_Bistre
WHERE date>'2020-09-01'
GROUP BY ticker; 
-- Portfolio returns last 12 months
SELECT SUM(Daily_Returns) /COUNT(DISTINCT ticker) AS 12month_portfolio_ret
FROM Nimrod_Paul_Bistre
WHERE date>'2021-09-01';
-- Portfolio returns last 18 months
SELECT SUM(Daily_Returns) /COUNT(DISTINCT ticker) AS 18month_portfolio_ret
FROM Nimrod_Paul_Bistre
WHERE date>'2021-03-01';
-- Portfolio returns last 24 months
SELECT SUM(Daily_Returns) /COUNT(DISTINCT ticker) AS 24month_portfolio_ret
FROM Nimrod_Paul_Bistre
WHERE date>'2020-09-01';
-- 12months sigma (risk) for each of the securities
SELECT ticker, std(Daily_Returns)*SQRT(250) AS sigma
FROM Nimrod_Paul_Bistre
WHERE date>'2021-09-01'
GROUP BY ticker;
-- average daily return for each of the securities
SELECT ticker, AVG(Daily_Returns) AS avg_daily_returns
FROM Nimrod_Paul_Bistre
WHERE date>'2021-09-01'
GROUP BY ticker;
-- adding a new investment to the portfolio, what would it be
-- and how much risk (sigma) would it add to your client?
-- creating a new view with returns of all assets
CREATE VIEW Nimrod_NewInvestment AS
SELECT ticker, date, p1,p0, (p1-p0)/p0 AS Daily_Returns
FROM
(SELECT p.ticker, p.date, p.value as p1, LAG (p.value,1) OVER (
 PARTITION BY p.ticker
 ORDER by p.date
) as p0
FROM customer_details c
INNER JOIN account_dim a
ON c.customer_id=a.client_id
INNER JOIN holdings_current h
ON a.account_id=h.account_id
INNER JOIN security_masterlist s
ON h.ticker=s.ticker
INNER JOIN pricing_daily_new p
ON s.ticker=p.ticker
WHERE p.price_type='Adjusted' AND
p.date>'2021-09-01'
) z;
-- all the last 12 months risk-adjusted returns for all tickers
SELECT ticker, AVG(Daily_Returns)/std(Daily_Returns)
FROM Nimrod_NewInvestment
WHERE date>'2021-09-01'
GROUP BY ticker;
-- 12months sigma (risk) for the new portfolio (including the 10 new tickers for
new investment)
SELECT AVG(Daily_Returns)/std(Daily_Returns) /COUNT(DISTINCT ticker) AS
12month_newportfolio_ret
FROM Nimrod_NewInvestment
WHERE date>'2021-09-01' AND ticker IN ('PFG', 'ETN', 'WTMF', 'K', 'SHY', 'GPN',
'LBAY', 'V', 'IAUM', 'KMLM', 'GLD', 'CHTR', 'UNG', 'MARB', 'IAU', 'RINF', 'MJ', 'ACN',
'BNDX', 'ARB', 'SHV', 'EIX', 'VCSH', 'GM', 'VTEB', 'CNBS',
'HDG', 'FTLS', 'CCI', 'SLV', 'TIP', 'VCIT', 'BAR', 'MSVX', 'FLSP', 'BTAL', 'AAAU',
'SVIX', 'SGOL', 'FLT', 'CNC', 'NVO', 'PFIX', 'EOPS', 'KO', 'VMBS', 'AXP', 'PANW',
'SBAC', 'TOKE',
'TLT', 'BIL', 'MUB', 'LQD', 'IGSB', 'COF', 'VGSH', 'SCHP', 'KRBN', 'GIGB', 'TJX',
'UVIX', 'GOVT', 'UPAR', 'RLY', 'ROST', 'GE' 'COP', 'CEG', 'MCK', 'VLO', 'CR', 'GVA',
'SLB', 'CVX', 'CI', 'CAH');
-- Finding the security with the highest risk adjusted returns last two years
SELECT ticker, AVG(Daily_Returns)/std(Daily_Returns) AS
12M_risk_adjusted_return
FROM Nimrod_Paul_Bistre
WHERE date>'2020-09-01'
GROUP BY ticker;
-- Finding the security with the highest risk adjusted returns all time
SELECT ticker, AVG(Daily_Returns)/std(Daily_Returns) AS
12M_risk_adjusted_return
FROM Nimrod_Paul_Bistre
GROUP BY ticker; 
