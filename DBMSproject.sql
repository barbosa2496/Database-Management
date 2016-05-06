CREATE TABLE Ships(
	Ship_ID int NOT NULL,
	Ship_Name varchar(10) NOT NULL,
	Ship_Size varchar(5) NOT NULL,
   PRIMARY KEY(Ship_ID)
);

CREATE TABLE Cruises(
	Cruise_Id int NOT NULL,
	Ship_Id int NOT NULL REFERENCES ships(Ship_ID),
	Start_Date date NOT NULL,
	End_Date date NOT NULL,
PRIMARY KEY(Cruise_Id)
);

CREATE TABLE ROOM_Categories(
	Room_Category_Code varchar(5) NOT NULL,
	Cruise_Charge decimal(6,2) NOT NULL,
	Daily_Gratuity_Rate decimal(5,2) NOT NULL,
	Section varchar(6) NOT NULL,
PRIMARY KEY(Room_Category_Code)
);

CREATE TABLE Rooms(
	Room_Id int NOT NULL,
	Cruise_ID int NOT NULL REFERENCES cruises(Cruise_ID),
	Room_Category_Code varchar(5) NOT NULL REFERENCES       room_categories(Room_category_code),
	Room_Name varchar(10) NOT NULL,
PRIMARY KEY (Room_Id)
);
CREATE TABLE Passengers(
  Passenger_Id int NOT NULL,
	First_Name varchar(10) NOT NULL,
	Last_Name varchar(10) NOT NULL,
	Gender varchar(1) NOT NULL,
	D_O_B date NOT NULL,
	City_of_origin varchar(20) NOT NULL,
PRIMARY KEY(Passenger_Id)
);

CREATE TABLE Passenger_Reservation(
	Reservation_Id int NOT NULL,
	Cruise_Id int NOT NULL REFERENCES cruises(Cruise_ID),
	Passenger_Id int NOT NULL REFERENCES passengers(Passenger_Id),
	Room_id int NOT NULL REFERENCES rooms(room_id),
PRIMARY KEY (Reservation_Id)
);

INSERT INTO "ARTURBARBOSA1"."PASSENGER_RESERVATION" (RESERVATION_ID, CRUISE_ID, PASSENGER_ID, ROOM_ID) VALUES ('30', '101', '1', '21');

drop table passenger_reservation;
CREATE TABLE Passenger_Reservation(
	Reservation_Id int NOT NULL,
	Cruise_Id int NOT NULL REFERENCES cruises(Cruise_ID),
	Passenger_Id int NOT NULL REFERENCES passengers(Passenger_Id),
	Room_id int NOT NULL REFERENCES rooms(room_id),
PRIMARY KEY (Reservation_Id)
);
CREATE TABLE Staff(
	Attendant_Id int NOT NULL,
	Staff_Lastname varchar(10) NOT NULL,
	Staff_Firstname varchar(10) NOT NULL,
PRIMARY KEY(Attendant_Id)
);

CREATE TABLE Amenity_Catalog(
	Amenity_Cat_Code varchar(4) NOT NULL,
	Amenity_catagory_Descrip varchar(15) NOT NULL,
PRIMARY KEY(Amenity_Cat_Code)
);

CREATE TABLE Amenities(
	Amenity_Id varchar(5) NOT NULL,
	Amenity_Cat_Code varchar(4) NOT NULL REFERENCES Amenity_Catalog(Amenity_cat_code),
	Amenity_charge decimal(5,2) NOT NULL,
	Amenity_Descrip varchar(16) NOT NULL,
PRIMARY KEY(Amenity_Id)
);


drop table amenity_bookings;
CREATE TABLE Amenity_Bookings(
  Booking_ID varchar(5) NOT NULL,
	Amenity_ID varchar(5) NOT NULL REFERENCES Amenities(Amenity_Id),
	Attendant_Id int NOT NULL REFERENCES Staff(Attendant_ID),
	Passenger_Id int NOT NULL REFERENCES Passengers(Passenger_Id),
	Start_Time varchar(5),
	End_Time varchar(5),
PRIMARY KEY(Booking_Id));

CREATE VIEW PassengersBoard AS
Select P.first_name,
       P.last_name,
	     P.gender,
       P.D_o_B,
	     R.Room_Id,
	     P.Passenger_Id
FROM  passengers P,
      Passenger_Reservation R 
WHERE P.passenger_id = R.passenger_id
ORDER BY p.last_name DESC;

CREATE VIEW AmenityPopularity AS
SELECT ships.ship_id,
	     ships.ship_name,
	     ships.ship_size,
	     ab.booking_id,
       ab.amenity_id,
       a.amenity_cat_code

FROM   ships,
	     Amenity_Bookings ab,
	     Amenities a,
	     Passengers P,
	     Passenger_Reservation PR,
	     Cruises C
WHERE ab.amenity_id = a.amenity_id
And        ab.passenger_id = P.Passenger_id
AND      P.Passenger_id = PR.Passenger_id
AND      PR.Cruise_Id = C.Cruise_ID
AND C.Ship_Id = Ships.Ship_Id ;


SELECT ab.attendant_id,
	     s.staff_lastname,
	     s.staff_firstname,
	     ab.Amenity_Id
FROM   Staff s, Amenity_Bookings ab
Where  ab.attendant_id = s.attendant_id;


CREATE OR REPLACE FUNCTION gratuityTotal(resid int) RETURNS DECIMAL(12,2)
AS $totalcharge$
DECLARE
	charge DECIMAL(12,2);
	stay_total INTEGER;
BEGIN
	stay_total := (SELECT (cruises.end_date - cruises.start_date) AS reservedays
		FROM cruises, passenger_reservation
		WHERE cruises.cruise_id = passenger_reservation.cruise_id
		AND passenger_reservation.reservation_id = resid);

	SELECT INTO charge (room_categories.daily_gratuity_rate * stay_total) AS charge
	FROM cruises, rooms, room_categories, passengers, passenger_reservation
	WHERE passenger_reservation.reservation_id = resid
	AND passenger_reservation.passenger_id = passengers.passenger_id
	AND passenger_reservation.room_id = rooms.roomid
	AND passenger_reservation.cruise_id = cruises.cruise_id
	AND rooms.room_category_code = room_categories.room_category_code;

	RETURN charge;
END;
$totalcharge$
LANGUAGE plpgsql;


--Calculate the total room charge for a reservation using the reservation id
CREATE OR REPLACE FUNCTION roomTotal(resid int) RETURNS DECIMAL(12,2)
AS $totalcharge$
DECLARE
	charge DECIMAL(12,2);
	stay_total INTEGER;
BEGIN
	stay_total := (SELECT (cruises.end_date - cruises.start_date) AS reservedays
		FROM cruises, passenger_reservation
		WHERE cruises.cruise_id = passenger_reservation.cruise_id
		AND passenger_reservation.reservation_id = resid);

	SELECT INTO charge (room_categories.cruise_charge * stay_total) AS charge
	FROM cruises, rooms, room_categories, passengers, passenger_reservation
	WHERE passenger_reservation.reservation_id = resid
	AND passenger_reservation.passenger_id = passengers.passenger_id
	AND passenger_reservation.room_id = rooms.roomid
	AND passenger_reservation.cruise_id = cruises.cruise_id
	AND rooms.room_category_code = room_categories.room_category_code;

	RETURN charge;
END;
$totalcharge$
LANGUAGE plpgsql;


--remove ameninty bookings on passenger reservation removal
CREATE OR REPLACE FUNCTION remove_amenity_bookings()
RETURNS trigger AS $$
BEGIN	
	DELETE FROM amenity_bookings
	WHERE amenity_bookings.passenger_id = OLD.passenger_id;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER remove_passenger_amenitybookings
BEFORE DELETE ON passenger_reservations
FOR EACH ROW EXECUTE remove_amenity_bookings();


--remove amenity bookings on amenity removal
CREATE OR REPLACE FUNCTION remove_amenity()
RETURNS trigger AS $$
BEGIN	
	DELETE FROM amenity_bookings
	WHERE amenity_bookings.amenity_id = OLD.amenity_id;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER remove_amenity_amenitybookings
BEFORE DELETE ON amenities
FOR EACH ROW EXECUTE remove_amenity();









