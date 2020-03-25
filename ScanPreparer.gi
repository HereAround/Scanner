# --------------------------------------------------------------------
# (0) Parameters for the scan, which encode line bundle and curve
# (0) Parameters for the scan, which encode line bundle and curve

# class of curve (in basis [H,E1,E2,E3])
deg_C := [4,-1,-2,-1];

# class of curve (in basis [H,E1,E2,E3])
deg_L := [1,1,-4,2];


# --------------------------------------------------------------------
# (1) Technical input parameters
# (1) Technical input parameters
# --------------------------------------------------------------------

# Number of allowed parallel threads is [ 1,2,4,8 ]
allowed_threads := [ 1, 2, 4, 8 ];

# Set threads to your desired number of threads
# For now, I suggest to stick to just one thread
threads := 1;

# Choices for the values of the coefficients
choices := [ 0, 1 ];

# Restart interval (in minutes)
lapse := 5; # once every 'lapse'-minutes, restart the gap computations (prevent memory leak + overall quicker)

# --------------------------------------------------------------------
# (2) Create the scan superfolder
# (2) Create the scan superfolder
# --------------------------------------------------------------------

# Extract date for human-reability -> to be added to the scan folder
path := DirectoriesSystemPrograms();
date := Filename( path, "date" );
date_str := "";
a := OutputTextString( date_str, true );
Process( DirectoryCurrent(), date, InputTextNone(), a, [] );
CloseStream(a);
RemoveCharacters( date_str, " \n\t\r:" );

# And create the scan superfolder
path := Concatenation( "PullbackOfBundle", String( deg_L ), "ToDeformedCurveDefinedBy", String( deg_C ), "-", date_str );
RemoveCharacters(path, " \n\t\r");
path := ReplacedString( path, "[", "-" );
path := ReplacedString( path, "]", "-" );
path := ReplacedString( path, ",", "-" );
Exec( Concatenation( "mkdir ", path ) );


# --------------------------------------------------------------------
# (3) Create subfolders
# (3) Create subfolders
# --------------------------------------------------------------------

# for the scans
for i in [ 1 .. threads ] do
  subpath := Concatenation( path, "/Scan", String( i ) );
  Exec( Concatenation( "mkdir ", subpath ) );
od;

# for summary of results
subpath := Concatenation( path, "/SummaryOfResults" );
Exec( Concatenation( "mkdir ", subpath ) );

# for scripts to control the scan
subpath := Concatenation( path, "/Controlers" );
Exec( Concatenation( "mkdir ", subpath ) );


# --------------------------------------------------------------------
# (4) Find absolute path to scan superfolder and copy cohomCalg
# (4) Find absolute path to scan superfolder and copy cohomCalg
# --------------------------------------------------------------------

#locate the pwd program
sys_programs := DirectoriesSystemPrograms();
pwd := Filename( sys_programs, "pwd" );

#ask for the absolute path
absolute_path := "";
a := OutputTextString( absolute_path, true );
Process( DirectoryCurrent(), pwd, InputTextNone(), a, [] );
RemoveCharacters( absolute_path, "\n" );

# copy cohomCalg into scan folders
for i in [ 1 .. threads ] do
  Exec( Concatenation( "cp ", absolute_path, "/cohomcalg ", absolute_path, "/", path, "/Scan", String( i ), "/cohomcalg" ) );
od;

#and add the name of the scan folder
absolute_path := Concatenation( absolute_path, "/", path );


# --------------------------------------------------------------------
# (5) Write the individual scan files
# (5) Write the individual scan files
# --------------------------------------------------------------------

# prepare lists of beginning coefficients which are to be handed over to the threads
if Position( allowed_threads, threads ) = fail then
    Error( "The number of threads is expected to be a power of 2 and not to exceed 1024" );
fi;
fixed_coeffs_per_thread := Position( allowed_threads, threads ) - 1;

# prepare the list of fixed coefficients
fixed_coeffs := Tuples( choices, fixed_coeffs_per_thread );

# consistency check
if Length( fixed_coeffs ) <> threads then
    Error( "Inconsistency detected - number of threads does not match number of tuples of fixed coefficients" );
fi;

# Define hyperplane class etc.
H := [1,1,0,1];
E1 := [1,0,0,0];
E2 := [1,1,-1,0];
E3 := [0,0,0,1];

# Express deg_curve and deg_bundle in terms of the degrees used by gap
deg_curve := deg_C[ 1 ] * H + deg_C[ 2 ] * E1 + deg_C[ 3 ] * E2 + deg_C[ 4 ] * E3;
deg_bundle := deg_L[ 1 ] * H + deg_L[ 2 ] * E1 + deg_L[ 3 ] * E2 + deg_L[ 4 ] * E3;

# identify how many coefficients the polynomial, which defines the curve, does have
LoadPackage( "SheafC" );
rays := [ [ 1, 0 ], [ 1, 1 ], [ 0, -1 ], [ 0, 1 ], [ -1, 0 ], [ -1, -1 ] ];
max_cones := [ [ 1,2 ],[ 1,3 ],[ 2,4 ],[ 4,5 ],[ 3,6 ],[ 5,6 ] ];
dP3 := ToricVariety( Fan( rays, max_cones ) );
number_of_monoms := Length( MonomsOfCoxRingOfDegreeByNormaliz( dP3, deg_curve ) );

# compute the number of computations per thread
comps_per_threads := (number_of_monoms^Length( choices ))/threads;
if not IsInt( comps_per_threads ) then
    Error( "Inconsistency detected - number of computations per thread is not an integer" );
fi;

# set the counter which tells us in which thread we are
thread_counter := 1;

# perform loop over the individual threads
for coeff_choice in fixed_coeffs do

  # initialise the directory
  directory := Directory( Concatenation( path, "/Scan", String (thread_counter) ) );
  name := Filename( directory, "Scan.gi" );

  # open filestream
  output := OutputTextFile( name, true );
  if output = fail then # check if the stream works
    Error( "failed to set up file-stream" );
    return;
  fi;

   # turn off ugly line breaks etc.
   SetPrintFormattingStatus( output, false );

   ###############################################################
   # here the writing of the scan file starts - this will be long!
   ###############################################################
   
   WriteLine( output, """##################################################################################################""" );
   WriteLine( output, """# 0: directory, where all the data are going to be stored""" );
   WriteLine( output, """# 0: directory, where all the data are going to be stored""" );
   WriteLine( output, """##################################################################################################""" );
   AppendTo( output, "\n" );
   
   WriteLine( output, """#IMPORTANT: hard-coded path!""" );
   WriteLine( output, Concatenation( "result_directory := Directory( \"", String( absolute_path ), """/SummaryOfResults" );""" ) );
   WriteLine( output, Concatenation( "scan_directory := Directory( \"", absolute_path , """/Scan""", String(thread_counter), """" );""" ) );
   WriteLine( output, Concatenation( """name := Filename( scan_directory, "ResultOfRun""", String(thread_counter), """.txt" );""" ) );
   WriteLine( output, Concatenation( """nameCSV := Filename( scan_directory, "ResultOfRun""", String(thread_counter), """.csv" );""" ) );
   WriteLine( output, Concatenation( """nameStatus := Filename( scan_directory, "StatusOfRun""", String(thread_counter), """.txt" );""" ) );
   AppendTo( output, "\n\n" );
   
   WriteLine( output, """##################################################################################################""" );
   WriteLine( output, """# 1: Load Packages + initialise variables""" );
   WriteLine( output, """# 1: Load Packages + initialise variables""" );
   WriteLine( output, """##################################################################################################""" );
   AppendTo( output, "\n" );
   
   WriteLine( output, """# load the required package (all others are triggered automatically by this one)""" );
   WriteLine( output, """LoadPackage( "SheafCohomologyOnToricVarieties" ); """ );
   AppendTo( output, "\n" );
   
   WriteLine( output, """##################################################################################################""" );
   WriteLine( output, """# 2: set up scan function""" );
   WriteLine( output, """# 2: set up scan function""" );
   WriteLine( output, """##################################################################################################""" );
   AppendTo( output, "\n" );
   
   WriteLine( output, """compute_spectrum := function( coeffs )""" );
   WriteLine( output, """   local rays, max_cones, dP3, ir_dP3, monoms, poly, range, matrix, C_struc_sheaf, ideal, splits, deg, bundle, bundle_coho, bundle_H0, chi, bundle_H1;""" );
   AppendTo( output, "\n" );
   
   WriteLine( output, """   # toric dP3""" );
   WriteLine( output, """   rays := [ [ 1, 0 ], [ 1, 1 ], [ 0, -1 ], [ 0, 1 ], [ -1, 0 ], [ -1, -1 ] ];""" );
   WriteLine( output, """   max_cones := [ [ 1,2 ],[ 1,3 ],[ 2,4 ],[ 4,5 ],[ 3,6 ],[ 5,6 ] ];""" );
   WriteLine( output, """   dP3 := ToricVariety( Fan( rays, max_cones ) );""" );
   WriteLine( output, """   ir_dP3 := IrrelevantIdeal( dP3 );""" );
   AppendTo( output, "\n" );
   
   WriteLine( output, """   # set special cohomCalg instance to try and avoid library error""" );
   WriteLine( output, """   SetSpecialCohomCalg( dP3, [ scan_directory, Filename( scan_directory, "cohomcalg" ) ] );""" );
   AppendTo( output, "\n" );
   
   WriteLine( output, """   # construct curve and structure sheaf""" );
   WriteLine( output, Concatenation( """   monoms := MonomsOfCoxRingOfDegreeByNormaliz( dP3, """, String( deg_curve ), """ );""" ) );
   WriteLine( output, """   poly := Sum( List( [ 1 .. Length( monoms ) ], k -> coeffs[ k ] * monoms[ k ] ) );""" );
   WriteLine( output, """   range := GradedRow( [[TheZeroElement(DegreeGroup(CoxRing( dP3 ))),1]], CoxRing( dP3 ) );""" );
   WriteLine( output, """   matrix := HomalgMatrix( [[poly]], CoxRing( dP3 ) );""" );
   WriteLine( output, """   C_struc_sheaf := FreydCategoryObject( DeduceSomeMapFromMatrixAndRangeForGradedRows( matrix, range ) );""" );
   AppendTo( output, "\n" );
   
   WriteLine( output, """   # compute number of split components""" );
   WriteLine( output, """   ideal := HomalgMatrix( [ poly ], CoxRing( dP3 ) );""" );
   WriteLine( output, """   ideal := LeftSubmodule( ideal );""" );
   WriteLine( output, """   splits := PrimaryDecomposition( ideal );""" );
   WriteLine( output, """   splits := List( [ 1 .. Length( splits ) ], i -> splits[ i ][ 2 ] );""" );
   WriteLine( output, """   splits := Filtered( splits,  i -> not IsSubset( i, ir_dP3 ) );""" );
   AppendTo( output, "\n" );
   
   WriteLine( output, """   # construct the bundle""" );
   WriteLine( output, Concatenation( """   deg := """, String( deg_bundle ), """;""" ) );
   WriteLine( output, """   bundle := AsFreydCategoryObject( GradedRow( [[deg,1]], CoxRing( dP3 ) ) ) * C_struc_sheaf;""" );
   AppendTo( output, "\n" );
   
   WriteLine( output, """   # try to deduce the cohomologies from resolution""" );
   WriteLine( output, """   bundle_coho := DeductionOfSheafCohomologyFromResolution( dP3, bundle, false );""" );
   AppendTo( output, "\n" );
   
   WriteLine( output, """   # use this result to deduce H0""" );
   WriteLine( output, """   if IsInt( bundle_coho[ 1 ] ) then""" );
   WriteLine( output, """       bundle_H0 := bundle_coho[ 1 ];""" );
   WriteLine( output, """   else""" );
   WriteLine( output, """       # compute H0""" );
   WriteLine( output, """       bundle_H0 := Dimension( H0Parallel( dP3, bundle, false, false )[ 3 ] );""" );
   WriteLine( output, """   fi;""" );
   AppendTo( output, "\n" );
   
   WriteLine( output, """   # compute H1""" );
   WriteLine( output, """   chi := bundle_coho[ 1 ] - bundle_coho[ 2 ] + bundle_coho[ 3 ];""" );
   WriteLine( output, """   bundle_H1 := bundle_H0 - chi;""" );
   AppendTo( output, "\n" );
   
   WriteLine( output, """   # return result""" );
   WriteLine( output, """   return [ bundle_H0, bundle_H1, Length( splits ) ];""" );
   AppendTo( output, "\n" );
   WriteLine( output, """end;""" );
   AppendTo( output, "\n\n" );
   
   WriteLine( output, """##################################################################################################""" );
   WriteLine( output, """# 5: perform scan""" );
   WriteLine( output, """# 5: perform scan""" );
   WriteLine( output, """##################################################################################################""" );
   AppendTo( output, "\n" );
   
   WriteLine( output, """# check on old status of this scan""" );
   WriteLine( output, """if IsExistingFile( nameStatus ) then""" );
   AppendTo( output, "\n" );
   WriteLine( output, """   # read counter from file """ );
   WriteLine( output, """   input := InputTextFile( nameStatus );;""" );
   WriteLine( output, """   start_counter := EvalString( ReadAll( input ) );""" );
   WriteLine( output, """   CloseStream(input);""" );
   AppendTo( output, "\n" );
   WriteLine( output, """else""" );
   AppendTo( output, "\n" );
   WriteLine( output, """   # create this file and write 0 to it""" );
   WriteLine( output, """   output := OutputTextFile( nameStatus, true );""" );
   WriteLine( output, """   SetPrintFormattingStatus( output, false );""" );
   WriteLine( output, """   if output = fail then""" );
   WriteLine( output, """       Error( "failed to set up file-stream" );""" );
   WriteLine( output, """       return;""" );
   WriteLine( output, """   fi;""" );
   WriteLine( output, """   PrintTo( output, "0" );""" );
   WriteLine( output, """   CloseStream(output);""" );
   AppendTo( output, "\n" );
   WriteLine( output, """   # set start counter""" );
   WriteLine( output, """   start_counter := 0;""" );
   AppendTo( output, "\n" );
   WriteLine( output, """fi;""" );
   AppendTo( output, "\n" );
   
   WriteLine( output, """# set up function that performs the scan""" );
   WriteLine( output, """performScan := function( start )""" );
   
   # initialize local variables
   l := List( [ 1 .. number_of_monoms - Length( coeff_choice ) ], i -> Concatenation( "e", String( i ) ) );
   s := JoinStringsWithSeparator( l, "," );
   s := Concatenation( "	local ", s, ", counter, coeffs, res, poly, ideal, splits, s, output;" );
   WriteLine( output, String( s ) );
   
   AppendTo( output, "\n" );
   WriteLine( output, """	counter := 0;""" );
   AppendTo( output, "\n" );
   
   # write as many loops as required to cover the remaining coefficients
   for i in [ 1 .. number_of_monoms - Length( coeff_choice ) ] do
        WriteLine( output, Concatenation( """	for e""", String( i ), """ in """, String( choices ), """ do""" ) );
   od;
   AppendTo( output, "\n" );
   
   WriteLine( output, """		# go to position where the scan is to start""" );
   WriteLine( output, """		if counter < start then""" );
   WriteLine( output, """		   counter := counter + 1;""" );
   WriteLine( output, """		   continue;""" );
   WriteLine( output, """		fi;""" );
   AppendTo( output, "\n" );
   WriteLine( output, """		# (i) inform what computation we are doing""" );
   s1 := JoinStringsWithSeparator( List( [ 1 .. Length( coeff_choice ) ], i -> String( coeff_choice[ i ] ) ), "," );
   s2 := JoinStringsWithSeparator( List( [ 1 .. number_of_monoms - Length( coeff_choice ) ], i -> Concatenation( "e", String( i ) ) ), "," );
   if Length( coeff_choice ) = 0 then
        WriteLine( output, Concatenation( """		coeffs := [ """, s2, """ ];""" ) );
   else
        WriteLine( output, Concatenation( """		coeffs := [ """, s1, """, """, s2, """ ];""" ) );
   fi;
   WriteLine( output, """		Print( Concatenation( String( counter+1 ), ": ", String( coeffs ), "...\n" ) );""" );
   AppendTo( output, "\n" );
   WriteLine( output, """		# continue only if not all coefficients are zero""" );
   WriteLine( output, """		if not ForAll( coeffs, IsZero ) then""" );
   AppendTo( output, "\n" );
   WriteLine( output, """   		  # (ii) perform the computation""" );
   WriteLine( output, """   		  res := TOOLS_FOR_HOMALG_GET_REAL_TIME_OF_FUNCTION_CALL( compute_spectrum, coeffs );""" );
   AppendTo( output, "\n" );
   WriteLine( output, """   		  # (v) write to CSV-file""" );
   WriteLine( output, """   		  s := Concatenation( "\"", String( Float( coeffs[ 1 ] ) ), "," );""" );
   for i in [ 2 .. number_of_monoms - 1 ] do
        WriteLine( output, Concatenation( """   		  s := Concatenation( s, String( Float( coeffs[ """, String( i ), """ ] ) ), "," );""" ) );
   od;
   WriteLine( output, Concatenation( """   		  s := Concatenation( s, String( Float( coeffs[ """, String( number_of_monoms ), """ ] ) ), "\"," );""" ) );
   WriteLine( output, Concatenation( """   		  s := Concatenation( s, "\"", String( """, String( deg_C ), """ ), "\"," );""" ) );
   WriteLine( output, Concatenation( """   		  s := Concatenation( s, "\"", String( """, String( deg_L ), """ ), "\"," );""" ) );
   WriteLine( output, """   		  s := Concatenation( s, "\"", String( res[ 1 ] ), "\"," );""" );
   WriteLine( output, """   		  s := Concatenation( s, "\"", String( res[ 2 ][ 1 ] ), "\"," );""" );
   WriteLine( output, """   		  s := Concatenation( s, "\"", String( res[ 2 ][ 2 ] ), "\"," );""" );
   WriteLine( output, """   		  s := Concatenation( s, "\"", String( res[ 2 ][ 3 ] ), "\"\n" );""" );
   WriteLine( output, """   		  output := OutputTextFile( nameCSV, true );""" );
   WriteLine( output, """   		  SetPrintFormattingStatus( output, false );""" );
   WriteLine( output, """   		  if output = fail then""" );
   WriteLine( output, """   		  	Error( "failed to set up file-stream" );""" );
   WriteLine( output, """	      	   	return;""" );
   WriteLine( output, """   		  fi;""" );
   WriteLine( output, """   		  AppendTo( output, s );""" );
   WriteLine( output, """   		  CloseStream(output);""" );
   AppendTo( output, "\n" );
   WriteLine( output, """   		  # (vi) inform about result""" );
   WriteLine( output, """   		  Print( Concatenation( "Time: ", String( res[ 1 ] ), "s\n" ) );""" );
   WriteLine( output, """   		  Print( Concatenation( "Hi: ", String( [ res[ 2 ][ 1 ], res[ 2 ][ 2 ] ] ), "\n" ) );""" );
   WriteLine( output, """   		  Print( Concatenation( "Splits: ", String( res[ 2 ][ 3 ] ), "\n\n" ) );""" );
   AppendTo( output, "\n" );
   WriteLine( output, """		else;""" );
   WriteLine( output, """   		  Print( "no computation - continue...\n" );""" );
   WriteLine( output, """		fi;""" );
   AppendTo( output, "\n" );
   WriteLine( output, """		# (vii) increase counter and signal end of computation""" );
   WriteLine( output, """		counter := counter + 1;""" );
   AppendTo( output, "\n" );
   WriteLine( output, """		# (viii) save value of counter to status file""" );
   WriteLine( output, """		RemoveFile( nameStatus );""" );
   WriteLine( output, """		output := OutputTextFile( nameStatus, true );""" );
   WriteLine( output, """		SetPrintFormattingStatus( output, false );""" );
   WriteLine( output, """		if output = fail then""" );
   WriteLine( output, """		   Error( "failed to set up file-stream" );""" );
   WriteLine( output, """		   return;""" );
   WriteLine( output, """		fi;""" );
   WriteLine( output, """		AppendTo( output, String( counter ) );""" );
   WriteLine( output, """		CloseStream(output);""" );
   AppendTo( output, "\n" );
    
   # write closing for as many loops as required to cover the remaining coefficients
   for i in [ 1 .. number_of_monoms - Length( coeff_choice ) ] do
        WriteLine( output, """	od;""" );
   od;
   AppendTo( output, "\n" );
   
   WriteLine( output, """	# return result""" );
   WriteLine( output, """	return true;""" );
   AppendTo( output, "\n" );
   WriteLine( output, """end;""" );
   AppendTo( output, "\n" );
   
   WriteLine( output, """# inform that we are ready for the scan""" );
   WriteLine( output, """Print( "Starting the scan... \n\n" );""" );
   WriteLine( output, """performScan( start_counter );""" );
   AppendTo( output, "\n" );
   WriteLine( output, """# signal that scan terminated...""" );
   WriteLine( output, """Print( "Scan completed! \n\n" );""" );
   WriteLine( output, """Print( "--------------------------------------------------------------------\n\n" );""" );
   AppendTo( output, "\n" );
   WriteLine( output, """QUIT;""" );

   # finally close the stream that wrote the scan file
   CloseStream(output);

   #################################################
   # the writing of the scan file ends here
   #################################################

   # increase counters
  thread_counter:=thread_counter+ 1;

od;


# --------------------------------------------------------------------
# (6) Write the starter file
# (6) Write the starter file
# --------------------------------------------------------------------

# initialise the directory and the filename
name := Filename( Directory( Concatenation( path, "/Controlers" ) ), "Start.gi" );

# open filestream
output := OutputTextFile( name, true );
if output = fail then # check if the stream works
  Error( "failed to set up file-stream" );
  return;
fi;

# turn off ugly line breaks etc.
SetPrintFormattingStatus( output, false );

# write the contents
WriteLine( output, """############################################################################""" );
WriteLine( output, """#### (1) Locate screen""" );
WriteLine( output, """#### (1) Locate screen""" );
WriteLine( output, """############################################################################""" );
AppendTo( output, "\n" );
WriteLine( output, """sys_programs := DirectoriesSystemPrograms();""" );
WriteLine( output, """screen := Filename( sys_programs, "screen" );""" );
AppendTo( output, "\n\n" );

WriteLine( output, """############################################################################""" );
WriteLine( output, """#### (2) Absolute path to scan superfolder""" );
WriteLine( output, """#### (2) Absolute path to scan superfolder""" );
WriteLine( output, """############################################################################""" );
AppendTo( output, "\n" );
WriteLine( output, Concatenation( "scan_superfolder := \"", absolute_path, "\";" ) );
AppendTo( output, "\n\n" );

WriteLine( output, """############################################################################""" );
WriteLine( output, """#### (3) Start scans""" );
WriteLine( output, """#### (3) Start scans""" );
WriteLine( output, """############################################################################""" );
AppendTo( output, "\n" );
WriteLine( output, Concatenation( """for i in [ 1 .. """, String( Int( threads ) ), """ ] do""" ) );
WriteLine( output, """	scan_file := Concatenation( scan_superfolder, "/Scan", String( i ), "/Scan.gi" );""" );
WriteLine( output, """	scan_file := ReplacedString( scan_file, " ", "\\ ");""" );
WriteLine( output, Concatenation("""	Exec( Concatenation( "screen -dm -S Scan",""", "\"", date_str, "_\"", """, String ( i ), " gap -o 0 ", scan_file ) );""" ) );
WriteLine( output, """od;""" );
AppendTo( output, "\n\n" );

WriteLine( output, """############################################################################""" );
WriteLine( output, """#### (4) Close session""" );
WriteLine( output, """#### (4) Close session""" );
WriteLine( output, """############################################################################""" );
AppendTo( output, "\n" );
WriteLine( output, """QUIT;""" );

# close the stream
CloseStream(output);


# --------------------------------------------------------------------
# (8) Write file to collect the individual results
# (8) Write file to collect the individual results
# --------------------------------------------------------------------

# initialise the directory and the filename
name := Filename( Directory( Concatenation( path, "/Controlers" ) ), "Collect.gi" );

# open filestream
output := OutputTextFile( name, true );
if output = fail then # check if the stream works
  Error( "failed to set up file-stream" );
  return;
fi;

# turn off ugly line breaks etc.
SetPrintFormattingStatus( output, false );

# write the contents
WriteLine( output, """############################################################################""" );
WriteLine( output, """# (1) initialise the target.csv file""" );
WriteLine( output, """# (1) initialise the target.csv file""" );
WriteLine( output, """############################################################################""" );
AppendTo( output, "\n" );
WriteLine( output, """# open the target file (delete if already exists)""" );
WriteLine( output, Concatenation( """deg_L := """, String( deg_L ), """;""" ) );
WriteLine( output, Concatenation( """deg_C := """, String( deg_C ), """;""" ) );
WriteLine( output, Concatenation( """date_str := """, "\"", date_str, "\"", """;""" ) );
WriteLine( output, """target_name := Concatenation( "SummaryOfResults-PullbackOfBundle", String( deg_L ), "ToDeformedCurveDefinedBy", String( deg_C ), "-", date_str, ".csv" );""" );
WriteLine( output, Concatenation( """target_directory := Directory( Concatenation( """, "\"", String( absolute_path ), "\"", """, "/SummaryOfResults" ) );""") );
WriteLine( output, """target := OutputTextFile( Filename( target_directory, target_name ), false );""" );
AppendTo( output, "\n" );
WriteLine( output, """# check if the stream works""" );
WriteLine( output, """if target = fail then""" );
WriteLine( output, """	Error( Concatenation( "failed to set up file-stream to target file", target_name ) );""" );
WriteLine( output, """	return;""" );
WriteLine( output, """fi;""" );
AppendTo( output, "\n\n" );

WriteLine( output, """############################################################################""" );
WriteLine( output, """# (2) iterate over the result files""" );
WriteLine( output, """# (2) iterate over the result files""" );
WriteLine( output, """############################################################################""" );
AppendTo( output, "\n" );
WriteLine( output, """WriteLine( target, Concatenation( "\"", "coeffs", "\"", ",", "\"", "curve", "\"", ",", "\"", "bundle", "\"", ",", "\"", "time", "\"", ",", "\"", "h0", "\"", ",", "\"", "h1", "\"", ",", "\"", "splits", "\"" ) );""" );
AppendTo( output, "\n" );
WriteLine( output, Concatenation( """for i in [ 1 .. """, String( threads ), """ ] do""" ) );
AppendTo( output, "\n" );
WriteLine( output, """	# open source_file""" );
WriteLine( output, Concatenation( """	source_directory := Directory( Concatenation( """, "\"", String( absolute_path ), "\"", """, "/Scan", String( i ) ) );""") );
WriteLine( output, """	source := InputTextFile( Filename( source_directory, Concatenation( "ResultOfRun", String ( i ), ".csv" ) ) );""" );
AppendTo( output, "\n" );
WriteLine( output, """	# check if the stream works""" );
WriteLine( output, """	if source = fail then""" );
WriteLine( output, """		Error( "failed to set up file-stream" );""" );
WriteLine( output, """		return;""" );
WriteLine( output, """	elif IsReadableFile( Filename( source_directory, Concatenation( "ResultOfRun", String ( i ), ".csv" ) ) ) = false then""" );
WriteLine( output, """		Error( Concatenation( "cannot read from file 'ResultOfRun", String ( i ), ".txt'" )  );""" );
WriteLine( output, """		return;""" );
WriteLine( output, """	fi;""" );
AppendTo( output, "\n" );
WriteLine( output, """	# read source file and add its contents to the target file""" );
WriteLine( output, """	WriteLine( target, ReadAll( source ) );""" );
AppendTo( output, "\n" );
WriteLine( output, """	# close the source_file""" );
WriteLine( output, """	CloseStream( source );""" );
AppendTo( output, "\n" );
WriteLine( output, """od;""" );
AppendTo( output, "\n\n" );

WriteLine( output, """############################################################################""" );
WriteLine( output, """# (3) close the target stream""" );
WriteLine( output, """# (3) close the target stream""" );
WriteLine( output, """############################################################################""" );
AppendTo( output, "\n" );
WriteLine( output, """CloseStream( target );""" );
AppendTo( output, "\n\n" );

WriteLine( output, """############################################################################""" );
WriteLine( output, """# (4) remove all cronjobs""" );
WriteLine( output, """# (4) remove all cronjobs""" );
WriteLine( output, """############################################################################""" );
AppendTo( output, "\n" );
WriteLine( output, """Exec( "crontab -r" );""" );
AppendTo( output, "\n\n" );

WriteLine( output, """############################################################################""" );
WriteLine( output, """#### (5) Close session""" );
WriteLine( output, """#### (5) Close session""" );
WriteLine( output, """############################################################################""" );
AppendTo( output, "\n" );
WriteLine( output, """QUIT;""" );

# close the stream
CloseStream(output);


# --------------------------------------------------------------------
# (9) Set up script to restart the scan
# (9) Set up script to restart the scan
# --------------------------------------------------------------------

# initialise restart.sh
name := Filename( Directory( Concatenation( path, "/Controlers" ) ), "restart.sh" );

# open filestream
output := OutputTextFile( name, true );
if output = fail then # check if the stream works
  Error( "failed to set up file-stream" );
  return;
fi;

# turn off ugly line breaks etc.
SetPrintFormattingStatus( output, false );

# write opening of script
WriteLine( output, """#!/bin/sh""" );
AppendTo( output, "\n" );

# write time/date and status of individual runs to log file
WriteLine( output, Concatenation( """/bin/date >> """, absolute_path, """/MyScan.log""" ) );
for i in [ 1 .. threads ] do
    WriteLine( output, Concatenation( "echo \"", """Scan""", String( i ), """: """, "\"", """ >> """, absolute_path, """/MyScan.log""" ) );
    WriteLine( output, Concatenation( """cat """, absolute_path, """/Scan""", String( i ), """/StatusOfRun""", String( i ), """.txt""", """ >> """, absolute_path, """/MyScan.log""" ) );
od;
WriteLine( output, Concatenation( "echo \"", """\n""", "\"", """ >> """,  absolute_path, """/MyScan.log""" ) );

# next kill all screens and delete tmp files
AppendTo( output, "\n" );
WriteLine( output, """/usr/bin/pkill screen""" );
WriteLine( output, """rm -rf /tmp/*""" );

# and restart the screens again
WriteLine( output, Concatenation( """/usr/bin/gap """, absolute_path, """/Controlers/Start.gi""" ) );

# close the stream
CloseStream(output);

# make this script executable
Exec( Concatenation( "chmod +x ", absolute_path, "/Controlers/restart.sh" ) );


# --------------------------------------------------------------------
# (10) Set up cronjob
# (10) Set up cronjob
# --------------------------------------------------------------------

#write out current crontab
Exec( """crontab -l > mycron""" );

#echo new cron into cron file
command := Concatenation("""echo """, "\"","""*/""", String( lapse ),""" * * * * """, absolute_path, """/Controlers/restart.sh > """, absolute_path, """/MyCronJob.log 2>&1""", "\"", """>> mycron""" );
Exec( command );

#install new cron file
Exec( """crontab mycron""" );
Exec( """rm mycron""" );

#crontab -e
#*/1 * * * * absolute_path/Controlers/restart.sh > /dev/null


# --------------------------------------------------------------------
# (11) Start the scan
# (11) Start the scan
# --------------------------------------------------------------------

start_file := ReplacedString( Concatenation( absolute_path, "/Controlers/Start.gi" ), " ", "\\ ");
Exec( Concatenation( "screen -dm -S Supervisor gap -o 0 ", start_file ) );


# --------------------------------------------------------------------
# (12) Inform about status
# (12) Inform about status
# --------------------------------------------------------------------

Print( "\n" );
Print( "----------------------\n" );
Print( "(*) Scan initiated\n" );
Print( "(*) Cronjob running\n" );
Print( "----------------------\n" );
Print( "\n" );


# --------------------------------------------------------------------
# (12) Close
# (12) Close
# --------------------------------------------------------------------
QUIT;

# Useful 1: End all screens
# pkill screen

# Useful 2: Display CRON log
# grep CRON /var/log/syslog

# Latest changes:
# (*) sudo apt-get install postfix
# (*) Redirecting output of cron to log file
# (*) Deleting temporary files once cronjob is being executed
