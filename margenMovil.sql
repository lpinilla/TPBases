CREATE OR REPLACE FUNCTION MargenMovil(fecha DATE,n integer) RETURNS decimal
as 
$$
BEGIN
        IF n = 0 THEN
                RAISE EXCEPTION 'La cantidad de meses anteriores debe ser mayor a 0';
        END IF;
        return (select avg(revenue-cost) as margenmovil
          from (
                select revenue,cost
                from definitiva        
                where  sales_date <= fecha and  fecha - (n || 'month')::INTERVAL  <=sales_date
          ) as subtable);
END;

$$ LANGUAGE plpgsql


select MargenMovil(to_date('2012-11-01','YYYY-MM-DD'),0);