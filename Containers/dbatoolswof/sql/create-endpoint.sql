-- Create an endpoint by importing a cert that lasts 100 years
-- And do it on both servers
-- This allows the two endpoints to talk to each other
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'dbatools.IO'
GO

CREATE CERTIFICATE AGCertificate2021_2121 FROM FILE ='/tmp/AGCertificate2021_2121.cer' WITH PRIVATE KEY(FILE='/tmp/AGCertificate2021_2121.pvk', DECRYPTION BY PASSWORD='dbatools.IO')
GO

CREATE ENDPOINT [hadr_endpoint] 
	STATE=STARTED
	AS TCP (LISTENER_PORT = 5022, LISTENER_IP = ALL)
	FOR DATA_MIRRORING (ROLE = ALL, AUTHENTICATION = CERTIFICATE [AGCertificate2021_2121]
, ENCRYPTION = REQUIRED ALGORITHM AES)
GO