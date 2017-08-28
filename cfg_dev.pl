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
	
	# aedb.anlage => emoncms.feed_id, live:0=pilot, 1=live
	emonfeeds => {
		furth 		=> {feed => "feed_19", live => 0},
		chuerstein	=> {feed => "feed_54", live => 0},
	},	
	
}