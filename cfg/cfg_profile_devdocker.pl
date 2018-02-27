{

	writeLog	=> 1,
	logFile		=> "log/logfile.csv",
	verbose		=> 1, #output also to stderr
	logAppend	=> 0, #1=append log

	outputDir		=> "data/output/",
	wwwDataDir		=> "data/www",
	dbImportDumps	=> "data/dumps/",
	rawDataDir		=> "data/raw/",
	
	dbAeType		=> "sqlite", #Aedb
	dbAeHost		=> "",
	dbAePort		=> "",
	dbAeName		=> "data/db/test.db",
	dbAeUser		=> "",
	dbAePwd			=> "",

	dbEmType		=> "mysql", #emoncms
	dbEmHost		=> "172.18.0.3", #docker 
	dbEmPort		=> "3306",
	dbEmName		=> "emoncms",
	dbEmUser		=> "emoncms",
	dbEmPwd			=> "YOUR_SECURE_PASSWORD",
	
}