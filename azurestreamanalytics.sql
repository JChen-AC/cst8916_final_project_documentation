WITH ProcessedData AS (
    SELECT 
        Replace(REPLACE(location,' ',''),'''','') as location,
        AVG(iceThickness) as avgIceThickness,
        MAX(iceThickness) as maxThickness,
        MIN(iceThickness) as minThickness,
        AVG(surfaceTemperature) as avgSurfaceTemperature,
        MIN(surfaceTemperature) as minSurface,
        MAX(surfaceTemperature) as maxSurface,
        MAX(snowAccumulation) as snowAccumulation,
        AVG(externalTemperature) as avgExternalTemperature,
        COUNT(*) AS readings,
        System.Timestamp() as dateTimeStamp
    FROM [cst8916-final-project-rideau-monitoring]
    GROUP BY location, TumblingWindow(minute, 5)
),

LogicResult AS (
    SELECT
        *,        
        CASE
            WHEN avgIceThickness >= 30 AND avgSurfaceTemperature <= -2 THEN 'Safe'
            WHEN avgIceThickness >= 25 AND avgSurfaceTemperature <= 0 THEN 'Cautious'
            ELSE 'Unsafe'
        END AS status 
    FROM ProcessedData
),


FORMATDATE AS (
    SELECT 
        *,
        CONCAT(
            CAST(DATEPART(year, dateTimeStamp) AS NVARCHAR(MAX)),
            RIGHT('0' + CAST(DATEPART(month, dateTimeStamp) AS NVARCHAR(MAX)), 2),
            RIGHT('0' + CAST(DATEPART(day, dateTimeStamp) AS NVARCHAR(MAX)), 2),
            '-',
            RIGHT('0' + CAST(DATEPART(hour, dateTimeStamp) AS NVARCHAR(MAX)), 2),
            RIGHT('0' + CAST(DATEPART(minute, dateTimeStamp) AS NVARCHAR(MAX)), 2),
            RIGHT('0' + CAST(DATEPART(second, dateTimeStamp) AS NVARCHAR(MAX)), 2)
        ) AS formattedDate
    FROM LogicResult
)

SELECT 
    location,
    avgIceThickness,
    maxThickness,
    minThickness,
    avgSurfaceTemperature,
    minSurface,
    maxSurface,
    snowAccumulation,
    avgExternalTemperature,
    readings,
    dateTimeStamp,
    status,
    CONCAT(location, '-',formattedDate) AS id
INTO CosmoAggregate
FROM FORMATDATE

SELECT
    location,
    avgIceThickness,
    maxThickness,
    minThickness,
    avgSurfaceTemperature,
    minSurface,
    maxSurface,
    snowAccumulation,
    avgExternalTemperature,
    readings,
    dateTimeStamp,
    status
INTO [historical-data]
FROM FORMATDATE;