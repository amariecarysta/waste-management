-- CS340 Project Step 3
-- Group 117: Carlos Ocampo & Amarie Drollinger

SET FOREIGN_KEY_CHECKS=0;
SET AUTOCOMMIT = 0;

DROP TABLE IF EXISTS `disposalFacilitiesHasWasteTypes`;
DROP TABLE IF EXISTS `customers`;
DROP TABLE IF EXISTS `routes`;
DROP TABLE IF EXISTS `vehicles`;
DROP TABLE IF EXISTS `wasteTypes`;
DROP TABLE IF EXISTS `disposalFacilities`;

-- 
-- Table `wasteTypes`
-- 
CREATE TABLE `wasteTypes` (
  `wasteTypeID` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'Primary key for waste types',
  `material` ENUM('Trash','Green Waste','Recycle','Demo') NOT NULL,
  `hazardous` BIT(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`wasteTypeID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 
-- Table `disposalFacilities`
-- 
CREATE TABLE `disposalFacilities` (
  `facilityID` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'Primary key for disposal facilities',
  `name` VARCHAR(45) NOT NULL,
  `location` VARCHAR(45) NOT NULL,
  `facilityType` ENUM('Landfill','Recycling Center','Transfer Station', 'Compost') NOT NULL,
  PRIMARY KEY (`facilityID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 
-- Table `vehicles`
-- 
CREATE TABLE `vehicles` (
  `vehicleID` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'Primary key for vehicles',
  `licensePlate` VARCHAR(45) NOT NULL COMMENT 'Unique license plate for the vehicle',
  `serviceType` ENUM('Residential','Commercial','Industrial') NOT NULL COMMENT 'Primary line of business this vehicle is used for',
  `status` ENUM('Active','Maintenance','Out of Service') NOT NULL,
  `wasteTypeID` INT(11) NOT NULL COMMENT 'Foreign key to wasteTypes, primary type of waste vehicle handles',
  PRIMARY KEY (`vehicleID`),
  UNIQUE KEY `licensePlate_UNIQUE` (`licensePlate`),
  KEY `fk_vehicles_wasteTypes_idx` (`wasteTypeID`),
  CONSTRAINT `fk_vehicles_wasteTypes` FOREIGN KEY (`wasteTypeID`) 
    REFERENCES `wasteTypes` (`wasteTypeID`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 
-- Table `routes`
-- 
CREATE TABLE `routes` (
  `routeID` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'Primary key for routes',
  `name` VARCHAR(45) NOT NULL COMMENT 'Name of the route',
  `routeType` ENUM('Residential','Commercial','Industrial') NOT NULL,
  `schedule` ENUM('Daily','Weekly','Bi-weekly','On-Call') NOT NULL,
  `activeRoute` BIT(1) NOT NULL DEFAULT b'1' COMMENT '1 if route is active, 0 if inactive',
  `vehicleID` INT(11) NULL COMMENT 'Foreign key to vehicles, the primary vehicle assigned to this route. NULL if route is unassigned.',
  PRIMARY KEY (`routeID`),
  KEY `fk_routes_vehicles_idx` (`vehicleID`),
  CONSTRAINT `fk_routes_vehicles` FOREIGN KEY (`vehicleID`) 
    REFERENCES `vehicles` (`vehicleID`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 
-- Table `customers`
-- 
CREATE TABLE `customers` (
  `customerID` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'Primary key for customers',
  `name` VARCHAR(45) NOT NULL,
  `address` VARCHAR(45) NOT NULL,
  `type` ENUM('Residential','Commercial','Industrial') NOT NULL,
  `contactNumber` VARCHAR(45) DEFAULT NULL,
  `routeID` INT(11) NOT NULL COMMENT 'Foreign key to routes, showscwhich route services this customer',
  PRIMARY KEY (`customerID`),
  KEY `fk_customers_routes_idx` (`routeID`),
  CONSTRAINT `fk_customers_routes` FOREIGN KEY (`routeID`) 
    REFERENCES `routes` (`routeID`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table `disposalFacilitiesHasWasteTypes` (Intersection table)
-- 
CREATE TABLE `disposalFacilitiesHasWasteTypes` (
  `facilityWasteTypeID` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'Primary key for M:M relationship',
  `facilityID` INT(11) NOT NULL COMMENT 'Foreign key to disposalFacilities',
  `wasteTypeID` INT(11) NOT NULL COMMENT 'Foreign key to wasteTypes',
  PRIMARY KEY (`facilityWasteTypeID`),
  UNIQUE KEY `uq_facility_wasteType` (`facilityID`, `wasteTypeID`),
  KEY `fk_junction_facilities_idx` (`facilityID`),
  KEY `fk_junction_wasteTypes_idx` (`wasteTypeID`),
  CONSTRAINT `fk_junction_facilities` FOREIGN KEY (`facilityID`) 
    REFERENCES `disposalFacilities` (`facilityID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_junction_wasteTypes` FOREIGN KEY (`wasteTypeID`) 
    REFERENCES `wasteTypes` (`wasteTypeID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



INSERT INTO `wasteTypes` (`material`, `hazardous`) VALUES 
('Trash', b'0'),
('Green Waste', b'0'),
('Recycle', b'0'),
('Demo', b'1');

INSERT INTO `disposalFacilities` (`name`, `location`, `facilityType`) VALUES 
('Kiefer Landfill', '123 Fake Street', 'Landfill'),
('Midtown Recycling Center', '1998 Tudor Street', 'Recycling Center'),
('Folsom Transfer Station', '2525 Lance Street', 'Transfer Station'),
('Altamont Landfill', '111 Cool Route', 'Landfill'),
('Elk Grove Compost', '789 Garden Way', 'Compost');

-- wasteTypeIDs: 1=Trash, 2=Green Waste, 3=Recycle, 4=Demo
INSERT INTO `vehicles` (`licensePlate`, `serviceType`, `status`, `wasteTypeID`) VALUES 
('CFG-1234', 'Residential', 'Active', (SELECT wasteTypeID FROM wasteTypes WHERE material = 'Trash')),
('RTY-5678', 'Commercial', 'Active', (SELECT wasteTypeID FROM wasteTypes WHERE material = 'Recycle')),
('IOP-9012', 'Industrial', 'Maintenance', (SELECT wasteTypeID FROM wasteTypes WHERE material = 'Demo')),
('LKJ-3456', 'Residential', 'Active', (SELECT wasteTypeID FROM wasteTypes WHERE material = 'Green Waste')),
('MLK-7890', 'Commercial', 'Out of Service', (SELECT wasteTypeID FROM wasteTypes WHERE material = 'Trash'));


INSERT INTO `routes` (`name`, `routeType`, `schedule`, `activeRoute`, `vehicleID`) VALUES 
('R101', 'Residential', 'Weekly', b'1', (SELECT vehicleID FROM vehicles WHERE licensePlate = 'CFG-1234')),
('C202', 'Commercial', 'Daily', b'1', (SELECT vehicleID FROM vehicles WHERE licensePlate = 'RTY-5678')),
('I303', 'Industrial', 'Bi-weekly', b'1', (SELECT vehicleID FROM vehicles WHERE licensePlate = 'IOP-9012')),
('R104', 'Residential', 'Weekly', b'1', (SELECT vehicleID FROM vehicles WHERE licensePlate = 'LKJ-3456')),
('C205', 'Commercial', 'Weekly', b'0', (SELECT vehicleID FROM vehicles WHERE licensePlate = 'MLK-7890')),
('R102', 'Residential', 'Weekly', b'1', (SELECT vehicleID FROM vehicles WHERE licensePlate = 'CFG-1234')); -- Vehicle CFG-1234 has two routes


INSERT INTO `customers` (`name`, `address`, `type`, `contactNumber`, `routeID`) VALUES 
('John Smith', '494 Anza Street', 'Residential', '555-1234', (SELECT routeID FROM routes WHERE name = 'R101')),
('Safeway', '1414 Business Ave', 'Commercial', '555-7890', (SELECT routeID FROM routes WHERE name = 'C202')),
('Stone Manufacturing', '6688 Wilks Lane', 'Industrial', '555-4567', (SELECT routeID FROM routes WHERE name = 'I303')),
('Kim Laney', '321 Cane Drive', 'Residential', '555-8765', (SELECT routeID FROM routes WHERE name = 'R101')),
('Mimi Cafe', '555 Main Street', 'Commercial', '555-5555', (SELECT routeID FROM routes WHERE name = 'C202')),
('Downtown Apartments', '777 Oak Street', 'Residential', '555-7777', (SELECT routeID FROM routes WHERE name = 'R104'));


INSERT INTO `disposalFacilitiesHasWasteTypes` (`facilityID`, `wasteTypeID`) VALUES 
((SELECT facilityID FROM disposalFacilities WHERE name = 'Kiefer Landfill'), (SELECT wasteTypeID FROM wasteTypes WHERE material = 'Trash')),
((SELECT facilityID FROM disposalFacilities WHERE name = 'Kiefer Landfill'), (SELECT wasteTypeID FROM wasteTypes WHERE material = 'Demo')),
((SELECT facilityID FROM disposalFacilities WHERE name = 'Midtown Recycling Center'), (SELECT wasteTypeID FROM wasteTypes WHERE material = 'Green Waste')),
((SELECT facilityID FROM disposalFacilities WHERE name = 'Midtown Recycling Center'), (SELECT wasteTypeID FROM wasteTypes WHERE material = 'Recycle')),
((SELECT facilityID FROM disposalFacilities WHERE name = 'Folsom Transfer Station'), (SELECT wasteTypeID FROM wasteTypes WHERE material = 'Trash')),
((SELECT facilityID FROM disposalFacilities WHERE name = 'Folsom Transfer Station'), (SELECT wasteTypeID FROM wasteTypes WHERE material = 'Green Waste')),
((SELECT facilityID FROM disposalFacilities WHERE name = 'Folsom Transfer Station'), (SELECT wasteTypeID FROM wasteTypes WHERE material = 'Recycle')),
((SELECT facilityID FROM disposalFacilities WHERE name = 'Altamont Landfill'), (SELECT wasteTypeID FROM wasteTypes WHERE material = 'Trash')),
((SELECT facilityID FROM disposalFacilities WHERE name = 'Altamont Landfill'), (SELECT wasteTypeID FROM wasteTypes WHERE material = 'Demo')),
((SELECT facilityID FROM disposalFacilities WHERE name = 'Elk Grove Compost'), (SELECT wasteTypeID FROM wasteTypes WHERE material = 'Green Waste'));


SET FOREIGN_KEY_CHECKS=1;
COMMIT;