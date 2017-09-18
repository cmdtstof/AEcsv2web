{
	app			=> "AEdataProc",
	version		=> "0.7",

	fileDbScvAnlagen	=> "ae_anlagen_db_import.csv",
	fileDbCsvArbeit		=> "ae_arbeit_db_import_", #ae_arbeit_db_import_furth.csv
	fileRawArbeit		=> "ae_raw_",
	fileGesamt 			=> "dataGesamt_",    #dataGesamt_2015.csv > dataGesamt_2015.html
	fileGesamtTotal		=> "dataGesamtTotal",	#gesamtproduktion aller analgen pro jahr
	fileAnlageJahr 		=> "dataJahr_",	#Jahresproduktion_furth.csv
	fileAnlageMonat		=> "dataMonat_",
	fileAnlageTag		=> "dataTag_",
	fileAnlageTagEmon	=> "dataTagEmon_", # for arbeitemon compare test phase
	fileAnlageTagDiff	=> "dataTagDiff_", #data/dataTagDiff_furth.csv
	fileAnlageTot		=> "dataTot_",

	sep_char			=> ";",
	emptyValue		=> "&nbsp;",		# empty values will be filled with this
	
	# aedb.anlage => emoncms.feed_id, live:0=pilot, 1=live
	emonfeeds => {
		furth 		=> {feed => "feed_19", live => 1},
		chuerstein	=> {feed => "feed_54", live => 1},
		bbzherisau	=> {feed => "feed_73", live => 0},
	},	
	
}
