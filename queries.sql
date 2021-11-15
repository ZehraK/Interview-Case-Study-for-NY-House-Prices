----- POSTGRESQL CASE STUDY -----
----- Remove characters (" - " from SALE PRICE) ----
UPDATE nyc_house_prices
SET "SALE PRICE"  = CASE
WHEN "SALE PRICE" ~E'^\\d+$' THEN "SALE PRICE"::bigint ELSE 0 END;
----- Convert SALE PRICE to INTEGER ----
alter table nyc_house_prices alter column "SALE PRICE" TYPE bigint
USING "SALE PRICE"::bigint;

----- TASK 1 -----

--create column sale_price_zscore
ALTER TABLE nyc_house_prices
ADD COLUMN sale_price_zscore FLOAT;
--calculate z-scores
UPDATE nyc_house_prices
SET sale_price_zscore = Scores.ZScore
FROM (
    SELECT "id", "SALE PRICE", ("SALE PRICE" - (AVG("SALE PRICE") OVER()))
                         /NULLIF((stddev("SALE PRICE")  OVER()),0) AS ZScore
    FROM nyc_house_prices
) Scores
WHERE Scores.id = nyc_house_prices.id;

----- TASK 2 -----

--create column sale_price_zscore_neighborhood
ALTER TABLE nyc_house_prices
ADD COLUMN sale_price_zscore_neighborhood FLOAT;

--calculate z-scores across segments
UPDATE nyc_house_prices
SET sale_price_zscore_neighborhood = Segment.ZSEGMENT
FROM (
    SELECT "id","neighborhood","BUILDING CLASS AT PRESENT", "SALE PRICE", ("SALE PRICE" - (AVG("SALE PRICE") OVER(PARTITION BY "neighborhood", "BUILDING CLASS AT PRESENT")))
                         /NULLIF((stddev("SALE PRICE")  OVER(PARTITION BY "neighborhood", "BUILDING CLASS AT PRESENT")),0) AS ZSEGMENT
    FROM nyc_house_prices
) Segment
WHERE Segment.id = nyc_house_prices.id;

----- TASK 3 -----

--- square_ft_per_unit

ALTER TABLE nyc_house_prices
ADD COLUMN square_ft_per_unit FLOAT;

UPDATE nyc_house_prices
SET square_ft_per_unit = spu.SquarePerUnit
FROM (
    SELECT "id", "GROSS SQUARE FEET"/NULLIF("TOTAL UNITS",0)  AS PricePerSquare
    FROM nyc_house_prices
) spu
WHERE spu.id = nyc_house_prices.id;

--- price_per_unit

ALTER TABLE nyc_house_prices
ADD COLUMN price_per_square FLOAT;

UPDATE nyc_house_prices
SET price_per_square = ppu.PricePerSquare
FROM (
    SELECT id, "SALE PRICE"/NULLIF("GROSS SQUARE FEET",0)  AS PricePerSquare
    FROM nyc_house_prices
) ppu
WHERE ppu.id = nyc_house_prices.id;