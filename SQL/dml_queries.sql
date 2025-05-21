-- Data Manipulation Queries
-- Group 117: Carlos Ocampo & Amarie Drollinger

-- Variables with '@' are placeholders that will be replaced by values from the backend


-- -----------------------------------------------------
-- customers Entity
-- -----------------------------------------------------

-- Get all customers
SELECT customerID, name, address, type, contactNumber, routeID FROM customers;

-- Get a single customer by ID
SELECT customerID, name, address, type, contactNumber, routeID FROM customers WHERE customerID = @customerIDInput;

-- Add a new customer
INSERT INTO customers (name, address, type, contactNumber, routeID)
VALUES (@nameInput, @addressInput, @typeInput, @contactNumberInput, @routeIDInput);

-- Update an existing customer's information
UPDATE customers
SET name = @nameInput, address = @addressInput, type = @typeInput, contactNumber = @contactNumberInput, routeID = @routeIDInput
WHERE customerID = @customerIDToUpdate;

-- Delete a customer
DELETE FROM customers WHERE customerID = @customerIDToDelete;


-- -----------------------------------------------------
-- routes Entity
-- -----------------------------------------------------

-- Get all routes
SELECT routeID, name, routeType, schedule, activeRoute, vehicleID FROM routes;

-- Get a single route by ID
SELECT routeID, name, routeType, schedule, activeRoute, vehicleID FROM routes WHERE routeID = @routeIDInput;

-- Add a new route
INSERT INTO routes (name, routeType, schedule, activeRoute, vehicleID)
VALUES (@nameInput, @routeTypeInput, @scheduleInput, @activeRouteInput, @vehicleIDInput); -- vehicleIDInput can be NULL

-- Update an existing route
UPDATE routes
SET name = @nameInput, routeType = @routeTypeInput, schedule = @scheduleInput, activeRoute = @activeRouteInput, vehicleID = @vehicleIDInput
WHERE routeID = @routeIDToUpdate;


-- Will need to reassign customers first or set routes to inactive if deleting route due to constraints, 
DELETE FROM routes WHERE routeID = @routeIDToDelete;


-- -----------------------------------------------------
-- vehicles Entity
-- -----------------------------------------------------

-- Get all vehicles
SELECT vehicleID, licensePlate, serviceType, status, wasteTypeID FROM vehicles;

-- Get a single vehicle by ID
SELECT vehicleID, licensePlate, serviceType, status, wasteTypeID FROM vehicles WHERE vehicleID = @vehicleIDInput;

-- Add a new vehicle
INSERT INTO vehicles (licensePlate, serviceType, status, wasteTypeID)
VALUES (@licensePlateInput, @serviceTypeInput, @statusInput, @wasteTypeIDInput);

-- Update an existing vehicle
UPDATE vehicles
SET licensePlate = @licensePlateInput, serviceType = @serviceTypeInput, status = @statusInput, wasteTypeID = @wasteTypeIDInput
WHERE vehicleID = @vehicleIDToUpdate;

-
-- Deleting a vehicle will set vehicleID to NULL for its assigned routes (on delete set null), dont want to lose the customers on the route
DELETE FROM vehicles WHERE vehicleID = @vehicleIDToDelete;


-- -----------------------------------------------------
-- wasteTypes Entity
-- -----------------------------------------------------

-- Get all waste types
SELECT wasteTypeID, material, hazardous FROM wasteTypes;

-- Get a single waste type by ID
SELECT wasteTypeID, material, hazardous FROM wasteTypes WHERE wasteTypeID = @wasteTypeIDInput;

-- Add a new waste type
INSERT INTO wasteTypes (material, hazardous)
VALUES (@materialInput, @hazardousInput);

-- Update an existing waste type
UPDATE wasteTypes
SET material = @materialInput, hazardous = @hazardousInput
WHERE wasteTypeID = @wasteTypeIDToUpdate;

-- Delete a waste type
DELETE FROM wasteTypes WHERE wasteTypeID = @wasteTypeIDToDelete;


-- -----------------------------------------------------
-- disposalFacilities Entity
-- -----------------------------------------------------

-- Get all disposal facilities
SELECT facilityID, name, location, facilityType FROM disposalFacilities;

-- Get a single disposal facility by ID
SELECT facilityID, name, location, facilityType FROM disposalFacilities WHERE facilityID = @facilityIDInput;

-- Add a new disposal facility
INSERT INTO disposalFacilities (name, location, facilityType)
VALUES (@nameInput, @locationInput, @facilityTypeInput);

-- Update an existing disposal facility
UPDATE disposalFacilities
SET name = @nameInput, location = @locationInput, facilityType = @facilityTypeInput
WHERE facilityID = @facilityIDToUpdate;

-- Delete a disposal facility
DELETE FROM disposalFacilities WHERE facilityID = @facilityIDToDelete;


-- -----------------------------------------------------
-- Dropdowns
-- -----------------------------------------------------

-- For assigning a route to a customer (get all route names and IDs)
SELECT routeID, name FROM routes WHERE activeRoute = 1; -- Or all routes if inactive can be assigned

-- For assigning a vehicle to a route (get all available vehicle license plates/IDs)
SELECT vehicleID, licensePlate FROM vehicles WHERE status = 'Active';

-- For assigning a waste type to a vehicle (get all waste types)
SELECT wasteTypeID, material FROM wasteTypes;

-- For associating waste types with facilities (get all facilities and waste types)
SELECT facilityID, name FROM disposalFacilities;
-- SELECT wasteTypeID, material FROM wasteTypes;


-- -----------------------------------------------------
-- disposalFacilitiesHasWasteTypes Entity (M:M)
-- -----------------------------------------------------

-- Get all associations
SELECT dfht.facilityWasteTypeID, df.name AS facilityName, wt.material AS wasteTypeMaterial
FROM disposalFacilitiesHasWasteTypes dfht
JOIN disposalFacilities df ON dfht.facilityID = df.facilityID
JOIN wasteTypes wt ON dfht.wasteTypeID = wt.wasteTypeID;

-- Get all waste types associated with a specific facility
SELECT wt.wasteTypeID, wt.material, wt.hazardous
FROM wasteTypes wt
JOIN disposalFacilitiesHasWasteTypes dfht ON wt.wasteTypeID = dfht.wasteTypeID
WHERE dfht.facilityID = @facilityIDInput;

-- Get all facilities that handle a specific waste type
SELECT df.facilityID, df.name, df.location, df.facilityType
FROM disposalFacilities df
JOIN disposalFacilitiesHasWasteTypes dfht ON df.facilityID = dfht.facilityID
WHERE dfht.wasteTypeID = @wasteTypeIDInput;

-- Add an association (link/connect a facility to a waste type)
INSERT INTO disposalFacilitiesHasWasteTypes (facilityID, wasteTypeID)
VALUES (@facilityIDInput, @wasteTypeIDInput);

-- Delete an association (unlink a facility from a waste type)
DELETE FROM disposalFacilitiesHasWasteTypes
WHERE facilityID = @facilityIDInput AND wasteTypeID = @wasteTypeIDInput;