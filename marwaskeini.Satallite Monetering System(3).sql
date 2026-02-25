CREATE TABLE Satellite (
  SatelliteID VARCHAR(20) PRIMARY KEY,
  Name VARCHAR(50),
  LaunchDate DATE,
  MissionType VARCHAR(30),
  OrbitType VARCHAR(30),
  Status VARCHAR(20),
  MassKg DECIMAL(6,1),
  PowerWatts INT
);

INSERT INTO Satellite (SatelliteID, Name, LaunchDate, MissionType, OrbitType, Status, MassKg, PowerWatts) VALUES
('SAT001', 'Landsat 9', '2021-09-27', 'Earth Observation', 'LEO', 'Active', 2680.0, 4000),
('SAT002', 'James Webb', '2021-12-25', 'Astronomy', 'L2 Orbit', 'Active', 6200.0, 2000),
('SAT003', 'Hubble', '1990-04-24', 'Astronomy', 'LEO', 'Active', 11110.0, 2800),
('SAT004', 'Envisat', '2002-03-01', 'Earth Observation', 'Sun-synchronous', 'Retired', 8211.0, 6500),
('SAT005', 'Aqua', '2002-05-04', 'Climate Monitoring', 'Sun-synchronous', 'Active', 2945.0, 3000);


CREATE TABLE Instrument (
  InstrumentID INT PRIMARY KEY,
  SatelliteID VARCHAR(20),
  Name VARCHAR(50),
  Type VARCHAR(50),
  `Range` VARCHAR(50),
  Resolution VARCHAR(50),
  Purpose TEXT,
  PowerConsumption INT,
  Status VARCHAR(20),
  Manufacturer VARCHAR(50),
  FOREIGN KEY (SatelliteID) REFERENCES Satellite(SatelliteID)
);

INSERT INTO Instrument (InstrumentID, SatelliteID, Name, Type, `Range`, Resolution, Purpose, PowerConsumption, Status, Manufacturer) VALUES
(1, 'SAT001', 'OLI-2', 'Multispectral Imaging System', '0.43-2.3 µm', '30 meters', 'Earth surface monitoring', 60, 'Active', 'NASA'),
(2, 'SAT002', 'NIRCam', 'Near-Infrared Camera', '0.6-5 µm', '0.1 arcseconds', 'Exoplanet and galaxy observation', 400, 'Active', 'NASA'),
(3, 'SAT003', 'Wide Field Camera 3', 'Imaging', '200-1000 nm', '0.1 arcseconds', 'Astronomy and astrophysics', 300, 'Active', 'NASA'),
(4, 'SAT004', 'ASAR', 'Synthetic Aperture Radar', 'C-band radar (5.3 GHz)', '100 meters', 'Monitor sea surface winds', 800, 'Retired', 'ESA'),
(5, 'SAT005', 'Aqua AMSR-E', 'Microwave Radiometer', '1.4 GHz - 89 GHz', '30 km', 'Measure global rainfall', 550, 'Active', 'NASA');


CREATE TABLE ControlStation (
  StationID INT PRIMARY KEY,
  Name VARCHAR(100),
  Country VARCHAR(50),
  Status VARCHAR(20)
);

INSERT INTO ControlStation (StationID, Name, Country, Status) VALUES
(1, 'Wallops Flight Facility', 'USA', 'Active'),
(2, 'Kourou Space Center', 'France', 'Active'),
(3, 'Canberra Deep Space Station', 'Australia', 'Maintenance');



CREATE TABLE PositionTracking (
  TrackID INT PRIMARY KEY AUTO_INCREMENT,
  SatelliteID VARCHAR(20),
  StationID INT,
  Timestamp DATETIME,
  Latitude DECIMAL(9,6),
  Longitude DECIMAL(9,6),
  AltitudeKM DECIMAL(6,2),
  VelocityKMPS DECIMAL(5,2),
  Orientation VARCHAR(50),
  Status VARCHAR(20),
  FOREIGN KEY (StationID) REFERENCES ControlStation(StationID),
  FOREIGN KEY (SatelliteID) REFERENCES Satellite(SatelliteID) ON DELETE CASCADE
);

INSERT INTO PositionTracking (SatelliteID, StationID, Timestamp, Latitude, Longitude, AltitudeKM, VelocityKMPS, Orientation, Status) VALUES
('SAT001', 1, '2025-05-13 08:00:00', 34.050000, -118.250000, 705.00, 7.60, 'Earth-facing', 'Active'),
('SAT001', 1, '2025-05-13 08:01:00', 35.100000, -117.850000, 705.50, 7.58, 'Earth-facing', 'Active'),
('SAT001', 1, '2025-05-13 08:02:00', 36.000000, -117.300000, 706.00, 7.55, 'Earth-facing', 'Active'),
('SAT002', 2, '2025-05-13 08:00:00', 64.850000, -147.720000, 705.00, 7.72, 'Nadir-pointing', 'Active'),
('SAT002', 2, '2025-05-13 08:01:00', 65.000000, -147.500000, 705.50, 7.68, 'Nadir-pointing', 'Emergency'),
('SAT002', 2, '2025-05-13 08:02:00', 65.150000, -147.100000, 706.00, 7.65, 'Nadir-pointing', 'Lost Signal');




CREATE TABLE DataLogs (
  LogID INT PRIMARY KEY AUTO_INCREMENT,
  InstrumentID INT,
  Timestamp DATETIME,
  DataType VARCHAR(50),
  DataValue VARCHAR(255),
  Unit VARCHAR(20),
  FOREIGN KEY (InstrumentID) REFERENCES Instrument(InstrumentID)
);

INSERT INTO DataLogs (InstrumentID, Timestamp, DataType, DataValue, Unit) VALUES
(1, '2025-05-15 08:00:00', 'Spectral Reflectance', '0.45', 'unitless'),
(1, '2025-05-15 08:05:00', 'Spectral Reflectance', '0.47', 'unitless'),
(2, '2025-05-15 09:00:00', 'Infrared Flux', '120', 'W/m^2'),
(3, '2025-05-15 10:15:00', 'UV Intensity', '300', 'nm'),
(4, '2025-05-15 11:30:00', 'Radar Backscatter', '0.88', 'unitless'),
(5, '2025-05-15 12:00:00', 'Rainfall Rate', '5', 'mm/hr');


SELECT * FROM Satellite;

DELETE FROM DataLogs
WHERE LogID = 1;


UPDATE Satellite
SET Status = 'Inactive'
WHERE SatelliteID = 'SAT002';

SELECT Instrument.Name AS InstrumentName, Satellite.Name AS SatelliteName, Instrument.Type, Instrument.Status
FROM Instrument
JOIN Satellite ON Instrument.SatelliteID = Satellite.SatelliteID;


SELECT * FROM Instrument
WHERE SatelliteID IN (
  SELECT SatelliteID FROM Satellite
  WHERE LaunchDate > '2020-01-01'
);

SELECT pt.SatelliteID, cs.Name AS StationName, pt.Timestamp, pt.Latitude, pt.Longitude
FROM PositionTracking pt
JOIN ControlStation cs ON pt.StationID = cs.StationID
WHERE cs.Country = 'USA';


SELECT
    Satellite.Name AS SatelliteName,
    ControlStation.Name AS StationName,
    PositionTracking.Timestamp,
    PositionTracking.Latitude,
    PositionTracking.Longitude,
    PositionTracking.AltitudeKM,
    PositionTracking.Orientation,
    PositionTracking.Status
FROM PositionTracking
JOIN Satellite ON PositionTracking.SatelliteID = Satellite.SatelliteID
JOIN ControlStation ON PositionTracking.StationID = ControlStation.StationID
WHERE PositionTracking.SatelliteID = 'SAT001'
  AND PositionTracking.Timestamp = '2025-05-13 08:01:00';
  

