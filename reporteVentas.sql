-- Reporte de Ventas Histórico

SELECT * FROM definitiva;

/* Función para probar si el año es el correcto.
create or replace function testPrintF(var varchar(100)) returns void as $$
BEGIN
PERFORM DBMS_OUTPUT.DISABLE();
PERFORM DBMS_OUTPUT.ENABLE();
PERFORM DBMS_OUTPUT.SERVEROUTPUT('t');
PERFORM DBMS_OUTPUT.PUT_LINE(var);
END;
$$ LANGUAGE plpgsql;
*/

CREATE OR REPLACE FUNCTION table_titles() RETURNS VOID AS $$
BEGIN
PERFORM DBMS_OUTPUT.DISABLE();
PERFORM DBMS_OUTPUT.ENABLE();
PERFORM DBMS_OUTPUT.SERVEROUTPUT ('t');
PERFORM DBMS_OUTPUT.PUT_LINE ('         HISTORIC SALES REPORT');
END;
$$ LANGUAGE plpgsql;


-- Devuelve el título del reporte.
select table_titles();




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
        PERFORM DBMS_OUTPUT.PUT_LINE ('YEAR' || CHR(9) || CHR(9) || 'CATEGORY' || CHR(9) || CHR(9) || CHR(9) || 'REVENUE' || CHR(9) || CHR(9) || 'COST' || CHR(9) || CHR(9) || 'MARGIN');
OPEN dataByYear;
LOOP
        FETCH dataByYear INTO fila;
        EXIT WHEN NOT FOUND;
        total_revenue := total_revenue + fila.revenue;
        total_cost := total_cost + fila.cost;
        total_margin := total_margin + fila.margin;
        PERFORM DBMS_OUTPUT.PUT_LINE(cast(myYear as varchar) || CHR(9) || CHR(9) || fila.category || CHR(9) || CHR(9) || CHR(9) || fila.revenue || CHR(9) || CHR(9) || fila.cost || CHR(9) || CHR(9) || fila.margin);
END LOOP;
        PERFORM DBMS_OUTPUT.PUT_LINE(CHR(9) || 'Total: ' || CHR(9) || CHR(9) || CHR(9) || CHR(9) || CHR(9) || total_revenue || CHR(9) || total_cost || CHR(9) || total_margin);
CLOSE dataByYear;
END;
$$ LANGUAGE plpgsql;


-- Test de la función para el año 2011. Debería dar todos los datos del año 2011.
select obtainDataFromYear(2011);




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


-- test de la función final
-- con 0 no devuelve nada
-- con 1 devuelve solo el primer año (ASC) que es el 2011
-- con 2 devuelve los dos primeros años (ASC) que son el 2011 y el 2012, en ese orden
-- con 3+ devuelve lo mismo que con 2 porque hay solo 2 años en los datos
select ReporteVentas(3);


