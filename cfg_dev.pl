{
	outputDir		=> "../datatest/output/",
	wwwDataDir		=> "../datatest/www",
	dbImportDumps	=> "../datatest/dumps/",
	rawDataDir		=> "../datatest/raw/",
	
	dbAeType		=> "sqlite", #Aedb
	dbAeHost		=> "",
	dbAePort		=> "",
	dbAeName		=> "../datatest/db/test.db",
	dbAeUser		=> "",
	dbAePwd			=> "",
	
	dbEmType		=> "mysql", #emoncms
	dbEmHost		=> "emoncms", #emoncms.rosslan.home
	dbEmPort		=> "3306",
	dbEmName		=> "emoncms",
	dbEmUser		=> "emoncms",
	dbEmPwd			=> "emoncms",
}