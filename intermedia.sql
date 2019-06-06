--% Tabla intermedia

drop table intermedia;

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
        Sales_Date DATE,
        Product_Type TEXT NOT NULL,
        Territory TEXT NOT NULL,
        Sales_Channel TEXT NOT NULL,
        Customer_Type TEXT NOT NULL,
        Revenue FLOAT NOT NULL,
        Cost FLOAT NOT NULL,
        PRIMARY KEY(Quarter, Month, Week, Product_Type, Territory, Sales_Channel, Customer_Type)
);

SELECT * FROM intermedia;

CREATE OR REPLACE FUNCTION insert_into_definitiva() RETURNS Trigger AS $$
BEGIN
        --%insertar en tabla
        --%INSERT INTO definitiva VALUES(new., new.Product_Type, new.Territory, new.Sales_Channel, new.Customer_Type, new.Revenue, new.Cost);        
        
END;
$$ LANGUAGE plpgsql;        

CREATE TRIGGER insert_data
BEFORE INSERT ON intermedia
FOR EACH ROW
EXECUTE PROCEDURE insert_into_definitiva();