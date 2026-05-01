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
		while ( true ) {
			printMenuHeader();
			pick();
			pauseForMenu();
		}
	}

	function list(){
		printStateList();
	}

	function show( string state = "" ){
		var selected = findState( normalizeStateID( arguments.state ) );
		printChat( selected );
	}

	function apply( string state = "" ){
		var selected = findState( normalizeStateID( arguments.state ) );

		print.boldCyanLine( "Applying state #selected.id#: #selected.title#" );
		print.line( selected.description );
		print.line();

		applyStateChanges( selected );
		setCurrentState( selected.id );

		print.line();
		print.boldGreenLine( "Changed" );
		for ( var changedFile in selected.changed ) {
			print.line( "  - #changedFile#" );
		}

		print.line();
		print.boldLine( "Suggested next command" );
		print.line( "  #selected.command#" );

		print.line();
		printChat( selected );
	}

	function pick(){
		apply( chooseState() );
	}

	function next(){
		applyRelativeState( 1 );
	}

	function back(){
		applyRelativeState( -1 );
	}

	function reset(){
		apply( "06" );
	}

	private function printMenuHeader(){
		var current = findState( getCurrentState() );

		print.line();
		print.boldLine( "Agentic BDD Demo Console" );
		print.line( "Next command: #current.command#" );
		print.line( "Select a state to transition. Press Ctrl-C to exit." );
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
			return multiselect()
				.setQuestion( "Choose demo state" )
				.setOptions(
					getStates().map( ( state ) => {
						return {
							"display"  : "#state.id#  #state.title#",
							"value"    : state.id,
							"selected" : state.id == current
						};
					} )
				)
				.setRequired( true )
				.setMultiple( false )
				.ask();
		} catch ( any e ) {
			print.yellowLine( "Interactive picker unavailable in this terminal. Falling back to typed selection." );
			print.line();
			printStateList();
			print.line();

			var selectedState = ask( message = "Type a state id [#current#]: " );
			if ( !len( trim( selectedState ) ) ) {
				selectedState = current;
			}
			return selectedState;
		}
	}

	private function pauseForMenu(){
		print.line();
		ask( message = "Press Enter to return to the menu." );
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

		apply( states[ nextIndex ].id );
	}

	private function applyStateChanges( required struct selected ){
		if ( selected.action == "firstSpec" ) {
			runGit( "checkout -- app/models/SessionDecisionService.bx tests/specs/unit/SessionSpec.bx" );
			fileCopy(
				variables.root & "tests/resources/demo-states/01-first-spec/SessionDecisionServiceSpec.bx",
				variables.root & "tests/specs/unit/SessionDecisionServiceSpec.bx"
			);
			return;
		}

		if ( selected.action == "restoreSpecs" ) {
			runGit( "checkout -- app/models/SessionDecisionService.bx tests/specs/unit/SessionDecisionServiceSpec.bx tests/specs/unit/SessionSpec.bx" );
			return;
		}

		if ( selected.action == "bug" ) {
			runGit( "checkout -- tests/specs/unit/SessionDecisionServiceSpec.bx tests/specs/unit/SessionSpec.bx" );
			fileCopy(
				variables.root & "tests/resources/intentional-bug/SessionDecisionService.bx",
				variables.root & "app/models/SessionDecisionService.bx"
			);
			return;
		}

		if ( selected.action == "final" ) {
			runGit( "checkout -- app/models/SessionDecisionService.bx tests/specs/unit/SessionDecisionServiceSpec.bx tests/specs/unit/SessionSpec.bx" );
			return;
		}
	}

	private function runGit( required string args ){
		command( "run" )
			.params( "git #arguments.args#" )
			.run();
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
				"action" : "final",
				"changed" : [ "app/models/SessionDecisionService.bx", "tests/specs/unit/SessionDecisionServiceSpec.bx", "tests/specs/unit/SessionSpec.bx" ],
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
				"action" : "none",
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
				"action" : "none",
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
				"changed" : [ "app/models/SessionDecisionService.bx" ],
				"command" : "box run-script test:target"
			},
			{
				"id" : "06",
				"title" : "Final green suite review",
				"description" : "Restore known-good code and show the skeptical senior engineer review.",
				"promptFile" : ".ai/prompts/06-improve-with-bdd-language.md",
				"responseFile" : ".ai/responses/06-improve-with-bdd-language.md",
				"action" : "final",
				"changed" : [ "app/models/SessionDecisionService.bx", "tests/specs/unit/SessionDecisionServiceSpec.bx", "tests/specs/unit/SessionSpec.bx" ],
				"command" : "box testbox run outputFormats=mintext"
			}
		];
	}

}
