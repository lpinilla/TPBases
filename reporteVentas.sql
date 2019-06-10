-- Reporte de Ventas Histórico

SELECT * FROM intermedia;

--% SELECT quarter, substr(quarter,4,5) FROM intermedia;

CREATE OR REPLACE FUNCTION ReporteVentas(integer n) RETURNS VOID AS $$
BEGIN
        RETURN(
                SELECT CASE
                        WHEN substr(month) = 'Jan' THEN '01'
                        WHEN substr(month) = 'Feb' THEN '02'
                END
        );
END;
$$ LANGUAGE plpgsql;

select to_date('2011'||'01'||'03');

CREATE OR REPLACE FUNCTION esteEs_string_to_DATE(year CHAR, month CHAR) RETURNS DATE AS $$
BEGIN
        RETURN to_date(year||month||'01');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION yEsteEs_insert_into_definitiva() RETURNS Trigger AS $$
BEGIN
        --%insertar en tabla
        INSERT INTO definitiva VALUES(DEFAULT, string_to_DATE(substr(new.quarter,4,5),get_month(substr(new.month,4,7))) , new.Product_Type, new.Territory, new.Sales_Channel, new.Customer_Type, new.Revenue, new.Cost);        
        RETURN NEW;
END;
$$ LANGUAGE plpgsql;        

SELECT * FROM intermedia;
SELECT * FROM definitiva;

CREATE TRIGGER Otro_InsertaDefinitiva
BEFORE INSERT ON intermedia
FOR EACH ROW
EXECUTE PROCEDURE insert_into_definitiva();

create or replace function testHelloWorld() returns void as $$
BEGIN
PERFORM DBMS_OUTPUT.DISABLE();
PERFORM DBMS_OUTPUT.ENABLE();
PERFORM DBMS_OUTPUT.SERVEROUTPUT ('t');
PERFORM DBMS_OUTPUT.PUT_LINE ('Hello World!');
PERFORM DBMS_OUTPUT.PUT_LINE ('Hello World!');
PERFORM DBMS_OUTPUT.PUT_LINE ('Hello World!');
PERFORM DBMS_OUTPUT.PUT_LINE ('Hello World!');
PERFORM DBMS_OUTPUT.PUT_LINE ('Hello World!');
END;
$$ LANGUAGE plpgsql;

select testHelloWorld();
