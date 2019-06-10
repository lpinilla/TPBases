CREATE OR REPLACE FUNCTION MargenMovil(fecha DATE,n INTEGER) RETURNS DECIMAL AS $$
BEGIN
        IF n = 0 THEN
                RAISE EXCEPTION 'La cantidad de meses anteriores debe ser mayor a 0';
        END IF;
        RETURN (SELECT AVG(revenue-cost) AS margenmovil
          FROM (
                SELECT revenue,cost
                FROM definitiva        
                WHERE  sales_date <= fecha AND fecha - (n || 'month')::INTERVAL  <=sales_date
                ) AS subtable);
END;
$$ LANGUAGE plpgsql;


select MargenMovil(to_date('2012-11-01','YYYY-MM-DD'),3);
