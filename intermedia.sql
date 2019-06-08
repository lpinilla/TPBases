--% Tabla intermedia

drop table intermedia;
drop table definitiva;

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

SELECT * FROM intermedia;

--% SELECT quarter, substr(quarter,4,5) FROM intermedia;

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

select to_date('2011'||'01'||'03');

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

SELECT * FROM intermedia;
SELECT * FROM definitiva;

CREATE TRIGGER InsertaDefinitiva
BEFORE INSERT ON intermedia
FOR EACH ROW
EXECUTE PROCEDURE insert_into_definitiva();

  
     






        













