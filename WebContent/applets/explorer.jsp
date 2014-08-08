<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">

    <title>Advanced BioInformatic Computing and Development Engine</title>

<!-- CSS Files -->
<link type="text/css" href="css/msg.css" rel="stylesheet" />
<link type="text/css" href="css/nv.d3.css" rel="stylesheet">

<!-- JavaScript -->
<script type="text/javascript" src="js/jquery-1.7.2.min.js"></script>

<!-- Ext JS Library file -->
<script type="text/javascript" src="js/ExtJS/bootstrap.js"></script>
<link rel="stylesheet" type="text/css" href="js/ExtJS/resources/css/ext-all.css" />

    <script type="text/javascript" src="js/d3/d3.js" charset="utf-8"></script>
    <!-- script type="text/javascript" src="js/d3/d3.geom.js"></script-->
    <!--  script type="text/javascript" src="js/d3/d3.layout.js"></script -->    
	<script type="text/javascript" src="js/d3/nv.d3_forkarlm.js"></script>
	<script type="text/javascript" src="js/jquery.tipsy.js"></script>
    <link href="css/tipsy.css" rel="stylesheet" type="text/css" />
    
	<script type="text/javascript" src="js/graph.js"></script>

    <meta name="author" content="Olivier Caron-Lizotte - olivier&#64;ocltech.ca"/>
    <meta name="Description" content="BioInformatic Javascript Development Framework"/>
    <link rel="sitemap" type="application/xml" title="Sitemap" href=""/>
    <link rel="shortcut icon" href="favicon.ico"/>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
    <!--script src="js/jquery-1.7.1.min.js"></script-->
    <script type='text/javascript' src="js/jquery.mousewheel-min.js"></script>
    
    <script type="text/javascript" src="lorikeet/js/jquery.flot.js"></script>
    <script type="text/javascript" src="lorikeet/js/jquery.flot.selection.js"></script>
    
    <script type="text/javascript" src="lorikeet/js/specview.js"></script>
    <script type="text/javascript" src="lorikeet/js/peptide.js"></script>
    <script type="text/javascript" src="lorikeet/js/aminoacid.js"></script>
    <script type="text/javascript" src="lorikeet/js/ion.js"></script>
    
    <script type='text/javascript' src="js/jquery.terminal-min.js"></script>
    <link href="css/jquery.terminal.css" rel="stylesheet"/>	
    <script type='text/javascript' src="js/console.js"></script>


        <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.4/jquery-ui.min.js"></script>
    

	<link href="css/window.css" rel="stylesheet"/>
	<link href="css/page.css" rel="stylesheet"/>
</head>

<script type="text/javascript">

var graphItemNumber=0;

Ext.Loader.setConfig({
    enabled: true
});
	
<%@include file="getInfo.jsp"%>

<%@include file="createGrid.jsp"%>
var charts=[];
<%@include file="drawCharts.jsp"%>
if (charts.length > 0){
	graphItemNumber=1;
}


MessageTop = function(){
    var msgCt;

    function createBox(t, s)
    {
       return '<div class="msg" style="position:absolute;"><h3>' + t + '</h3><p>' + s + '</p></div>';
    };
    
    return {
        msg : function(title, format){
            if(!msgCt){
                msgCt = Ext.DomHelper.insertFirst(document.body, {id:'msg-div'}, true);
            }
            var s = Ext.String.format.apply(String, Array.prototype.slice.call(arguments, 1));
            var m = Ext.DomHelper.append(msgCt, createBox(title, s), true);
            m.hide();
            m.slideIn('t').ghost("t", { delay: 1000, remove: true});
        },

        init : function(){
        }
    };
}();

function columnDesc(val) {
        return '<div style="overflow: auto !important; white-space: normal !important;">'+val+'</div>';
        return val;
}  

function showHelp (){
	var plotWin = Ext.create('Ext.Window', {
	    title: 'Database structure',
	    width: 400,
	    height: 650,
//	    x: 10,
//	    y: 200,
	    plain: true,
	    headerPosition: 'top',
	    layout: 'fit',
	    items: {
	        xtype: 'image',
	        src: "icons/network.png"
	    }
	});
	plotWin.show();
}

var navigate = function(panel, direction){
    // This routine could contain business logic required to manage the navigation steps.
    // It would call setActiveItem as needed, manage navigation button state, handle any
    // branching logic that might be required, handle alternate actions like cancellation
    // or finalization, etc.  A complete wizard implementation could get pretty
    // sophisticated depending on the complexity required, and should probably be
    // done as a subclass of CardLayout in a real-world implementation.
    var layout = panel.getLayout();
    layout[direction]();
    Ext.getCmp('move-prev').setDisabled(!layout.getPrev());
    Ext.getCmp('move-next').setDisabled(!layout.getNext());
    if (direction=='next'){
    	graphItemNumber+=1;
    	document.getElementById('graphItemNumber').innerHTML='page:'+graphItemNumber+'/'+charts.length;
    }else{
    	graphItemNumber-=1;
    	document.getElementById('graphItemNumber').innerHTML='page:'+graphItemNumber+'/'+charts.length;
    }
};

var viewport;
var commentGrid;
var nodeStoreComment;

function CreateComments(myComments)
{	
	if(!commentGrid)
	{
		Ext.define('ncModel', {
		    extend: 'Ext.data.Model',
		    fields: [{name : "comment", type :'string'}]
		});
		
	    nodeStoreComment = Ext.create('Ext.data.Store', {
	        storeId: 'nodeCommentStoreID',
	        model: 'ncModel',
	        data: myComments
	    });
	    
	    //commentGrid = Ext.create('Ext.container.Container', {
	    commentGrid = Ext.create('Ext.container.Container', {
	        title: 'Comments',
	        //height: 240,
	        layout: {
	            type: 'vbox',      
	            align: 'stretch'    
	        },
        	border: false,
            //bodyPadding: 0,
	        items: [{             
	            xtype: 'grid',
	            hideHeaders: true,
	            border: true,
	            columns: [{text:'Comments', flex:1, dataIndex:'comment', renderer: columnDesc}],
	            store: nodeStoreComment, 
	            flex: 1                                      
                //layout: 'fit'
	        	},
	        	//{tag:'hr'},
	            {
	                xtype     : 'textareafield',
	                name      : 'newCommentField',
	                emptyText : "Add comment...",
	                //height : 80,
	                maxHeight:40,
	                //flex: 1,
	                //bodyPadding: 0,
	                //padding : 0,
	                margins: '5 0 -5 0',
	                enableKeyEvents: true,
	                listeners: {
	                	keypress: function(field,event)
	                    {	
	                		var theCode = event.keyCode ? event.keyCode : event.which ? event.which : event.charCode;
	                		if (theCode == 13)//If enter was pressed
	                		{
	                    		AddComment(field, event);
	                    		field.reset();
	                    		event.stopEvent();
	                		}
	                    	else
	                    		if(theCode == 32)//space bar, trap it
	                    			return false;
	                    		else
	                    			return true;
	                    }
	                }
	            }
	        ]
	    });
	}
	else
		nodeStoreComment.loadData(myComments);
    
    return commentGrid;
}

function replaceAll(txt, replace, with_this)
{
	return txt.replace(new RegExp(replace, 'g'), with_this);
}

function AddComment(field, event) 
{
	//Send new comment to a jsp file that will add the comment and return the new list of comments		
	var texte = field.getValue();
	if(!(texte === ""))
	{
		texte = replaceAll(texte,"\f",   "<br/>");
		texte = replaceAll(texte,"\r",   "<br/>");
		texte = replaceAll(texte,"\n",   "<br/>");
		texte = replaceAll(texte,"&",    "&amp;");
		texte = replaceAll(texte,"\"",   "&quot;");
		texte = replaceAll(texte,"/\\/", "&brvbar;");
		texte = replaceAll(texte,"'",    "&apos;")
		texte = replaceAll(texte,"<",    "&lt;")
		texte = replaceAll(texte,">",    "&gt;")
 		
		$.post(	"addComment.jsp",
				{"id":currentNodeID,"user":<%=session.getAttribute("userNodeID")%>, "comment": texte}, 
				function(results)
				{				 	
			 		CreateComments( eval(results) );
			 		MessageTop.msg("Comment added", texte);
				});
	}
	return false; 
}   

function AddAttribute(btn, text)
{
	myAttributeObject[text] = "";
	attribPanel.setSource(myAttributeObject);
	MessageTop.msg('Button Click', 'You clicked the {0} button and entered the text "{1}".', btn, text);
};

function AddNode(btn, text)
{
   	Ext.Ajax.request({
 				url   : "AddNode.jsp?id=" + currentNodeID + "&db=" + currentDB,
 				type  : 'POST',
 				//data  : myAttributeObject,
 				params: {type: text},
	      		success: function(result) {
	      			MessageTop.msg("Success!", "Node Created");
	      			window.location = "index.jsp?id=" + result.responseText;
	     		}
	    	});
};

function showTools(){
var toolWin = new Ext.create(
		'Ext.Window',
		{
			id : 'autoload-win',
			title : currentNodeType
					+ ' Tools',
			closable : true,
			autoScroll:true,
			width : 400,
			height : 200,
//			x : 10,
//			y : 200,
			plain : true,
			loader : {
				url : "tools.jsp?name=seq&id="+currentNodeID,
				scripts : true,
				autoLoad : true,
				renderer : 'html'
			},
			layout : 'fit',
		//items: attributeForm,
		});
toolWin.show();
}
var attribPanel;

function CreateAttributes(attribs)
{
	if(!attribPanel)
	{
		attribPanel = Ext.create('Ext.grid.property.Grid', {        
	    	border: true,
	        hideHeaders : true,
	        listeners://Add listener to adjust column width of first column
	        {
	        	render: function(grid)
	        	{
	        		grid.columns[0].width = 200;//().setColumnWidth(0, 200);
	        	}
	        },
	        editable:true,
	        /*plugins: [
	              Ext.create('Ext.grid.plugin.RowEditing', {
	               	  clicksToEdit: 1
	               	  /*listeners:{afteredit:
	               			//scope:this,
	               			//afteredit: 
	               				function(roweditor, changes, record, rowIndex) 
	               			{
	               		    	//your save logic here - might look something like this:
	               		    	Ext.Ajax.request({
	               		      		url   : record.phantom ? '/users' : '/users/' + record.get('user_id'),
	               		      		method: record.phantom ? 'POST'   : 'PUT',
	               		      		params: changes,
	               		      		success: function() {
	               				        //post-processing here - this might include reloading the grid if there are calculated fields
	               		     		}
	               		    	});
	               				MessageTop.msg("Attribute edited", "Congratulations");
	               			}
	               	  }
	                 })
	                ],//*/
		   	bbar: [
		   	{	   		
		   		text : 'Add attribute',
	            iconCls: 'icon-plus',
		   		//text   : '<table><tr><td align="center"><img src="icons/plus.png" height="20px"></td>'+
				//'<td align="center">&nbsp Add attribute </td></tr></table>',
		   	    handler: function() 
		   	    {
		   	    	Ext.MessageBox.prompt('New Attribute', 'Please enter the name for the new attribute:', AddAttribute);
		   	    }
		   	},
		   	{	   		
		   		text   : 'Save',
		   		iconCls: 'icon-save',
		   	    handler: function() 
		   	    {
		   	    	Ext.Ajax.request({
   		      				url   : "EditAttribute.jsp?id=" + currentNodeID + "&db=" + currentDB,
   		      				type  : 'POST',
   		      				//data  : myAttributeObject,
   		      				params: {json: Ext.encode(myAttributeObject)},
           		      		success: function(result) {
//           		      			myAttributeObject = eval(result.responseText);
           		      			attribPanel.setSource(myAttributeObject);           
           		      			MessageTop.msg("Success!", "Attributes saved");
           		     		}
           		    	});
		   	    }
		   	},
		   	{	   		
		   		text   : 'Tools',
		   		iconCls: 'icon-tools',
		   	    handler: function() 
		   	    {
		   	    	showTools();
		   	    }
		   	},
		   	{	   		
		   		text : 'Insert Node',
	            iconCls: 'icon-plus',
		   		//text   : '<table><tr><td align="center"><img src="icons/plus.png" height="20px"></td>'+
				//'<td align="center">&nbsp Add attribute </td></tr></table>',
		   	    handler: function() 
		   	    {
		   	    	Ext.MessageBox.prompt('Insert Node', 'Please enter the type for the new outgoing node:', AddNode);
		   	    }
		   	}],
	        source: attribs
	    });
	}
	return attribPanel;
}

function ShowChartsForm()
{
	 var win = new Ext.create('Ext.window.Window',{//Window({
	        layout:'fit',
	        height: 300,
            width: 300,
	        closable: true,
	        resizable: true,
	        autoScroll:true,
	        id:'tool-win',
//	        plain: true,
	        title:'Tools',
//	        border: false,	        
	        modal:'true',
	        //items: [login]
	        loader:{url:"tools.jsp?name=charts&id="+currentNodeID, scripts:true, autoLoad:true, renderer:'html'}
		});
	 	//win.load({url:"http://slashdot.org", scripts:true, autoLoad:true, renderer:'html'});
		win.center();
		win.show();
	/*
	var msgContent = 'Which chart do you want to draw?<br><br>';
	msgContent += '<form name="chartsForm"> <input type="checkbox" name="lengthDistribution"/> Peptides length distribution<br>';
	msgContent += '<input type="checkbox" name="volcanoplot"/> Volcano plot<br>';
	Ext.Msg.show({
		width:300,
		title: 'Charts form',
		msg: msgContent,
		buttons: Ext.Msg.OKCANCEL,
		fn: function(btn){
			if (btn=='ok'){
				if (document.chartsForm.lengthDistribution.value == 'on'){
					//get information from DB and draw peptides length graph
					fetchPeptidesLength(drawPeptidesLength);
				}
			}
		}
	});//*/
}	 	 

function CreateViewport()
{
	return Ext.create('Ext.container.Viewport', {
	//return Ext.create('Ext.window.Window', {
	id: 'MainContainer',
    layout: {
        align: 'stretch',
        type: 'vbox'
    },
	border: false,
	renderTo: Ext.Element.get('#navigationID'),
    //renderTo: Ext.getBody(),
    items: [    {
                    xtype: 'panel',
                    layout: {
                        align: 'stretch',
                        type: 'hbox'
                    },
                    margins: '0 0 0 0',
                    collapseDirection: 'top',
                    collapsible: true,
                    frameHeader: false,
                    hideCollapseTool: false,
                    preventHeader: false,
                	border: false,
                    title: '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Immuno Graph :: ' + browserHistory,
                    flex: 1,
                    items: [
                        {
                        	id: 'navigationPanel',
                            xtype: 'panel',
                            minHeight: 100,
                            minWidth: 100,
                            layout: 'fit',
                            collapseDirection: 'left',
                            collapsible: true,
                        	border: false,
                            frameHeader: false,
                            preventHeader: true,
                            //title: '<span style="cursor:help" title="Navigation" onclick=showHelp()>Navigation</span>',
                            //iconCls:'icon-help',
                            //{
                		   	//	text : 'Navigation',
                	        //    iconCls: 'icon-help',
                		   		//text   : '<table><tr><td align="center"><img src="icons/plus.png" height="20px"></td>'+
                				//'<td align="center">&nbsp Add attribute </td></tr></table>',
                		   //	    handler: function() 
                		   //	    {
                		   //	    	showHelp();
                		   //	    }},
                            	
                            	   //'Navigation',//<table><tr><td align="center">Navigation</td><td align="center"><button type="button" style="background:none;border:none" onclick="showHelp()">'+
                            	   //'<img src="icons/help.png" height="11px"></button></td>'+
            					   //'</tr></table>',
                            floatable: false,
                            margins: '0 0 0 0',
                            flex: 0.4,
                            items:
                            [{
                                xtype: 'panel',  
                                minHeight: 100,
                                minWidth: 100,
                                layout: 'fit',       
                            	border: true,
                                preventHeader: true,
                                listeners: {'resize': function () { ResizeNavPanel(); } },
                                id: 'idNavigation',
                            	html: "<div id='navigationID'></div>"
                            	//autoEl: {tag: 'div', id:'navigationID'}
                            	//loader: 
                            	//{
	                            //    url: 'createNav.jsp?id='+currentNodeID,
                                //	contentType: 'html',
                                //	autoLoad: true,
                                //	scripts: true,
                                //	loadMask: true
                            	//},
                            }]
                        },
                        {
                            xtype: 'splitter'
                        },//*/
                        {
                            xtype: 'container',
                            layout: {
                                align: 'stretch',
                                type: 'vbox'
                            },
                            margins: '0 0 0 0',
                            flex: 1,
                        	border: false,
                            items: [
                                {
                                    xtype: 'container',
                                    //height: 200,
                                    layout: {
                                        align: 'stretch',
                                        type: 'hbox'
                                    },
                                	border: false,
                                    margins: '0 0 0 0',
                                    flex: 1,
                                    items: [
                                        {
                                            xtype: 'panel',
                                            title: 'Attributes [' + currentNodeType + ']',
                                            margins: '0 0 0 0',
                                            flex: 1.5,
                                            layout: 'fit',
                                        	border: false,
                                            id : 'idAttributes',
                                            items: [CreateAttributes(myAttributeObject)]
                                        },
                                        {
                                            xtype: 'splitter'
                                        },
                                        {
                                            xtype: 'panel',//panel',
                                            collapseDirection: 'right',
                                            collapsible: true,
                                            title: 'Comments',
                                        	border: false,
                                            margins: '0 0 0 0',
                                            flex: 1,
                                            id: 'idComments',
                                            layout: 'fit',
                                            items: [CreateComments(myCommentData)]
                                        }//*/
                                    ]
                                },
                                {
                                    xtype: 'splitter'
                                },
                                {
                                    xtype: 'panel',
                                    layout: 'card',
                                    collapseDirection: 'bottom',
                                    collapsible: true,
                                    margins: '0 0 0 0',
                                    flex: 1,
                                    id: 'idGraphs',                                                               
                                    border: false,
                                    preventHeader: true,
                                    bbar:[
                                          {
                                              id: 'idShowChartsForm',
                                              iconCls: 'icon-barchart',
                                              text: 'Charts',
                                              handler: function(btn) {
                                            	  ShowChartsForm();                                              
                                                  //navigate(btn.up("panel"), "prev");
                                              }
                                              //disabled: true
                                          },
                                          {
                                              text: 'Save Chart',
                                              handler: function() {
                                                  Ext.MessageBox.confirm('Confirm Download', 'Would you like to download the chart as an image?', function(choice){
                                                      if(choice == 'yes'){
                                                          charts[graphItemNumber-1].save({
                                                              type: 'image/png'
                                                          });
                                                      }
                                                  });
                                              }
                                          },
                                          '->', // greedy spacer so that the buttons are aligned to each side
                                          {
                                       	   xtype:'text',
                                       	   text:graphItemNumber+'/'+charts.length, 
                                       	   id:'graphItemNumber'
                                          },
                                          '->', // greedy spacer so that the buttons are aligned to each side

                                          {
                                        	  id: 'move-prev',
                                        	  text: 'Back',
                                        	  handler: function(btn) {
                                            	  navigate(btn.up("panel"), "prev");
                                        	  },
                                    	      disabled: true
                                    	  },
                                          {
                                              id: 'move-next',
                                              text: 'Next',
                                              disabled: (charts.length > 1? false: true),
                                              handler: function(btn) {
                                                  navigate(btn.up("panel"), "next");
                                              }
                                          }
                                          ],
                                    /*bbar: [
                                           {
                                               id: 'move-prev',
                                               text: 'Back',
                                               handler: function(btn) {
                                                   navigate(btn.up("panel"), "prev");
                                               },
                                               disabled: true
                                           },
                                           '->',
                                           {
                                        	   xtype:'text',
                                        	   text:graphItemNumber+'/'+charts.length, 
                                        	   id:'graphItemNumber'
                                           },
                                           '->', // greedy spacer so that the buttons are aligned to each side
                                           {
                                               id: 'move-next',
                                               text: 'Next',
                                               disabled: (charts.length > 1? false: true),
                                               handler: function(btn) {
                                                   navigate(btn.up("panel"), "next");
                                               }
                                           }
                                       ],//*/
                                    items: charts
                                }
                            ]
                        }
                    ]
                },
                {
                    xtype: 'splitter'
                },
                {
                    xtype: 'container',
                    animCollapse: false,
                    collapsed: false,
                    //collapsible: false,
                    //collapseDirection: 'top',
                    title: 'List',
                	border: false,
                    loadMask: true,
                    margins: '0 0 0 0',
                    flex: 1,
                    layout: {
                        align: 'stretch',
                        type: 'hbox'
                    },
                    id: 'idGrid',
                    items: Grid
                }
            ]
        });
}
//dynamicPanel = new Ext.Component({
//    loader: {
//       url: 'url_containing_scripts.htm',
//       renderer: 'html',
//       autoLoad: true,
//       scripts: true
//       }
//    });
//Ext.getCmp('specific_panel_id').add(dynamicPanel);  

// This is assuming that the TabPanel is defined as a global variable 'myTabPanel'
function setActiveTabByTitle( tabTitle ) 
{
	var tabPane = Ext.getCmp('tabPanelGrid');
	for(tab in tabPane.items.items)
		if(tabPane.items.items[tab].title == tabTitle)
			tabPane.setActiveTab( Number(tab) );
	//var tabs = tabPane.find( 'title', tabTitle );
	//tabPane.setActiveTab( tabs[ 0 ] );
}

function OnNodeClick(node)
{
	if(node && node.type)//.relationIndex >= 0)
	{
		setActiveTabByTitle( node.type );
        //Ext.getCmp('tabPanelGrid').setActiveTab(node.relationIndex);
	
		MessageTop.msg("Node clicked", node.name + "<br> Showing relation " + node.relation);
	}
}

</script>


<body>

<div id='winB-div'>
	
</div>
<script type="text/javascript">
	//$('#gearGroup').on('click', ShowTools );
	
    var OpenedWindow;
    //Pop up window function with site content
    function PopOut(nextFct) {
        if (OpenedWindow && OpenedWindow != null) {
            $("#msg-divC").animate({ top: "-602px" }, 200, function () {
                $(OpenedWindow).hide(0, "linear", nextFct);
            	//OpenedWindow = null;
                //			OpenedWindow = undefined;
            });
        }
        else
            nextFct();
    }

    var currentWidth;
    var winWidth;
    function resizeWindow(theDiv) {
        currentWidth = $("#winB-div").width();
        var lastWinWidth = $("#" + theDiv).width() + 10;
        if (lastWinWidth != winWidth) {
            winWidth = lastWinWidth;
            var position = currentWidth - winWidth - 10;
            //$("#msg-divB").css({ left: position + "px", width: winWidth + "px", top: "-1602px" });
            $("#msg-divC").css({ left: "20px", top: "-1602px" });
        }
    }
    
    function PopUp(theDiv) {
        PopOut(function () {
            resizeWindow(theDiv);
            //$("#msg-divB").css({ left: "10px", width: "100%", top: "-1602px" });

            OpenedWindow = "#" + theDiv;
            $(OpenedWindow).show(0, "linear", function () {
                $("#msg-divC").animate({ top: "20px" }, 1024);
            });
        });
    }

    //empty callback function. Could be used to know when the message window is hidden
    function WindowHiddenCallback() { };

    //hides currently displayed message window
    function HideWindow() {
        PopOut(WindowHiddenCallback);
    }

    //Function called when a window needs to be shown. The Div param is the content to be shown
    function OpenWindow(theDiv) {
        if (theDiv)// && OpenedWindow != "#" + theDiv) 
        {
            $("#msg-divC").clearQueue();
            PopUp(theDiv);
        }
    }

    function isCanvasSupported() {
        var elem = document.createElement('canvas');
        return !!(elem.getContext && elem.getContext('2d'));
    }

    function DisplaySources(sources) {

    	$("#sources").empty();
        // render the sources with the given options 
        var arrayLength = sources.length;
        for (var i = 0; i < arrayLength; i++) {
        	$("#sources").append(sources[i] + "<BR/>");
		}
        OpenWindow("sources");
    }//*/

    function DisplaySpectrum(spectrum) {

    	$("#spectrum").empty();
        // render the spectrum with the given options 
        $("#spectrum").specview({ sequence: spectrum.Sequence,
            scanNum: spectrum.ScanNumber,
            charge: spectrum.PrecursorCharge,
            precursorMz: spectrum.PrecursorMZ,
            fileName: spectrum.Source,
            staticMods: spectrum.staticMods,
            variableMods: spectrum.variableMods,
            ntermMod: spectrum.ntermMod,
            ctermMod: spectrum.ctermMod,
            peaks: spectrum.Peaks
        });

        OpenWindow("spectrum");
    }//*/

</script>


<div id="msg-divC" class="msg" style="position:absolute; top:-600px;">
    
            <div id="spectrum" class="win" style="display:none;position:relative;margin:4px;"></div>
            <div id="sources" class="win" style="display:none;position:relative;"></div>
            <div id="hideWindow"><span onclick="HideWindow(); return false;"> --- hide --- </span></div>
    
</div>

<div id="console-msg-div">
  <div class="msg" style="">
    <div id="msgWin" class="win" style="">
	<div id='console-div'></div>
	<div id="hideConsole"><span onclick="CloseConsole(); return false;" style="float:right;"> -^- Console -^- &nbsp;&nbsp;&nbsp;&nbsp;</span></div>
    </div>
  </div>
</div>

    <div id="code_hierarchy_legend">&nbsp;</div>
    <div id="code_hierarchy">&nbsp;</div>

<div id="openConsole"><span onclick="OpenConsole(); return false;" style="float:right;"> -v- Console -v- &nbsp;&nbsp;&nbsp;&nbsp;</span></div>

<script type='text/javascript'>    

var trinityConn = {};

function retryTrinityConnection() {
    if (trinityConn.readyState === undefined || trinityConn.readyState > 1){
    	openTrinityConnection();        
        setInterval(retryTrinityConnection, 10000);
    }
}

function logUser(theUser){
    var dataToSend = { Type: "Register", Name: theUser }; //Register
    trinityConn.send(JSON.stringify(dataToSend));        
}

function getQueryParams(qs) {
    qs = qs.split("+").join(" ");

    var params = {}, tokens,
        re = /[?&]?([^=]+)=([^&]*)/g;

    while (tokens = re.exec(qs)) {
        params[decodeURIComponent(tokens[1])]
            = decodeURIComponent(tokens[2]);
    }

    return params;
}

function SendRequest( command,  arrayOfParam){
	if(myAttributeObject && myAttributeObject.Sequence)
			arrayOfParam.push(myAttributeObject.Sequence);
	if(trinityConn.readyState == trinityConn.OPEN)
		trinityConn.send(JSON.stringify({ Type : command, Data : arrayOfParam}));
	else
		MessageTop.msg("PeptidAce Server is offline", "Could not run command");    	
}

function RequestSpectrum( theSource,  theScan,  theSequence){
	if(trinityConn.readyState == trinityConn.OPEN)
	    trinityConn.send(JSON.stringify({ Type : "ShowSpectrum", Source : theSource, Scan : theScan, Sequence : theSequence}));    
	else
		MessageTop.msg("PeptidAce Server is offline", "Could not run command");   	
}

function CheckQueryParam()
{
	query = getQueryParams(document.location.search);
	if(query.source && query.scan)
		if(query.sequence)
			RequestSpectrum(query.source, query.scan, query.sequence);
		else
			RequestSpectrum(query.source, query.scan);
}

function openTrinityConnection() {
    // uses global 'conn' object
    if (trinityConn.readyState === undefined || trinityConn.readyState > 1) {
    	trinityConn = new WebSocket('ws://localhost:8181');
    	
    	trinityConn.onopen = function () {
//    		alert("Connected");
			//logUser("admin");
        };

        trinityConn.onmessage = function (event) {
            var responseData = JSON.parse(event.data);
            if (responseData.Type) {
                if (responseData.Type == 'Data' && responseData.Data)
                    DisplayData(responseData.Data);

                if(responseData.Type == 'Register')
                	logUser("admin");                	

                if(responseData.Type == 'Connection'){
                	//SendRequest();                    	
                }
                
                if (responseData.Message)
                    Terminal.echo(responseData.Message);

             	if(responseData.Type == "AnnotatedSpectrum")
                 	DisplaySpectrum(responseData.Data);
             	if(responseData.Type == "ListSources")
                 	DisplaySources(responseData.Data);                    
            }
        };

        trinityConn.onerror = function (event) {
            var responseData;
            if(event.data)
            	responseData = JSON.parse(event.data);
            if (responseData && responseData.Message)
                Terminal.echo(responseData.Message);
            else
                Terminal.echo("Web Socket Error");
        };

        trinityConn.onclose = function (event) {
            var responseData;
            if (event.data)
            	responseData = JSON.parse(event.data);
            if (responseData && responseData.Message)
                Terminal.echo(responseData.Message);
            else
                Terminal.echo("Web Socket Closed");
            userLoged = 0;
            setInterval(retryTrinityConnection, 3000);
        };
    }
}

OpenConsole();
	
    Ext.onReady(function() {
    	viewport = CreateViewport();
    	
    	CreateGraph(dataObject, "navigationID", OnNodeClick);    	
    });
    
    $(document).ready(function () {   
    	window.WebSocket = window.WebSocket || window.MozWebSocket;

    	retryTrinityConnection();

    	CheckQueryParam();
    	
    	CloseConsole();
    });//*/
</script>
</body>

</html>
