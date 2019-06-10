--                                                                                                             % Tablas

CREATE TABLE intermedia(
        Quarter TEXT NOT NULL,
        Month TEXT NOT NULL,
        Week TEXT NOT NULL,
        Product_Type TEXT NOT NULL,
        Territory TEXT NOT NULL,
        Sales_Channel TEXT NOT NULL,
        Customer_Type TEXT NOT NULL,
        Revenue FLOAT NOT NULL,
        Cost FLOAT NOT NULL,
        CONSTRAINT non_neg_cost CHECK ( Cost >= 0),
        PRIMARY KEY(Quarter, Month, Week, Product_Type, Territory, Sales_Channel, Customer_Type)
);

CREATE TABLE definitiva(
        id SERIAL,
        Sales_Date DATE,
        Product_Type TEXT NOT NULL,
        Territory TEXT NOT NULL,
        Sales_Channel TEXT NOT NULL,
        Customer_Type TEXT NOT NULL,
        Revenue FLOAT NOT NULL,
        Cost FLOAT NOT NULL,
        PRIMARY KEY(id)
);

CREATE OR REPLACE FUNCTION get_month(month CHAR) RETURNS CHAR AS $$
BEGIN
        RETURN(
                SELECT CASE
                        WHEN month = 'Jan' THEN '01'
                        WHEN month = 'Feb' THEN '02'
                        WHEN month = 'Mar' THEN '03'
                        WHEN month = 'Apr' THEN '04'
                        WHEN month = 'May' THEN '05'
                        WHEN month = 'Jun' THEN '06'
                        WHEN month = 'Jul' THEN '07'
                        WHEN month = 'Aug' THEN '08'
                        WHEN month = 'Sep' THEN '09'
                        WHEN month = 'Oct' THEN '10'
                        WHEN month = 'Nov' THEN '11'
                        WHEN month = 'Dec' THEN '12'
                END
        );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION string_to_DATE(year CHAR, month CHAR) RETURNS DATE AS $$
BEGIN
        RETURN to_date(year||month||'01');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_into_definitiva() RETURNS Trigger AS $$
BEGIN
        --%insertar en tabla
        INSERT INTO definitiva VALUES(DEFAULT, string_to_DATE(substr(new.quarter,4,5),get_month(substr(new.month,4,7))) , new.Product_Type, new.Territory, new.Sales_Channel, new.Customer_Type, new.Revenue, new.Cost);        
        RETURN NEW;
END;
$$ LANGUAGE plpgsql;        

--                                                                                                              % Trigger

CREATE TRIGGER InsertaDefinitiva
BEFORE INSERT ON intermedia
FOR EACH ROW
EXECUTE PROCEDURE insert_into_definitiva();


--                                                                                                              % Margen movil

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

--                                                                                                              % Reporte

CREATE OR REPLACE FUNCTION table_titles() RETURNS VOID AS $$
BEGIN
PERFORM DBMS_OUTPUT.DISABLE();
PERFORM DBMS_OUTPUT.ENABLE();
PERFORM DBMS_OUTPUT.SERVEROUTPUT ('t');
PERFORM DBMS_OUTPUT.PUT_LINE ('         HISTORIC SALES REPORT');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obtainDataFromYear(in myYear integer) RETURNS VOID AS $$
DECLARE
dataByYear CURSOR FOR
                select a2.category, a2.revenue, a2.cost, a2.margin from
                        ((SELECT a1.myYear as year, a1.category, a1.revenue, a1.cost, (a1.revenue - a1.cost) as margin
                        FROM (select extract(year from sales_date) as myYear, CONCAT('SALES CHANNEL: ', sales_channel) as category, sum(revenue) as revenue, sum(cost) as cost FROM definitiva group by myYear, sales_channel order by sales_channel) as a1
                        ORDER BY year, category)
                UNION
                        ((SELECT a1.myYear as year, a1.category, a1.revenue, a1.cost, (a1.revenue - a1.cost) as margin
                        FROM (select extract(year from sales_date) as myYear, CONCAT('CUSTOMER TYPE: ', customer_type) as category, sum(revenue) as revenue, sum(cost) as cost FROM definitiva group by myYear, customer_type order by customer_type) as a1
                        ORDER BY year, category))) as a2
                where a2.year = myYear;
fila record;
total_revenue bigint := 0;
total_cost bigint := 0;
total_margin bigint := 0;
BEGIN
        PERFORM DBMS_OUTPUT.PUT_LINE ('-----------------------------------------');
        -- CHR(9) es porque en ASCII, el tab o '\t' es el 9
        PERFORM DBMS_OUTPUT.PUT_LINE ('YEAR' || '    ' || 'CATEGORY' || '                                                     ' || 'REVENUE' || '        ' || 'COST' || '          ' || 'MARGIN');
OPEN dataByYear;
LOOP
        FETCH dataByYear INTO fila;
        EXIT WHEN NOT FOUND;
        total_revenue := total_revenue + fila.revenue;
        total_cost := total_cost + fila.cost;
        total_margin := total_margin + fila.margin;
        -- Para imprimir parejo
        IF fila.category LIKE '%Branded%' THEN fila.category := fila.category || '           ';
        END IF;
        IF fila.category LIKE '%Retail%' THEN fila.category := fila.category || '                          ';
        END IF;
        IF fila.category LIKE '%SALES%Direct%' THEN fila.category := fila.category || '                         ';
        END IF;
        IF fila.category LIKE '%SALES%Internet%' THEN fila.category := fila.category || '                      ';
        END IF;
        IF fila.category LIKE '%CUSTOMER%Internet%' THEN fila.category := fila.category || '            ';
        END IF;
        PERFORM DBMS_OUTPUT.PUT_LINE(cast(myYear as varchar) || '    ' || fila.category || '        ' || cast(fila.revenue as integer) || '    ' || '    ' || cast(fila.cost as integer) || '    ' || cast(fila.margin as integer));
END LOOP;
        PERFORM DBMS_OUTPUT.PUT_LINE('Total: ' || '                                                                      ' || total_revenue || '    ' || total_cost || '    ' || total_margin);
CLOSE dataByYear;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ReporteVentas(in n integer) RETURNS VOID AS $$
DECLARE
-- Voy a iterar a través de los años.
        list_of_years RECORD;
BEGIN
-- Si no encuentra nada tiene que devolver sin hacer nada.
IF NOT EXISTS (SELECT DISTINCT EXTRACT(year from sales_date) as currentYear FROM definitiva ORDER BY currentYear LIMIT n) THEN
        RETURN;
ELSE
        PERFORM table_titles();
END IF;
FOR list_of_years IN
        -- No me deja guardar esto en una variable entonces tengo que hacer nuevamente la query.
        SELECT DISTINCT EXTRACT(year from sales_date) as currentYear FROM definitiva ORDER BY currentYear LIMIT n
    LOOP
                PERFORM obtainDataFromYear(cast(list_of_years.currentYear as integer));
    END LOOP;
END;
$$ LANGUAGE plpgsql;