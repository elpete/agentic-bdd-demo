component {

	property name="root";
	property name="stateFile";

	function init(){
		variables.root = getDirectoryFromPath( getCurrentTemplatePath() );
		variables.stateFile = variables.root & ".demo-state.json";
		return this;
	}

	function run(){
		menu();
	}

	function menu(){
		if ( !pick() ) {
			print.greenLine( "Done." );
			return;
		}

		print.greenLine( "Done." );
	}

	function list(){
		printStateList();
	}

	function show( string state = "" ){
		var selected = findState( normalizeStateID( arguments.state ) );
		printChat( selected );
	}

	function apply( string state = "" ){
		transitionToState( normalizeStateID( arguments.state ) );
	}

	function pick(){
		var selectedState = chooseState();
		if ( isQuitInput( selectedState ) ) {
			return false;
		}

		transitionToState( selectedState );
		return true;
	}

	function next(){
		applyRelativeState( 1 );
	}

	function back(){
		applyRelativeState( -1 );
	}

	function reset(){
		runQuietTransition( findState( "06" ) );
	}

	private function printMenuHeader(){
		var current = findState( getCurrentState() );

		print.line();
		print.boldLine( "Agentic BDD Demo Console" );
		print.line( "Next command: #current.command#" );
		print.line( 'Select a state to transition. Press "q" to quit.' );
		print.line();
	}

	private function printStateList( boolean includeTitle = true ){
		var current = getCurrentState();

		if ( arguments.includeTitle ) {
			print.boldLine( "Agentic BDD Demo States" );
		} else {
			print.boldLine( "Available States" );
		}

		for ( var state in getStates() ) {
			var marker = state.id == current ? "=>" : "  ";
			print.line( "#marker# #state.id#  #state.title#" );
		}

		print.line();
		print.line( "Current state: #current#" );
	}

	private string function chooseState(){
		var current = getCurrentState();

		try {
			return pickStateWithKeyboard( current );
		} catch ( any e ) {
			print.yellowLine( "Interactive picker unavailable in this terminal. Falling back to typed selection." );
			print.line();
			printStateList();
			print.line();

			var selectedState = ask( message = 'Type a state id [#current#] or "q" to quit: ' );
			if ( !len( trim( selectedState ) ) ) {
				selectedState = current;
			}
			if ( isQuitInput( selectedState ) ) {
				return "quit";
			}
			return selectedState;
		}
	}

	private string function pickStateWithKeyboard( required string current ){
		var states = getStates();
		var activeIndex = findStateIndex( arguments.current );

		shell.clearScreen();
		printMenuHeader();
		renderStatePicker( states, activeIndex );

		while ( true ) {
			var key = waitForKey();

			if ( isQuitInput( key ) || key == "escape" ) {
				return "quit";
			}

			if ( key == "key_up" || key == "back_tab" ) {
				activeIndex = max( 1, activeIndex - 1 );
			} else if ( key == "key_down" || key == chr( 9 ) ) {
				activeIndex = min( arrayLen( states ), activeIndex + 1 );
			} else if ( key == chr( 13 ) ) {
				return states[ activeIndex ].id;
			} else if ( isNumeric( key ) ) {
				var shortcutState = normalizeStateID( key );
				if ( hasState( shortcutState ) ) {
					return shortcutState;
				}
			}

			shell.clearScreen();
			printMenuHeader();
			renderStatePicker( states, activeIndex );
		}
	}

	private function renderStatePicker( required array states, required numeric activeIndex ){
		var current = getCurrentState();

		print.boldLine( "Choose demo state" );

		for ( var i = 1; i <= arrayLen( arguments.states ); i++ ) {
			var state = arguments.states[ i ];
			var marker = i == arguments.activeIndex ? ">" : " ";
			var shortcut = val( state.id );
			var stateLine = "#marker# [#shortcut#] #state.id#  #state.title#";

			if ( state.id == current ) {
				print.boldGreenLine( "#stateLine# [current]" );
			} else if ( i == arguments.activeIndex ) {
				print.boldCyanLine( stateLine );
			} else {
				print.line( stateLine );
			}
		}

		print.line();
		print.line( "Use Up/Down, Enter to apply, 1-6 to jump, or q to quit." );
		print.toConsole();
	}

	private boolean function isQuitInput( required string value ){
		return listFindNoCase( "q,quit,exit", trim( arguments.value ) );
	}

	private numeric function findStateIndex( required string state ){
		var states = getStates();

		for ( var i = 1; i <= arrayLen( states ); i++ ) {
			if ( states[ i ].id == arguments.state ) {
				return i;
			}
		}

		return 1;
	}

	private boolean function hasState( required string state ){
		for ( var item in getStates() ) {
			if ( item.id == arguments.state ) {
				return true;
			}
		}

		return false;
	}

	private function transitionToState( required string targetState ){
		if ( !hasState( arguments.targetState ) ) {
			error( "Unknown demo state [#arguments.targetState#]. Run `box task run demo list` to see available states." );
		}

		var states = getStates();
		var currentIndex = findStateIndex( getCurrentState() );
		var targetIndex = findStateIndex( arguments.targetState );

		if ( targetIndex > currentIndex ) {
			for ( var i = currentIndex + 1; i <= targetIndex; i++ ) {
				runForwardTransition( states[ i ] );
			}
			return;
		}

		runQuietTransition( states[ targetIndex ] );
	}

	private function runForwardTransition( required struct selected ){
		printTransitionHeader( arguments.selected, "Forward transition" );
		printTypedArtifact(
			title = "Prompt",
			filePath = arguments.selected.promptFile,
			emptyMessage = "No prompt for this state."
		);

		waitForAnyKey( "Press any key to show the AI response..." );

		printTypedArtifact(
			title = "AI response",
			filePath = arguments.selected.responseFile,
			emptyMessage = "No saved AI response for this state."
		);

		applyStateChanges( arguments.selected );
		setCurrentState( arguments.selected.id );
		printChangedFiles( arguments.selected );
		waitForAnyKey( "Press any key to continue..." );
	}

	private function runQuietTransition( required struct selected ){
		printTransitionHeader( arguments.selected, "Backward transition" );
		applyStateChanges( arguments.selected );
		setCurrentState( arguments.selected.id );
		printChangedFiles( arguments.selected );
		waitForAnyKey( "Press any key to finish..." );
	}

	private function printTransitionHeader( required struct selected, required string label ){
		print.line();
		print.boldCyanLine( repeatString( "=", 72 ) );
		print.boldCyanLine( "#arguments.label#: #arguments.selected.id# - #arguments.selected.title#" );
		print.line( arguments.selected.description );
		print.boldCyanLine( repeatString( "=", 72 ) );
		print.line();
	}

	private function printTypedArtifact(
		required string title,
		required string filePath,
		required string emptyMessage
	){
		print.boldLine( arguments.title );
		print.line( repeatString( "-", 72 ) );

		if ( len( arguments.filePath ) && fileExists( variables.root & arguments.filePath ) ) {
			typeText( fileRead( variables.root & arguments.filePath ) );
		} else {
			typeText( arguments.emptyMessage );
		}
	}

	private function typeText( required string text ){
		var normalized = replace( arguments.text, chr( 13 ) & chr( 10 ), chr( 10 ), "all" );
		normalized = replace( normalized, chr( 13 ), chr( 10 ), "all" );

		print.toConsole();
		for ( var i = 1; i <= len( normalized ); i++ ) {
			shell.printString( mid( normalized, i, 1 ) );
			if ( i % 8 == 0 ) {
				sleep( 1 );
			}
		}
		shell.printString( chr( 10 ) );
	}

	private function printChangedFiles( required struct selected ){
		print.line();
		print.boldGreenLine( "Files changed" );
		print.line( repeatString( "-", 72 ) );
		for ( var changedFile in arguments.selected.changed ) {
			print.line( "  * #changedFile#" );
		}

		print.line();
		print.boldLine( "Suggested next command" );
		print.line( "  #arguments.selected.command#" );
		print.toConsole();
	}

	private function waitForAnyKey( required string message ){
		print.line();
		print.line( arguments.message );
		print.toConsole();
		try {
			waitForKey();
		} catch ( any e ) {
			if (
				e.type.toString() == "UserInterruptException" ||
				e.message == "UserInterruptException" ||
				e.message == "CANCELLED"
			) {
				rethrow;
			}
			ask( message = "Press Enter to continue: " );
		}
		print.line();
	}

	private function applyRelativeState( required numeric offset ){
		var states = getStates();
		var current = getCurrentState();
		var index = 1;

		for ( var i = 1; i <= arrayLen( states ); i++ ) {
			if ( states[ i ].id == current ) {
				index = i;
				break;
			}
		}

		var nextIndex = index + arguments.offset;
		if ( nextIndex < 1 ) {
			nextIndex = 1;
		}
		if ( nextIndex > arrayLen( states ) ) {
			nextIndex = arrayLen( states );
		}

		transitionToState( states[ nextIndex ].id );
	}

	private function applyStateChanges( required struct selected ){
		if ( selected.action == "baseline" ) {
			runGit( "checkout -- app/models/SessionDecisionService.bx" );
			deleteIfExists( variables.root & "tests/specs/unit/SessionDecisionServiceSpec.bx" );
			deleteIfExists( variables.root & "tests/specs/unit/SessionSpec.bx" );
			deleteIfExists( variables.root & "tests/specs/integration/SessionsSpec.bx" );
			return;
		}

		if ( selected.action == "firstSpec" ) {
			runGit( "checkout -- app/models/SessionDecisionService.bx" );
			deleteIfExists( variables.root & "tests/specs/unit/SessionSpec.bx" );
			deleteIfExists( variables.root & "tests/specs/integration/SessionsSpec.bx" );
			fileCopy(
				variables.root & "tests/resources/demo-states/01-first-spec/SessionDecisionServiceSpec.bx",
				variables.root & "tests/specs/unit/SessionDecisionServiceSpec.bx"
			);
			return;
		}

		if ( selected.action == "restoreSpecs" ) {
			copyFinalImplementation();
			copyFinalUnitSpecs();
			deleteIfExists( variables.root & "tests/specs/integration/SessionsSpec.bx" );
			return;
		}

		if ( selected.action == "bug" ) {
			copyFinalUnitSpecs();
			deleteIfExists( variables.root & "tests/specs/integration/SessionsSpec.bx" );
			fileCopy(
				variables.root & "tests/resources/intentional-bug/SessionDecisionService.bx",
				variables.root & "app/models/SessionDecisionService.bx"
			);
			return;
		}

		if ( selected.action == "final" ) {
			copyFinalImplementation();
			copyFinalUnitSpecs();
			copyFinalIntegrationSpec();
			return;
		}
	}

	private function copyFinalImplementation(){
		fileCopy(
			variables.root & "tests/resources/demo-states/final/SessionDecisionService.bx",
			variables.root & "app/models/SessionDecisionService.bx"
		);
	}

	private function copyFinalUnitSpecs(){
		fileCopy(
			variables.root & "tests/resources/demo-states/final/SessionDecisionServiceSpec.bx",
			variables.root & "tests/specs/unit/SessionDecisionServiceSpec.bx"
		);
		fileCopy(
			variables.root & "tests/resources/demo-states/final/SessionSpec.bx",
			variables.root & "tests/specs/unit/SessionSpec.bx"
		);
	}

	private function copyFinalIntegrationSpec(){
		fileCopy(
			variables.root & "tests/resources/demo-states/final/SessionsSpec.bx",
			variables.root & "tests/specs/integration/SessionsSpec.bx"
		);
	}

	private function runGit( required string args ){
		command( "run" )
			.params( "git #arguments.args#" )
			.run();
	}

	private function deleteIfExists( required string path ){
		if ( fileExists( arguments.path ) ) {
			fileDelete( arguments.path );
		}
	}

	private function printChat( required struct selected ){
		if ( len( selected.promptFile ) && fileExists( variables.root & selected.promptFile ) ) {
			print.line();
			print.boldBlueLine( "You paste" );
			print.line( repeatString( "-", 72 ) );
			print.line( fileRead( variables.root & selected.promptFile ) );
		}

		if ( len( selected.responseFile ) && fileExists( variables.root & selected.responseFile ) ) {
			print.line();
			print.boldMagentaLine( "Codex says" );
			print.line( repeatString( "-", 72 ) );
			print.line( fileRead( variables.root & selected.responseFile ) );
		}
	}

	private string function getCurrentState(){
		if ( !fileExists( variables.stateFile ) ) {
			return "00";
		}

		try {
			return deserializeJSON( fileRead( variables.stateFile ) ).state ?: "00";
		} catch ( any e ) {
			return "00";
		}
	}

	private function setCurrentState( required string state ){
		fileWrite( variables.stateFile, serializeJSON( { "state" : arguments.state } ) );
	}

	private string function normalizeStateID( required string state ){
		if ( !len( trim( arguments.state ) ) ) {
			return getCurrentState();
		}

		if ( isNumeric( arguments.state ) && len( arguments.state ) == 1 ) {
			return "0#arguments.state#";
		}

		return arguments.state;
	}

	private struct function findState( required string state ){
		for ( var item in getStates() ) {
			if ( item.id == arguments.state ) {
				return item;
			}
		}

		error( "Unknown demo state [#arguments.state#]. Run `box task run demo list` to see available states." );
	}

	private array function getStates(){
		return [
			{
				"id" : "00",
				"title" : "Baseline orientation",
				"description" : "Start clean, explain the CFP scoring domain, and open the service under test.",
				"promptFile" : "",
				"responseFile" : "",
				"action" : "baseline",
				"changed" : [ "Remove tests/specs/unit/SessionDecisionServiceSpec.bx", "Remove tests/specs/unit/SessionSpec.bx" ],
				"command" : "Open app/models/SessionDecisionService.bx"
			},
			{
				"id" : "01",
				"title" : "First generated spec",
				"description" : "Apply a useful but shallow first-pass AI spec with one implementation-shaped assertion.",
				"promptFile" : ".ai/prompts/01-generate-first-spec.md",
				"responseFile" : ".ai/responses/01-generate-first-spec.md",
				"action" : "firstSpec",
				"changed" : [ "tests/specs/unit/SessionDecisionServiceSpec.bx" ],
				"command" : "box run-script test:target"
			},
			{
				"id" : "02",
				"title" : "Audit before running",
				"description" : "Do not change code. Show the critique pass before execution.",
				"promptFile" : ".ai/prompts/02-audit-before-running.md",
				"responseFile" : ".ai/responses/02-audit-before-running.md",
				"action" : "firstSpec",
				"changed" : [ "No code changes" ],
				"command" : "box run-script test:dry"
			},
			{
				"id" : "03",
				"title" : "Improved BDD coverage",
				"description" : "Restore the stronger BDD specs with boundaries, minimum count, and excluded reviews.",
				"promptFile" : ".ai/prompts/03-fix-bad-test-smells.md",
				"responseFile" : ".ai/responses/03-fix-bad-test-smells.md",
				"action" : "restoreSpecs",
				"changed" : [ "tests/specs/unit/SessionDecisionServiceSpec.bx", "tests/specs/unit/SessionSpec.bx" ],
				"command" : "box run-script test:target"
			},
			{
				"id" : "04",
				"title" : "Dry-run discovery",
				"description" : "Keep code steady and inspect discovered bundles, suites, and specs before execution.",
				"promptFile" : ".ai/prompts/04-use-dry-run-discovery.md",
				"responseFile" : ".ai/responses/04-use-dry-run-discovery.md",
				"action" : "restoreSpecs",
				"changed" : [ "No code changes" ],
				"command" : "box run-script test:dry"
			},
			{
				"id" : "05",
				"title" : "Intentional failing implementation",
				"description" : "Apply the threshold bug so the equality boundary spec fails for the right reason.",
				"promptFile" : ".ai/prompts/05-debug-failing-spec.md",
				"responseFile" : ".ai/responses/05-debug-failing-spec.md",
				"action" : "bug",
				"changed" : [ "app/models/SessionDecisionService.bx (intentional failing threshold comparison)" ],
				"command" : "box run-script test:target"
			},
			{
				"id" : "06",
				"title" : "Final green suite review",
				"description" : "Restore known-good code and show the skeptical senior engineer review.",
				"promptFile" : ".ai/prompts/06-improve-with-bdd-language.md",
				"responseFile" : ".ai/responses/06-improve-with-bdd-language.md",
				"action" : "final",
				"changed" : [ "app/models/SessionDecisionService.bx", "tests/specs/unit/SessionDecisionServiceSpec.bx", "tests/specs/unit/SessionSpec.bx", "tests/specs/integration/SessionsSpec.bx" ],
				"command" : "box testbox run outputFormats=mintext"
			}
		];
	}

}
