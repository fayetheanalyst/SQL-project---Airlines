show tables from airlines;
select * from airlines.airports;
select * from carriers;
select * from flights;

-- check the dataset datatypes, delete unused columns
SHOW INDEXES FROM airlines.flights;

SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, DATA_TYPE 
	from INFORMATION_SCHEMA.COLUMNS 
    where (table_name = 'flights') OR (table_name = 'carriers') OR (table_name = 'airports');
    
-- delete unused columns, check for null values, convert date
SELECT str_to_date(CONCAT(year, "-", month, "-", day), '%Y-%m-%d') AS the_date, origin, dest, flight, carrier FROM airlines.flights LIMIT 0,10;
-- SELECT DATA_TYPE from airlines.flights.COLUMNS;
-- SELECT SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS null_year FROM airlines.flights;

-- percentage of delayed, diverted, cancelled flights
-- total number of flights
-- get the names of top airlines
-- number of unique places airline goes
SELECT a.*,
COUNT(DISTINCT b.carrier) AS total_Flights     -- , (DISTINCT b.origin)
FROM airlines.airports a
INNER JOIN airlines.flights b ON a.faa = b.origin  
group by faa;



select * from flights.airlines group by faa;



SELECT a.carrier,  -- year, c.name,
COUNT(a.carrier) AS totalFlights,
COUNT(DISTINCT origin) as unique_origin,
COUNT(DISTINCT dest) as unique_dest,
FORMAT((SUM(IF(cancelled=1, 0, IF(diverted =1, 0 ,IF(arr_delay <= 10, 1, 0)))) / COUNT(a.carrier))*100,4)	AS pct_onTimeFlight,
FORMAT((SUM(IF(arr_delay > 10, 1, 0))/ COUNT(a.carrier))*100,4) AS pct_DelayedFlights,
FORMAT(sum(IF(arr_delay > 10, arr_delay, 0))/sum(IF(arr_delay > 10, 1, 0)),2) AS avg_MinDelayed,
FORMAT((SUM(cancelled=1)/COUNT(a.carrier))*100,4) AS pct_CancelledFlights,
FORMAT((SUM(diverted = 1)/COUNT(a.carrier))*100,4) AS pct_DivertedFlights,
FORMAT((SUM(cancelled=1)/COUNT(a.carrier))+(SUM(diverted = 1)/COUNT(a.carrier))*100,4) AS pct_diverted_cancelled
FROM airlines.flights a
-- LEFT JOIN airlines.carriers c ON a.carrier = c.carrier
GROUP BY a.carrier -- , year
ORDER BY totalFlights desc; -- year,



SELECT b.carrier, 
a.faa AS origin, a.name, a.lat, a.lon, a.city, a.country,
COUNT(b.origin) AS total_flights,
FORMAT(SUM(IF(b.cancelled=1, 0, IF(b.diverted =1, 0 ,IF(b.arr_delay <= 10, 1, 0)))) / COUNT(b.origin)*100,2) AS pct_onTimeFlight
FROM airlines.airports a
RIGHT JOIN airlines.flights b ON a.faa = b.origin
where b.carrier = 'WN' or b.carrier = 'DL' or b.carrier = 'HA' or b.carrier = 'AS' or b.carrier = 'YV'
GROUP by carrier, origin;
-- wn, dl most flights > 2.4M
-- HA, AS, DL,  pct on time flights >80%
-- least diverted + cancelled HA, YV, <15% 
-- include WN, DL, HA, AS, YV 

-- 


-- use sytax case, stored procedure, delimeter, altertable







SELECT *, CONCAT(year, "-", month, "-", day) AS the_date FROM airlines.flights LIMIT 0,10;
-- SELECT CONCAT(year, "-", month, "-", day) AS the_date, origin, dest, flight, carrier FROM airlines.flights LIMIT 0,10;


/*Question 2 */
SELECT origin, count(*) AS num_flights
FROM airlines.flights b
JOIN (SELECT * FROM airlines.airports WHERE name LIKE '%Chicago%' OR name LIKE '%Chicago' OR name LIKE 'Chicago%') a ON b.origin = a.faa
WHERE year = 2013
GROUP BY origin;

SELECT b.tailnum , count(dest) AS num_flight, a.model 
FROM airlines.flights b
LEFT JOIN airlines.planes a ON b.tailnum = a.tailnum
WHERE carrier = 'WN' AND cancelled = 0 AND b.year = 2015
GROUP BY b.tailnum 
HAVING num_flight >= 2200 
ORDER BY num_flight desc;

SELECT origin, count(dest) as time_visited,  c.name AS airport_name
FROM airlines.flights b
JOIN (SELECT * FROM airlines.planes WHERE tailnum = 'N750AT') a ON b.tailnum = a.tailnum
JOIN airlines.airports c ON b.origin = c.faa
WHERE b.year = 2015 AND cancelled = 0
GROUP BY origin
ORDER BY time_visited desc;


SET @@local.net_read_timeout=360;

select carrier,
count(arr_delay)as count,
sum(arr_delay)as sum,
sum(IF(arr_delay > 10, arr_delay, 0)) AS sum_arr,
sum(IF(arr_delay > 10, 1, 0)) AS sum_one,
FORMAT(sum(IF(arr_delay > 10, arr_delay, 0))/sum(IF(arr_delay > 10, 1, 0)),2) AS sum_sum,
sum(IF(arr_delay > 10, arr_delay, 0)) AS sum_arr,
count(IF(arr_delay > 10, 1, 0)) AS count_one,
FORMAT(sum(IF(arr_delay > 10, arr_delay, 0))/count(IF(arr_delay > 10, 1, 0)),2) AS sum_count,
FORMAT(avg(IF(arr_delay > 10, arr_delay, 0)),2) AS avg_func
from airlines.flights GROUP BY carrier;

select carrier, count(arr_delay) as count_arr,sum(arr_delay) as sum_arr,
count(carrier) as count_carrier
from airlines.flights where arr_delay <0
group by carrier;

select carrier, count(arr_delay) as count_arr, sum(arr_delay) as sum_arr,
count(carrier) as count_carrier
from airlines.flights 
group by carrier;