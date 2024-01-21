#1 What are the most popular neighborhood for Airbnb rentals in New york city ? How do prices and availabiltiy vary by neighborhood?
SELECT neighbourhood, room_type, average_price, average_availability FROM RankedListings WHERE room_type_rank = 1; 
use airbnb;

SELECT
    neighbourhood,
    room_type,
    COUNT(*) AS room_type_count,
    AVG(price) AS price_distribution,
    AVG(availability_365) AS availability_average
FROM
    airbnb
WHERE
    room_type IN ('Private room', 'Entire home/apt', 'Shared room')
   GROUP BY
    neighbourhood, room_type
ORDER BY
    room_type_count DESC
LIMIT 1;

WITH RankedCities AS (
    SELECT
        neighbourhood,
        room_type,
        COUNT(*) AS room_type_count,
        AVG(price) AS price_distribution,
        AVG(availability_365) AS availability_average
    FROM
        airbnb
    WHERE
        room_type IN ('Private room', 'Entire home/apt', 'Shared room')
    GROUP BY
        neighbourhood, room_type
)
SELECT
    neighbourhood,
    room_type,
    MAX(room_type_count) AS room_type_count,
    MAX(price_distribution) AS price_distribution,
    MAX(availability_average) AS availability_average
FROM
    RankedCities
GROUP BY
    neighbourhood, room_type desc limit 1;

#2 How has the Airbnb market in New York City changed over time? Have there been any significant trends in terms of the number of listings, prices, or occupancy rates?

#Top city acc to listing count
SELECT neighbourhood, AVG(calculated_host_listings_count) AS calculated_host_listings_count, AVG(price) AS price_distribution, 
AVG(availability_365) AS availability_average FROM airbnb GROUP BY neighbourhood ORDER BY calculated_host_listings_count DESC LIMIT 1;

#Top city acc to price
SELECT neighbourhood, COUNT(*) AS listing_count, AVG(price) AS price_distribution, AVG(availability_365) AS availability_average
FROM  airbnb GROUP BY neighbourhood ORDER BY AVG(price) DESC LIMIT 1;

#Top city acc to availability
SELECT neighbourhood, COUNT(*) AS listing_count, AVG(price) AS price_distribution, AVG(availability_365) AS availability_average
FROM airbnb GROUP BY neighbourhood ORDER BY AVG(availability_365) DESC LIMIT 1;

#3 Are there any patterns or trends in terms of the types of properties that are being rented out on Airbnb in New York City?
# Are certain types of properties more popular or more expensive than others?


WITH RankedCities AS ( SELECT room_type, neighbourhood, COUNT(*) AS room_type_count, AVG(price) AS price_distribution,
        AVG(availability_365) AS availability_average, ROW_NUMBER() OVER (PARTITION BY room_type ORDER BY COUNT(*) DESC) AS room_type_rank
    FROM airbnb WHERE room_type IN ('Private room', 'Entire home/apt', 'Shared room') GROUP BY room_type, neighbourhood ) SELECT room_type AS 'Airbnb Rentals',
    neighbourhood AS 'Top City', room_type_count AS 'Room Count',ROUND(price_distribution) AS 'Prices',ROUND(availability_average) AS 'Availability' FROM
    RankedCities WHERE room_type_rank = 1;

#4 Are there any factors that seem to be correalated with the prices of Airbnb rentals in New York City?

SELECT room_type AS 'Airbnb Rental', 
    IFNULL(SUM(price * minimum_nights) / SQRT(SUM(price * price) * SUM(minimum_nights * minimum_nights)),0) AS 'Co-Rel'
FROM airbnb GROUP BY room_type;

#5. The Best Area in New York City for a host to buy property at a good price rate and in an area with high traffic ?
SELECT
    'Price' AS 'Metric',
    AVG(CASE WHEN neighbourhood_group = 'Brooklyn' THEN price END) AS 'Brooklyn',
    AVG(CASE WHEN neighbourhood_group = 'Bronx' THEN price END) AS 'Bronx',
    AVG(CASE WHEN neighbourhood_group = 'Manhattan' THEN price END) AS 'Manhattan',
    AVG(CASE WHEN neighbourhood_group = 'Queens' THEN price END) AS 'Queens',
    AVG(CASE WHEN neighbourhood_group = 'Staten Island' THEN price END) AS 'Staten Island'
FROM
    airbnb
UNION ALL
SELECT
    'Minimum Nights' AS 'Metric',
    AVG(CASE WHEN neighbourhood_group = 'Brooklyn' THEN minimum_nights END) AS 'Brooklyn',
    AVG(CASE WHEN neighbourhood_group = 'Bronx' THEN minimum_nights END) AS 'Bronx',
    AVG(CASE WHEN neighbourhood_group = 'Manhattan' THEN minimum_nights END) AS 'Manhattan',
    AVG(CASE WHEN neighbourhood_group = 'Queens' THEN minimum_nights END) AS 'Queens',
    AVG(CASE WHEN neighbourhood_group = 'Staten Island' THEN minimum_nights END) AS 'Staten Island'
FROM
    airbnb;

#6 How do the lengths of stay for Airbnb rentals in New York City vary by neighborhood ? Do certain neighborhood tend to attract longer or shorter days?
SELECT neighbourhood, sum(minimum_nights) AS average_minimum_nights FROM airbnb
GROUP BY neighbourhood ORDER BY average_minimum_nights DESC limit 3;

#7 How do the ratings of Airbnb rentals in New  York  City compare to their prices? Are higher price rated rentals  more likely to have higher ratings ?
SELECT room_type AS 'Room Rentals', ROUND(AVG(price)) AS 'Price', Round(avg(number_of_reviews)) AS 'Rating'
FROM airbnb GROUP BY room_type ORDER BY Price DESC LIMIT 3;

#8 Find the total numbers of Reviews and Maximum Reviews by Each Neighborhood Group.
SELECT neighbourhood_group as 'Neighbourhood Group', round(sum(number_of_reviews)) As 'Number of Reviews',round(max(number_of_reviews)) As 'Maximum Number of Reviews'
From airbnb Group By neighbourhood_group ;

#9. Find Most reviewed room type in Neighborhood groups per month.

SELECT
    neighbourhood_group,
    SUM(CASE WHEN room_type = 'Private room' THEN 1 ELSE 0 END) AS 'Private Room',
    SUM(CASE WHEN room_type = 'Entire home/apt' THEN 1 ELSE 0 END) AS 'Entire home/apt',
    SUM(CASE WHEN room_type = 'Shared room' THEN 1 ELSE 0 END) AS 'Shared Room'
FROM
    airbnb
WHERE
    last_review IS NOT NULL
GROUP BY
    neighbourhood_group;

#10 Find Best location listing/property location for travelers.
SELECT
    neighbourhood_group,
    neighbourhood,
    sum(number_of_reviews) AS total_listings,
    ROUND(AVG(reviews_per_month)) AS average_rating,
    ROUND(avg(number_of_reviews) + AVG(reviews_per_month)) AS total_score
FROM
    airbnb
GROUP BY
    neighbourhood_group, neighbourhood
ORDER BY
    total_score DESC
LIMIT 1;

#OR

SELECT
    'number_of_reviews' AS 'Metric',
    Round(sum(CASE WHEN neighbourhood_group = 'Brooklyn' THEN minimum_nights END)) AS 'Brooklyn',
    Round(sum(CASE WHEN neighbourhood_group = 'Bronx' THEN minimum_nights END)) AS 'Bronx',
    Round(sum(CASE WHEN neighbourhood_group = 'Manhattan' THEN minimum_nights END)) AS 'Manhattan',
    Round(sum(CASE WHEN neighbourhood_group = 'Queens' THEN minimum_nights END)) AS 'Queens',
    Round(sum(CASE WHEN neighbourhood_group = 'Staten Island' THEN minimum_nights END)) AS 'Staten Island'
FROM
    airbnb;

#11. Find also best location listing/property location for Hosts. 
   
    SELECT
    neighbourhood_group,
    neighbourhood,
    SUM(calculated_host_listings_count) AS total_listings,
    ROUND(AVG(reviews_per_month)) AS average_rating,
    ROUND(SUM(calculated_host_listings_count) + AVG(reviews_per_month)) AS total_score
FROM
    airbnb
GROUP BY
    neighbourhood_group, neighbourhood
ORDER BY
    total_score DESC
LIMIT 5;

#12 Find Price variations in NYC Neighborhood groups
SELECT
    'Price Variations' AS 'Metric',
    Round(avg(CASE WHEN neighbourhood_group = 'Brooklyn' THEN price END)) AS 'Brooklyn',
    Round(avg(CASE WHEN neighbourhood_group = 'Bronx' THEN Price END)) AS 'Bronx',
    Round(avg(CASE WHEN neighbourhood_group = 'Manhattan' THEN price END)) AS 'Manhattan',
    Round(avg(CASE WHEN neighbourhood_group = 'Queens' THEN price END)) AS 'Queens',
    Round(avg(CASE WHEN neighbourhood_group = 'Staten Island' THEN price END)) AS 'Staten Island'
FROM
    airbnb;
