Const CONNECT_STRING = "Provider=SQLOLEDB;Data Source=HOMEPC\SQL_2016;Database=StackOverflow;Integrated Security=SSPI"
Set objBL = CreateObject("SQLXMLBulkLoad.SQLXMLBulkload.4.0")
objBL.ErrorLogFile = "X:\sample3.log"
objBL.ConnectionString = CONNECT_STRING
objBL.Execute "D:\PROJECT\XML\SQLXMLBulkLoad\sample3.xsd", "X:\sample3.xml"