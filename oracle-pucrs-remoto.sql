-- Etapa 1 - Criação das tabelas sem otimização
create table AIR_AIRLINES as select * from arruda.AIR_AIRLINES;
create table AIR_AIRPLANES as select * from arruda.AIR_AIRPLANES;
create table AIR_AIRPLANE_TYPES as select * from arruda.AIR_AIRPLANE_TYPES; 
create table AIR_AIRPORTS as select * from arruda.AIR_AIRPORTS; 
create table AIR_AIRPORTS_GEO as select * from arruda.AIR_AIRPORTS_GEO; 
create table AIR_BOOKINGS as select * from arruda.AIR_BOOKINGS; 
create table AIR_FLIGHTS as select * from arruda.AIR_FLIGHTS;
create table AIR_FLIGHTS_SCHEDULES as select * from arruda.AIR_FLIGHTS_SCHEDULES; 
create table AIR_PASSENGERS as select * from arruda.AIR_PASSENGERS;
create table AIR_PASSENGERS_DETAILS as select * from arruda.AIR_PASSENGERS_DETAILS;

-- Etapa 2 - Elabore as seguintes consultas SQL:
-- 1. listar o nome completo (primeiro nome + ultimo nome), a idade e a cidade 
-- de todos os passageiros do sexo feminino (sex='w') com mais de 40 anos, 
-- residentes no pais 'BRAZIL'. [resposta sugerida = 141 linhas]
SELECT
    pass.firstname || ' ' || pass.lastname AS nome_completo,
    TRUNC(MONTHS_BETWEEN(SYSDATE,passd.birthdate)/12) AS idade,   
    passd.city AS cidade
FROM
    air_passengers pass 
    inner join air_passengers_details passd ON pass.passenger_id = passd.passenger_id
WHERE
    passd.sex = 'w'
    AND passd.country = 'BRAZIL'
    AND passd.birthdate <= ADD_MONTHS(SYSDATE, -40 * 12);
    
-- 2. Listar o nome da companhia aerea, o identificador da aeronave, 
-- o nome do tipo de aeronave e o numero de todos os voos operados por essa companhia aerea 
-- (independentemente de a aeronave ser de sua propriedade) que saem E chegam em 
-- aeroportos localizados no pais 'BRAZIL'. [resposta sugerida = 8 linhas]  
SELECT
    cia.airline_name,
    plane.airplane_id,
    typie.name,
    fli.flight_id
FROM
    air_airlines cia
    INNER JOIN air_flights fli ON cia.airline_id = fli.airline_id
    INNER JOIN air_airports from_airport ON fli.from_airport_id = from_airport.airport_id
    INNER JOIN air_airports to_airport ON fli.to_airport_id = to_airport.airport_id
    INNER JOIN air_airports_geo from_geo ON from_airport.airport_id = from_geo.airport_id
    INNER JOIN air_airports_geo to_geo ON to_airport.airport_id = to_geo.airport_id
    INNER JOIN air_airplanes plane ON fli.airplane_id = plane.airplane_id
    INNER JOIN air_airplane_types typie ON plane.airplane_type_id = typie.airplane_type_id
WHERE
    from_geo.country = 'BRAZIL' 
    AND to_geo.country = 'BRAZIL';

-- 3. Listar o número do voo, o nome do aeroporto de saída e o nome do aeroporto de destino
-- , o nome completo e o assento de cada passageiro, 
-- para todos os voos que partem no dia do seu aniversário 
-- (do seu mesmo, caro aluno, e não o do passageiro) 
-- neste ano (caso a consulta não retorne nenhuma linha, 
-- faça para o dia subsequente até encontrar uma data que retorne alguma linha). 
-- [resposta sugerida = 106 linhas para o dia 25/03/2024]
SELECT
    fli.flight_id,
    from_airport.name AS origem,
    to_airport.name AS destino,
    pass.firstname || ' ' || pass.lastname AS nome_completo,
    books.seat
FROM
    air_flights fli
    INNER JOIN air_bookings books ON fli.flight_id = books.flight_id
    INNER JOIN air_airports from_airport ON fli.from_airport_id = from_airport.airport_id
    INNER JOIN air_airports to_airport ON fli.to_airport_id = to_airport.airport_id
    INNER JOIN air_passengers pass ON books.passenger_id = pass.passenger_id
WHERE
    TO_CHAR(fli.departure, 'DD/MM/YY') = '24/09/23';

-- 4. Listar o nome da companhia aérea bem como a data e a hora de saída de todos os voos 
-- que chegam para a cidade de 'NEW YORK' que partem às terças, quartas ou quintas-feiras, no mês do seu aniversário  
-- (caso a consulta não retorne nenhuma linha, faça para o mês subsequente até encontrar um mês que retorne alguma linha). 
-- [resposta sugerida = 1 linha para o mês de março de 2024]
SELECT
    cia.airline_name,
    fli.departure
FROM
    air_flights fli
    INNER JOIN air_airlines cia ON fli.airline_id = cia.airline_id
    INNER JOIN air_flights_schedules sched ON fli.flightno = sched.flightno
    INNER JOIN air_airports to_airport ON fli.to_airport_id = to_airport.airport_id
    INNER JOIN air_airports_geo to_geo ON to_airport.airport_id = to_geo.airport_id
WHERE
    to_geo.city = 'NEW YORK'
    AND TO_CHAR(fli.departure, 'MM') = '03'
    AND (sched.TUESDAY = 1 OR sched.WEDNESDAY = 1 OR sched.THURSDAY = 1);


--ATIVIDADE 4

-- Tabela AIR_AIRLINES
ALTER TABLE AIR_AIRLINES
    ADD CONSTRAINT airlines_pk PRIMARY KEY (airline_id)
    ADD CONSTRAINT airlines_base_fk FOREIGN KEY (base_airport_id) REFERENCES AIR_AIRPORTS (airport_id)
    ADD CONSTRAINT airlines_iata_ak UNIQUE (iata);

-- Tabela AIR_AIRPLANE_TYPES
ALTER TABLE AIR_AIRPLANE_TYPES
    ADD CONSTRAINT airplane_types_pk PRIMARY KEY (airplane_type_id);

-- Tabela AIR_AIRPLANES
ALTER TABLE AIR_AIRPLANES
    ADD CONSTRAINT airplanes_pk PRIMARY KEY (airplane_id)
    ADD CONSTRAINT airplanes_airlines_fk FOREIGN KEY (airline_id) REFERENCES AIR_AIRLINES (airline_id)
    ADD CONSTRAINT airplanes_types_fk FOREIGN KEY (airplane_type_id) REFERENCES AIR_AIRPLANE_TYPES (airplane_type_id);

-- Tabela AIR_PASSENGERS
ALTER TABLE AIR_PASSENGERS
    ADD CONSTRAINT passengers_pk PRIMARY KEY (passenger_id)
    ADD CONSTRAINT passengers_passport_ak UNIQUE (passportno);

-- Tabela AIR_PASSENGERS_DETAILS
ALTER TABLE AIR_PASSENGERS_DETAILS
    ADD CONSTRAINT passengers_details_pk PRIMARY KEY (passenger_id)
    ADD CONSTRAINT passengers_fk FOREIGN KEY (passenger_id) REFERENCES AIR_PASSANGERS (passenger_id);

-- Tabela AIR_AIRPORTS
ALTER TABLE AIR_AIRPORTS
    ADD CONSTRAINT airports_pk PRIMARY KEY (airport_id)
    ADD CONSTRAINT airports_icao_ak UNIQUE (icao);

-- Tabela AIR_AIRPORTS_GEO
ALTER TABLE AIR_AIRPORTS_GEO
    ADD CONSTRAINT airports_geo_pk PRIMARY KEY (airport_id)
    ADD CONSTRAINT airports_geo_fk FOREIGN KEY (airport_id) REFERENCES  AIR_AIRPORTS (airport_id);

-- Tabela AIR_FLIGHTS_SCHEDULES
ALTER TABLE AIR_FLIGHTS_SCHEDULES
    ADD CONSTRAINT flights_schedules_pk PRIMARY KEY (flightno)
    ADD CONSTRAINT flight_schedules_airlines_fk FOREIGN KEY (airline_id) REFERENCES AIR_AIRLINES (airline_id)
    ADD CONSTRAINT from_airports_fk FOREIGN KEY (from_airport_id) REFERENCES AIR_AIRPORTS (airport_id)
    ADD CONSTRAINT to_airport_geo_fk FOREIGN KEY (to_airport_id) REFERENCES AIR_AIRPORTS (airport_id);

-- Tabela AIR_FLIGHTS
ALTER TABLE AIR_FLIGHTS
    ADD CONSTRAINT flights_pk PRIMARY KEY (flight_id)
    ADD CONSTRAINT flight_schedules_fk FOREIGN KEY (flightno) REFERENCES AIR_FLIGHTS_SCHEDULES (flightno)
    ADD CONSTRAINT flight_airlines_fk FOREIGN KEY (airline_id) REFERENCES AIR_AIRLINES (airline_id)
    ADD CONSTRAINT flights_from_airports_fk FOREIGN KEY (from_airport_id) REFERENCES AIR_AIRPORTS (airport_id)
    ADD CONSTRAINT flights_to_airport_fk FOREIGN KEY (to_airport_id) REFERENCES AIR_AIRPORTS (airport_id)
    ADD CONSTRAINT flights_airplanes_fk FOREIGN KEY (airplane_id) REFERENCES AIR_AIRPLANES (airplane_id);

-- Tabela AIR_BOOKINGS
ALTER TABLE AIR_BOOKINGS
    ADD CONSTRAINT bookings_pk PRIMARY KEY (booking_id)
    ADD CONSTRAINT booking_passengers_fk FOREIGN KEY (passenger_id) REFERENCES AIR_PASSENGERS (passenger_id)
    ADD CONSTRAINT booking_flights_fk FOREIGN KEY (flight_id) REFERENCES AIR_FLIGHTS (flight_id)
    ADD CONSTRAINT booking_flights_ak UNIQUE (flight_id)
    ADD CONSTRAINT booking_seats_ak UNIQUE (seat);


-- PESQUISA 1 OTIMIZADA
CREATE CLUSTER air_passengers_cluster(
    passenger_id NUMBER(12,0)
)hashkeys 1024;


CREATE TABLE air_passengers_hash AS SELECT * FROM air_passengers;
ALTER TABLE air_passengers_hash ADD CONSTRAINT passengers_hash_pk PRIMARY KEY (passenger_id);

CREATE TABLE air_passengers_details_hash CLUSTER air_passengers_cluster(passenger_id) AS SELECT * FROM air_passengers_details;
ALTER TABLE air_passengers_details_hash ADD CONSTRAINT passengers_details_hash_pk PRIMARY KEY (passenger_id);

-- indice no birthdate pois é mais seletivo
CREATE INDEX idx__passengerdet_bdate ON air_passengers_details_hash(birthdate);


-- PESQUISA 2 OTIMIZADA

CREATE TABLE air_flights_hash AS SELECT * FROM air_flights;
ALTER TABLE air_flights_hash ADD CONSTRAINT flights_hash_pk PRIMARY KEY (flight_id);
ALTER TABLE air_flights_hash ADD CONSTRAINT flights_hash_fk FOREIGN KEY (airline_id) REFERENCES AIR_AIRLINES (airline_id);
ALTER TABLE air_flights_hash ADD CONSTRAINT flights_hash_fk2 FOREIGN KEY (from_airport_id) REFERENCES AIR_AIRPORTS (airport_id);
ALTER TABLE air_flights_hash ADD CONSTRAINT flights_hash_fk3 FOREIGN KEY (to_airport_id) REFERENCES AIR_AIRPORTS (airport_id);
ALTER TABLE air_flights_hash ADD CONSTRAINT flights_hash_fk4 FOREIGN KEY (airplane_id) REFERENCES AIR_AIRPLANES (airplane_id);

-- indices na maior seletividade
CREATE INDEX idx__from_airport_id ON air_flights_hash(from_airport_id);
CREATE INDEX idx__to_airport_id ON air_flights_hash(to_airport_id);



-- PESQUISA 3 OTIMIZADA

CREATE TABLE air_bookings_hash AS SELECT * FROM air_bookings;
ALTER TABLE air_bookings_hash ADD CONSTRAINT bookings_hash_pk PRIMARY KEY (booking_id);
ALTER TABLE air_bookings_hash ADD CONSTRAINT bookings_hash_fk FOREIGN KEY (passenger_id) REFERENCES AIR_PASSENGERS (passenger_id);
ALTER TABLE air_bookings_hash ADD CONSTRAINT bookings_hash_fk2 FOREIGN KEY (flight_id) REFERENCES AIR_FLIGHTS (flight_id);

-- indice na maior seletividade
CREATE INDEX idx__flight_id ON air_bookings_hash(flight_id);


-- PESQUISA 4 OTIMIZADA

CREATE CLUSTER airports_cluster(
    airport_id NUMBER(5)
)hashkeys 1024;

CREATE TABLE air_airports_hash CLUSTER airports_cluster(airport_id) AS SELECT * FROM air_airports;
ALTER TABLE air_airports_hash ADD CONSTRAINT airports_hash_pk PRIMARY KEY (airport_id);

CREATE TABLE air_airports_geo_hash CLUSTER airports_cluster(airport_id) AS SELECT * FROM air_airports_geo;
ALTER TABLE air_airports_geo_hash ADD CONSTRAINT airports_geo_hash_pk PRIMARY KEY (airport_id);
ALTER TABLE air_airports_geo_hash ADD CONSTRAINT airports_geo_hash_fk FOREIGN KEY (airport_id) REFERENCES  AIR_AIRPORTS (airport_id);


SELECT
    cia.airline_name,
    fli.departure
FROM
    air_flights fli
    INNER JOIN air_airlines cia ON fli.airline_id = cia.airline_id
    INNER JOIN air_flights_schedules sched ON fli.flightno = sched.flightno
    INNER JOIN air_airports_hash to_airport ON fli.to_airport_id = to_airport.airport_id
    INNER JOIN air_airports_geo_hash to_geo ON to_airport.airport_id = to_geo.airport_id
WHERE
    to_geo.city = 'NEW YORK'
    AND TO_CHAR(fli.departure, 'MM') = '03'
    AND (sched.TUESDAY = 1 OR sched.WEDNESDAY = 1 OR sched.THURSDAY = 1);




-- 5. listar o nome completo (primeiro nome + ultimo nome) e a idade de todos os passageiros
-- com mais de 20 anos que sairam do brasil e chegaram em outro pais, assim como o pais em que
-- chegaram.

SELECT
    pass.firstname || ' ' || pass.lastname AS nome_completo,
    TRUNC(MONTHS_BETWEEN(SYSDATE,passd.birthdate)/12) AS idade,
    to_geo.country AS pais_chegada
FROM
    air_passengers pass 
    inner join air_passengers_details passd ON pass.passenger_id = passd.passenger_id
    inner join air_bookings books ON pass.passenger_id = books.passenger_id
    inner join air_flights fli ON books.flight_id = fli.flight_id
    inner join air_airports from_airport ON fli.from_airport_id = from_airport.airport_id
    inner join air_airports to_airport ON fli.to_airport_id = to_airport.airport_id
    inner join air_airports_geo from_geo ON from_airport.airport_id = from_geo.airport_id
    inner join air_airports_geo to_geo ON to_airport.airport_id = to_geo.airport_id
WHERE
    from_geo.country = 'BRAZIL'
    AND from_geo.country <> to_geo.country
    AND passd.birthdate <= ADD_MONTHS(SYSDATE, -21 * 12);


-- OTIMIZAÇÃO DA PESQUISA 5

CREATE CLUSTER air_passengers_cluster(
    passenger_id NUMBER(12,0)
)hashkeys 1024;

CREATE TABLE air_passengers_hash AS SELECT * FROM air_passengers;
ALTER TABLE air_passengers_hash ADD CONSTRAINT passengers_hash_pk PRIMARY KEY (passenger_id);

CREATE TABLE air_passengers_details_hash CLUSTER air_passengers_cluster(passenger_id) AS SELECT * FROM air_passengers_details;
ALTER TABLE air_passengers_details_hash ADD CONSTRAINT passengers_details_hash_pk PRIMARY KEY (passenger_id);

-- indice no birthdate pois é mais seletivo
CREATE INDEX idx__passengerdet_bdate ON air_passengers_details_hash(birthdate);
CREATE INDEX idx__from_airport_id ON air_flights(from_airport_id);
CREATE INDEX idx__to_airport_id ON air_flights(to_airport_id);





