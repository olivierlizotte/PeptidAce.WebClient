var about = {
	'jquery':'http://www.jquery.com',
	'jquery.terminal':'http://terminal.jcubic.pl/',
	'jquery.mousewheel':'https://github.com/brandonaaron/jquery-mousewheel'	
};


var Terminal;
jQuery(document).ready(function ($) {
    
    Terminal = $('#console-div').terminal(function (command, term) {
        Terminal = term;
        switch (command) {
        	case "close":
        		CloseConsole();
        		break;
        	case "ls":
            case "help":
                term.echo("available commands are trinity, js, about, ls, help, exit, close");
                break;
            case "trinity":
                term.push(function (command, term) {
                    var data = { Type: "Command", Command: command };
                    conn.send(JSON.stringify(data));                    
                }, {
                    prompt: 'Trinity> ',
                    name: 'trinity',
                    greetings: "With great power comes great responsability"
                });
                break;
            case "about":
                term.push(function (command, term) {
                    switch (command) {
                        case "help":
                            term.echo('List of available commands :');
                            for (var i in about)
                                term.echo(i);
                            break;
                        default:
                            var result = window.eval("about['" + command + "']");
                            if (result != undefined)
                                term.echo(String(result));
                            else
                                term.echo('unknown command ' + command);
                            break;
                    }
                }, {
                    prompt: 'about> ',
                    name: 'about',
                    greetings: "This tool uses many dependencies: jquery, jquery.terminal, jquery.mousewheel"
                });
                break;
            case "js":
                term.push(function (command, term) {
                    var result = window.eval(command);
                    if (result != undefined) {
                        term.echo(String(result));
                    }
                }, {
                    name: 'js',
                    prompt: 'js> '
                });
                break;
            default:
                term.echo("unknow command " + command);
                break;
        }
    }, {
        greetings: "Advance user terminal",
        onBlur: function () {
            // prevent loosing focus
            return false;
        } 
    });
});  //*/

//Pop up window with terminal
function OpenConsole()
{
	if(Terminal)
		Terminal.enable();
    $("#openConsole").hide(0, "linear", ConSolHiddenCallback); 
	var currentWidth = $("body").width();
	var winWidth  = currentWidth * 0.9;
	if(winWidth < 300)
		winWidth = 300;
	if(winWidth > 800)
		winWidth = 800;
		
	var position = currentWidth - winWidth - 10;
	$("#console-msg-div").css({left: position + "px", width: winWidth + "px"});
	$("#console-div").show(0, "linear", function()
	{
	    $("#console-msg-div").animate({ top: "0px" }, 800, ConSolHiddenCallback);
	});
}

//Hide terminal window and show small link instead
function CloseConsole()
{
	if(Terminal)
		Terminal.disable();
    $("#openConsole").show(0, "linear", ConSolHiddenCallback); 
		$("#console-msg-div").animate({ top: -$("#console-msg-div").height() }, 500 , function()
		{
 			$("#console-div").hide(0, "linear", ConSolHiddenCallback); 
		});
}	

//empty callback function. Could be used to know when the message window is hidden
function ConSolHiddenCallback() { };

//$("#console-msg-div").clearQueue();
window.onresize = OpenConsole;