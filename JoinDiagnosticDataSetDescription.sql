/****** Skript für SelectTopNRows-Befehl aus SSMS ******/
SELECT FK_ReadOut, StartDateTime, EndDateTime, AlarmCount, Latitude, Longitude, DiagnosticDataSetDefinition.Description_L1, EnvironmentDataSet.DigitalSignalValues, EnvironmentDataSet.AnalogSignalValues
  FROM DiagnosticDataSet 
  JOIN DiagnosticDataSetDefinition ON (DiagnosticDataSet.FK_DiagnosticDataSetDefinition = DiagnosticDataSetDefinition.DefinitionNumber)
  JOIN EnvironmentDataSet ON (EnvironmentDataSet.FK_DiagnosticDataSet = DiagnosticDataSet.PK_DiagnosticDataSet)
  ORDER BY DiagnosticDataSet.StartDateTime