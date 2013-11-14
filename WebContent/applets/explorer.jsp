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

    <script type="text/javascript" src="js/d3/d3.v2.js" charset="utf-8"></script>
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
 				url   : "AddNode.jsp?id=" + currentNodeID,
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
   		      				url   : "EditAttribute.jsp?id=" + currentNodeID,
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
<div id="gear" style="position:absolute;left:-96px;top:-72px;">
<svg id="gearsvg" width="192" height="144" xmlns="http://www.w3.org/2000/svg">
 <title>gear</title>
 <defs>
  <filter id="svg_7_blur">
   <feGaussianBlur stdDeviation="1.4" in="SourceGraphic"/>
  </filter>
 </defs>
 <metadata id="metadata7">image/svg+xml</metadata>
 <g id="gearGroup" transform="scale(0.3)">
  <title>Layer 1</title>
  <g filter="url(#svg_7_blur)" opacity="0.5" id="svg_7">
 <animateTransform attributeName="transform" attributeType="XML" type="rotate"
	from="0, 325, 258" to="360, 325, 258"
	begin="0s" dur="24s"
	repeatCount="indefinite"/>
   <g id="svg_8">
    <path id="svg_9" stroke="#000000" fill="#5e5c5c" fill-rule="nonzero" stroke-width="0" stroke-linecap="round" marker-start="none" marker-mid="none" marker-end="none" stroke-miterlimit="4" stroke-dashoffset="0" d="m196.28125,117.07272l16.4375,45.1875c-0.03551,0.03839 -0.05829,0.08658 -0.09375,0.125l0.125,0.375c-6.91243,7.53391 -13.13052,15.84741 -18.5,24.90625l-49.5,-1.34375c-0.98158,2.22409 -1.98515,4.44559 -2.875,6.6875c-1.21228,3.05432 -2.33096,6.10504 -3.375,9.1875c-1.04367,3.08258 -2.02916,6.20715 -2.90625,9.3125c-0.78568,2.7821 -1.47246,5.5499 -2.125,8.34375l40.5,27.09375c-0.04924,0.44421 -0.0174,0.89896 -0.0625,1.34375l0.28125,0.1875c-0.4657,4.72357 -0.62151,9.44803 -0.625,14.15625l88.9375,0c0.01782,-2.83725 0.25076,-5.67804 0.65625,-8.46875c0.40546,-2.79071 1.00079,-5.54474 1.78125,-8.25c0.78046,-2.70526 1.73221,-5.35654 2.875,-7.9375c1.14279,-2.58096 2.47629,-5.08221 3.96875,-7.5c1.49246,-2.41779 3.13928,-4.75302 4.96875,-6.96875c1.82947,-2.21573 3.84616,-4.30646 6,-6.28125c2.15384,-1.97476 4.4407,-3.83627 6.90625,-5.53125c2.46555,-1.69495 5.11041,-3.24875 7.875,-4.625c1.9729,-0.98215 3.94766,-1.82794 5.96875,-2.59375c2.02109,-0.76581 4.07019,-1.44589 6.125,-2c2.05481,-0.55411 4.11346,-0.99677 6.1875,-1.34375c0.97446,-0.16302 1.96115,-0.22571 2.9375,-0.34375c0.33383,-0.04297 0.66531,-0.08713 1,-0.125c0.76926,-0.08099 1.54321,-0.22778 2.3125,-0.28125c0.75201,-0.05225 1.49866,-0.0051 2.25,-0.03125c0.85345,-0.03687 1.70621,-0.05905 2.5625,-0.0625c0.46866,0.00208 0.93835,-0.04333 1.40625,-0.03125c0.34445,0.00891 0.68732,0.04819 1.03125,0.0625c1.71768,0.05716 3.43723,0.21198 5.15625,0.40625c7.37845,0.83383 14.74649,2.85727 21.75,6.34375c22.11658,11.01007 34.82608,32.86462 34.96875,55.5625l89.03122,0c-0.00098,-4.72623 -0.21802,-9.47733 -0.6875,-14.21875l41.00003,-27.4375c-0.01196,-0.05289 -0.05042,-0.10336 -0.0625,-0.15625c-0.71216,-3.12265 -1.49805,-6.23837 -2.375,-9.34375c-0.87695,-3.10535 -1.8313,-6.19867 -2.875,-9.28125c-1.0437,-3.08258 -2.16272,-6.13318 -3.375,-9.1875c-0.88013,-2.21738 -1.84045,-4.42917 -2.8125,-6.625l-49.125,1.34375c-0.32849,-0.55521 -0.72672,-1.07364 -1.0625,-1.625l-0.3125,0c-2.40787,-3.95306 -4.96716,-7.77524 -7.6875,-11.4375c-2.72034,-3.66226 -5.58698,-7.16986 -8.59375,-10.53125l16.6875,-45.8125c-1.45001,-1.26461 -2.89124,-2.53091 -4.375,-3.75c-2.46719,-2.02713 -4.97525,-4.00642 -7.53125,-5.90625c-2.55603,-1.89984 -5.17328,-3.72924 -7.8125,-5.5c-2.63925,-1.77075 -5.31439,-3.48508 -8.03125,-5.125c-0.77728,-0.46918 -1.55521,-0.92767 -2.34375,-1.375l-39,29.34375c-0.56766,-0.2489 -1.14954,-0.4147 -1.71875,-0.65625l-0.09375,0.0625c-4.30518,-1.8309 -8.70319,-3.43737 -13.15625,-4.875c-4.45306,-1.43762 -8.95871,-2.68002 -13.53125,-3.71875l-0.0625,-0.15625c-0.02219,-0.00494 -0.04034,-0.02631 -0.0625,-0.03125l-14.03125,-46.56251c-1.97339,-0.20361 -3.92493,-0.44845 -5.90625,-0.59374c-3.18457,-0.23352 -6.39328,-0.3544 -9.59375,-0.4375c-2.14056,-0.05557 -4.28888,-0.0383 -6.4375,-0.03125c-1.07559,0.01142 -2.14496,-0.02786 -3.21875,0c-3.20038,0.0831 -6.37793,0.23523 -9.5625,0.46875c-1.01263,0.07422 -2.02094,0.22301 -3.03125,0.31249l-14,46.37501c-10.15869,2.09684 -20.0712,5.18036 -29.59375,9.21875l-39.375,-29.59375c-1.31567,0.75378 -2.63878,1.46593 -3.9375,2.25c-2.71692,1.6399 -5.39172,3.35434 -8.03125,5.125c-2.63927,1.77079 -5.25653,3.60013 -7.8125,5.5c-2.55606,1.8998 -5.06396,3.87912 -7.53125,5.90625c-0.98041,0.80563 -1.91158,1.67136 -2.875,2.5zm181.78125,39.28125c1.3598,0.09421 2.74118,0.45154 4.03125,1.09375c5.16028,2.56891 7.22305,8.77075 4.59375,13.8125c-2.62933,5.04172 -8.96472,7.03766 -14.125,4.46875c-5.16028,-2.56889 -7.22308,-8.7395 -4.59375,-13.78125c1.97195,-3.78131 6.01437,-5.87637 10.09375,-5.59375zm-148.875,47.28125c1.35977,0.09421 2.74118,0.45154 4.03125,1.09375c5.16037,2.56894 7.22308,8.73956 4.59375,13.78125c-2.62941,5.04172 -8.96469,7.03766 -14.125,4.46875c-5.16031,-2.56888 -7.22314,-8.73953 -4.59375,-13.78125c1.97203,-3.78128 6.0144,-5.84512 10.09375,-5.5625z"/>
    <path id="svg_10" stroke="#000000" fill="#5e5c5c" fill-rule="nonzero" stroke-width="0" stroke-linecap="round" marker-start="none" marker-mid="none" marker-end="none" stroke-miterlimit="4" stroke-dashoffset="0" d="m457.71875,406.92731l-16.4375,-45.1875c0.03549,-0.03845 0.05829,-0.08661 0.09375,-0.125l-0.125,-0.37506c6.91241,-7.53387 13.13052,-15.84741 18.5,-24.90619l49.5,1.34375c0.98157,-2.22418 1.98511,-4.44568 2.875,-6.6875c1.21228,-3.05432 2.33093,-6.1051 3.375,-9.18756c1.0437,-3.08258 2.02917,-6.20718 2.90625,-9.31244c0.78564,-2.78217 1.47241,-5.5499 2.125,-8.34381l-40.50003,-27.09369c0.04926,-0.44424 0.01746,-0.89899 0.0625,-1.34378l-0.28125,-0.1875c0.4657,-4.72357 0.62152,-9.44806 0.625,-14.15625l-88.93747,0c-0.01782,2.83725 -0.25079,5.67804 -0.65625,8.46875c-0.40549,2.79068 -1.00079,5.54471 -1.78125,8.24997c-0.78046,2.70526 -1.73221,5.35654 -2.875,7.93756c-1.14279,2.5809 -2.47629,5.08215 -3.96875,7.49994c-1.49246,2.41782 -3.13928,4.75305 -4.96875,6.96881c-1.82947,2.21564 -3.84616,4.3064 -6,6.28119c-2.15384,1.97476 -4.4407,3.83633 -6.90625,5.53131c-2.46555,1.69489 -5.11041,3.24866 -7.875,4.625c-1.9729,0.98206 -3.94766,1.82788 -5.96875,2.59369c-2.02109,0.76587 -4.07019,1.44589 -6.125,2c-2.05481,0.55414 -4.11346,0.99677 -6.1875,1.34381c-0.97446,0.16302 -1.96115,0.22565 -2.9375,0.34369c-0.33383,0.04297 -0.66531,0.08722 -1,0.12506c-0.76929,0.08093 -1.54321,0.22772 -2.3125,0.28125c-0.75201,0.05225 -1.49866,0.005 -2.25,0.03125c-0.85345,0.0368 -1.70621,0.05896 -2.5625,0.0625c-0.46866,-0.00214 -0.93835,0.04327 -1.40625,0.03125c-0.34445,-0.00897 -0.68732,-0.04828 -1.03125,-0.0625c-1.71768,-0.05725 -3.43723,-0.21204 -5.15625,-0.40625c-7.37845,-0.83392 -14.74649,-2.85733 -21.75,-6.34375c-22.11658,-11.01007 -34.82608,-32.86462 -34.96875,-55.56253l-89.03125,0c0.00101,4.7262 0.21806,9.47729 0.6875,14.21875l-41,27.43753c0.01202,0.05286 0.05045,0.10336 0.0625,0.15625c0.71211,3.12262 1.49802,6.23834 2.375,9.34369c0.877,3.10532 1.83127,6.19867 2.875,9.28125c1.04373,3.08258 2.16275,6.13324 3.375,9.18756c0.88008,2.21735 1.84045,4.42914 2.8125,6.625l49.125,-1.34375c0.32849,0.55511 0.72672,1.07361 1.0625,1.62494l0.3125,0c2.40785,3.95306 4.96716,7.77521 7.6875,11.43756c2.72032,3.6622 5.58696,7.16986 8.59375,10.53125l-16.6875,45.8125c1.45001,1.26459 2.89125,2.53088 4.375,3.75c2.46719,2.02704 4.97525,4.00635 7.53125,5.90613c2.55606,1.8999 5.17326,3.72931 7.8125,5.50006c2.63925,1.77075 5.31439,3.48505 8.03125,5.125c0.77728,0.46918 1.55518,0.92767 2.34375,1.37494l39,-29.34363c0.56766,0.24887 1.14954,0.41473 1.71875,0.65613l0.09375,-0.0625c4.30518,1.83093 8.70319,3.4375 13.15625,4.875c4.45306,1.43762 8.95871,2.68011 13.53125,3.71887l0.0625,0.15613c0.02216,0.00504 0.04031,0.02631 0.0625,0.03137l14.03125,46.5625c1.97339,0.20355 3.9249,0.44836 5.90625,0.59363c3.18457,0.2337 6.39328,0.35443 9.59375,0.43756c2.14056,0.05554 4.28888,0.03827 6.4375,0.03131c1.07559,-0.01147 2.14496,0.02783 3.21875,0c3.20038,-0.08313 6.37793,-0.23535 9.5625,-0.46887c1.01263,-0.07416 2.0209,-0.22296 3.03125,-0.3125l14,-46.37494c10.15869,-2.09686 20.0712,-5.1803 29.59375,-9.21869l39.375,29.59363c1.31567,-0.75366 2.63876,-1.46588 3.9375,-2.24994c2.71692,-1.63995 5.39172,-3.35431 8.03125,-5.125c2.63928,-1.77075 5.25653,-3.60016 7.8125,-5.50006c2.55606,-1.89978 5.06396,-3.87909 7.53125,-5.90613c0.98041,-0.80573 1.91156,-1.67145 2.875,-2.5zm-181.78125,-39.28137c-1.3598,-0.09418 -2.74118,-0.45148 -4.03125,-1.09369c-5.16028,-2.56885 -7.22305,-8.77081 -4.59375,-13.81244c2.6293,-5.04175 8.96472,-7.03772 14.125,-4.46875c5.16028,2.56885 7.22305,8.73956 4.59375,13.78125c-1.97198,3.78131 -6.0144,5.8764 -10.09375,5.59363zm148.875,-47.28113c-1.35977,-0.09424 -2.74118,-0.4516 -4.03125,-1.09375c-5.16037,-2.56897 -7.22308,-8.73962 -4.59375,-13.78125c2.62939,-5.04175 8.96469,-7.03772 14.125,-4.46875c5.16031,2.56882 7.22314,8.73944 4.59375,13.78119c-1.97202,3.78131 -6.01443,5.84518 -10.09375,5.56256z"/>
   </g>
   <path id="svg_11" stroke="#000000" fill="#5e5c5c" fill-rule="nonzero" stroke-width="0" stroke-linejoin="round" stroke-miterlimit="4" stroke-dashoffset="0" d="m327.20111,167.69968c-51.38983,0 -93.33093,41.89944 -93.33093,93.28928c0,51.3898 41.9411,93.33093 93.33093,93.33093c51.38986,0 93.28928,-41.94113 93.28928,-93.33093c0,-51.38983 -41.89941,-93.28928 -93.28928,-93.28928zm0,21.30061c39.86197,0 71.98865,32.12669 71.98865,71.98866c0,39.86194 -32.12668,72.03033 -71.98865,72.03033c-39.86194,0 -72.0303,-32.1684 -72.0303,-72.03033c0,-39.86197 32.16837,-71.98866 72.0303,-71.98866z"/>
   <path id="svg_12" stroke="#000000" fill="#5e5c5c" fill-rule="nonzero" stroke-width="0" stroke-linejoin="round" stroke-miterlimit="4" stroke-dashoffset="0" d="m327.20074,170.82602c-49.68298,0 -90.16299,40.479 -90.16299,90.16302c0,49.68399 40.48001,90.16299 90.16299,90.16299c49.68402,0 90.12201,-40.479 90.12201,-90.16299c0,-49.68402 -40.43799,-90.16302 -90.12201,-90.16302zm0,15.00601c41.56802,0 75.15701,33.589 75.15701,75.15701c0,41.56802 -33.58899,75.15695 -75.15701,75.15695c-41.56799,0 -75.15601,-33.58893 -75.15601,-75.15695c0,-41.56801 33.58801,-75.15701 75.15601,-75.15701z"/>
  </g>
  <g id="layer1">
 <animateTransform attributeName="transform" attributeType="XML" type="rotate"
	from="0, 320, 240" to="360, 320, 240"
	begin="0s" dur="24s"
	repeatCount="indefinite"/>
   <g id="g2290">
    <path stroke="#000000" fill="#050202" fill-rule="nonzero" stroke-width="0" stroke-linecap="round" marker-start="none" marker-mid="none" marker-end="none" stroke-miterlimit="4" stroke-dashoffset="0" d="m191.28125,99.07272l16.4375,45.1875c-0.03551,0.03839 -0.05829,0.08658 -0.09375,0.125l0.125,0.375c-6.91243,7.53391 -13.13052,15.84741 -18.5,24.90625l-49.5,-1.34375c-0.98158,2.22409 -1.98515,4.44559 -2.875,6.6875c-1.21228,3.05432 -2.33096,6.10504 -3.375,9.1875c-1.04366,3.08258 -2.02916,6.20715 -2.90625,9.3125c-0.78568,2.7821 -1.47246,5.5499 -2.125,8.34375l40.5,27.09375c-0.04924,0.44421 -0.0174,0.89896 -0.0625,1.34375l0.28125,0.1875c-0.4657,4.72357 -0.62151,9.44803 -0.625,14.15625l88.9375,0c0.01782,-2.83725 0.25076,-5.67804 0.65625,-8.46875c0.40546,-2.79071 1.00079,-5.54474 1.78125,-8.25c0.78046,-2.70526 1.73221,-5.35654 2.875,-7.9375c1.14279,-2.58096 2.47629,-5.08221 3.96875,-7.5c1.49246,-2.41779 3.13928,-4.75302 4.96875,-6.96875c1.82947,-2.21573 3.84616,-4.30646 6,-6.28125c2.15384,-1.97476 4.4407,-3.83627 6.90625,-5.53125c2.46555,-1.69495 5.11041,-3.24875 7.875,-4.625c1.9729,-0.98215 3.94766,-1.82794 5.96875,-2.59375c2.02109,-0.76581 4.07019,-1.44589 6.125,-2c2.05481,-0.55411 4.11346,-0.99677 6.1875,-1.34375c0.97446,-0.16302 1.96115,-0.22571 2.9375,-0.34375c0.33383,-0.04297 0.66531,-0.08713 1,-0.125c0.76926,-0.08099 1.54321,-0.22778 2.3125,-0.28125c0.75201,-0.05225 1.49866,-0.0051 2.25,-0.03125c0.85345,-0.03687 1.70621,-0.05905 2.5625,-0.0625c0.46866,0.00208 0.93835,-0.04333 1.40625,-0.03125c0.34445,0.00891 0.68732,0.04819 1.03125,0.0625c1.71768,0.05716 3.43723,0.21198 5.15625,0.40625c7.37845,0.83383 14.74649,2.85727 21.75,6.34375c22.11658,11.01007 34.82608,32.86462 34.96875,55.5625l89.03122,0c-0.00098,-4.72623 -0.21802,-9.47733 -0.6875,-14.21875l41.00003,-27.4375c-0.01196,-0.05289 -0.05042,-0.10336 -0.0625,-0.15625c-0.71216,-3.12265 -1.49805,-6.23837 -2.375,-9.34375c-0.87695,-3.10535 -1.83127,-6.19867 -2.87503,-9.28125c-1.0437,-3.08258 -2.16272,-6.13318 -3.375,-9.1875c-0.88007,-2.21738 -1.84045,-4.42917 -2.8125,-6.625l-49.12497,1.34375c-0.32849,-0.55521 -0.72672,-1.07364 -1.0625,-1.625l-0.3125,0c-2.40787,-3.95306 -4.96716,-7.77524 -7.6875,-11.4375c-2.72034,-3.66226 -5.58698,-7.16986 -8.59375,-10.53125l16.6875,-45.8125c-1.45001,-1.26462 -2.89124,-2.53091 -4.375,-3.75001c-2.46719,-2.02712 -4.97525,-4.00641 -7.53125,-5.90624c-2.55603,-1.89984 -5.17328,-3.72925 -7.8125,-5.50001c-2.63925,-1.77074 -5.31439,-3.48507 -8.03125,-5.12499c-0.77728,-0.46918 -1.55521,-0.92767 -2.34375,-1.375l-39,29.34375c-0.56766,-0.2489 -1.14954,-0.4147 -1.71875,-0.65625l-0.09375,0.0625c-4.30518,-1.8309 -8.70319,-3.43738 -13.15625,-4.875c-4.45306,-1.43762 -8.95871,-2.68002 -13.53125,-3.71876l-0.0625,-0.15624c-0.02219,-0.00494 -0.04034,-0.0263 -0.0625,-0.03125l-14.03125,-46.5625c-1.97339,-0.20361 -3.92493,-0.44845 -5.90625,-0.59375c-3.18457,-0.23352 -6.39328,-0.3544 -9.59375,-0.4375c-2.14056,-0.05557 -4.28888,-0.0383 -6.4375,-0.03125c-1.07559,0.01142 -2.14496,-0.02786 -3.21875,0c-3.20038,0.0831 -6.37793,0.23523 -9.5625,0.46875c-1.01263,0.07422 -2.02094,0.22302 -3.03125,0.3125l-14,46.375c-10.15869,2.09684 -20.0712,5.18037 -29.59375,9.21876l-39.375,-29.59376c-1.31567,0.75379 -2.63878,1.46594 -3.9375,2.25001c-2.71692,1.63989 -5.39172,3.35434 -8.03125,5.12499c-2.63927,1.77079 -5.25653,3.60014 -7.8125,5.50001c-2.55606,1.8998 -5.06396,3.87912 -7.53125,5.90624c-0.98041,0.80564 -1.91158,1.67136 -2.875,2.50001zm181.78125,39.28125c1.3598,0.09421 2.74118,0.45154 4.03125,1.09375c5.16028,2.56891 7.22305,8.77075 4.59375,13.8125c-2.62933,5.04172 -8.96472,7.03766 -14.125,4.46875c-5.16028,-2.56889 -7.22308,-8.7395 -4.59375,-13.78125c1.97195,-3.78131 6.01437,-5.87637 10.09375,-5.59375zm-148.875,47.28125c1.35977,0.09421 2.74118,0.45154 4.03125,1.09375c5.16037,2.56894 7.22308,8.73956 4.59375,13.78125c-2.62941,5.04172 -8.96469,7.03766 -14.125,4.46875c-5.16031,-2.56888 -7.22314,-8.73953 -4.59375,-13.78125c1.97203,-3.78128 6.0144,-5.84512 10.09375,-5.5625z" id="path4850"/>
    <path stroke="#000000" fill="#050202" fill-rule="nonzero" stroke-width="0" stroke-linecap="round" marker-start="none" marker-mid="none" marker-end="none" stroke-miterlimit="4" stroke-dashoffset="0" d="m452.71875,388.92731l-16.4375,-45.1875c0.03549,-0.03845 0.05829,-0.08661 0.09375,-0.125l-0.125,-0.37506c6.91241,-7.53387 13.13052,-15.84741 18.5,-24.90619l49.49997,1.34375c0.98163,-2.22418 1.98517,-4.44568 2.875,-6.6875c1.21228,-3.05432 2.33099,-6.1051 3.375,-9.18756c1.04373,-3.08258 2.02921,-6.20718 2.90628,-9.31244c0.78564,-2.78217 1.47241,-5.5499 2.125,-8.34381l-40.50003,-27.09369c0.04926,-0.44424 0.01746,-0.89899 0.0625,-1.34378l-0.28125,-0.1875c0.4657,-4.72357 0.62152,-9.44806 0.625,-14.15625l-88.93747,0c-0.01782,2.83725 -0.25079,5.67804 -0.65625,8.46875c-0.40549,2.79068 -1.00079,5.54471 -1.78125,8.24997c-0.78046,2.70526 -1.73221,5.35654 -2.875,7.93756c-1.14279,2.5809 -2.47629,5.08215 -3.96875,7.49994c-1.49246,2.41782 -3.13928,4.75305 -4.96875,6.96881c-1.82947,2.21564 -3.84616,4.3064 -6,6.28119c-2.15384,1.97476 -4.4407,3.83633 -6.90625,5.53131c-2.46555,1.69489 -5.11041,3.24866 -7.875,4.625c-1.9729,0.98206 -3.94766,1.82788 -5.96875,2.59369c-2.02109,0.76587 -4.07019,1.44589 -6.125,2c-2.05481,0.55414 -4.11346,0.99677 -6.1875,1.34381c-0.97446,0.16302 -1.96115,0.22565 -2.9375,0.34369c-0.33383,0.04297 -0.66531,0.08722 -1,0.12506c-0.76929,0.08093 -1.54321,0.22772 -2.3125,0.28125c-0.75201,0.05225 -1.49866,0.005 -2.25,0.03125c-0.85345,0.0368 -1.70621,0.05896 -2.5625,0.0625c-0.46866,-0.00214 -0.93835,0.04327 -1.40625,0.03125c-0.34445,-0.00897 -0.68732,-0.04828 -1.03125,-0.0625c-1.71768,-0.05725 -3.43723,-0.21204 -5.15625,-0.40625c-7.37845,-0.83392 -14.74649,-2.85733 -21.75,-6.34375c-22.11658,-11.01007 -34.82608,-32.86462 -34.96875,-55.56253l-89.03125,0c0.00101,4.7262 0.21806,9.47729 0.6875,14.21875l-41,27.43753c0.01202,0.05286 0.05045,0.10336 0.0625,0.15625c0.71211,3.12262 1.49802,6.23834 2.375,9.34369c0.877,3.10532 1.83127,6.19867 2.875,9.28125c1.04373,3.08258 2.16275,6.13324 3.375,9.18756c0.88008,2.21735 1.84045,4.42914 2.8125,6.625l49.125,-1.34375c0.32849,0.55511 0.72672,1.07361 1.0625,1.62494l0.3125,0c2.40785,3.95306 4.96716,7.77521 7.6875,11.43756c2.72032,3.6622 5.58696,7.16986 8.59375,10.53125l-16.6875,45.8125c1.45001,1.26459 2.89125,2.53088 4.375,3.75c2.46719,2.02704 4.97525,4.00635 7.53125,5.90613c2.55606,1.8999 5.17326,3.72931 7.8125,5.50006c2.63925,1.77075 5.31439,3.48505 8.03125,5.125c0.77728,0.46918 1.55518,0.92767 2.34375,1.37494l39,-29.34363c0.56766,0.24887 1.14954,0.41473 1.71875,0.65613l0.09375,-0.0625c4.30518,1.83093 8.70319,3.4375 13.15625,4.875c4.45306,1.43762 8.95871,2.68011 13.53125,3.71887l0.0625,0.15613c0.02216,0.00504 0.04031,0.02631 0.0625,0.03137l14.03125,46.5625c1.97339,0.20355 3.9249,0.44836 5.90625,0.59363c3.18457,0.2337 6.39328,0.35443 9.59375,0.43756c2.14056,0.05554 4.28888,0.03827 6.4375,0.03131c1.07559,-0.01147 2.14496,0.02783 3.21875,0c3.20038,-0.08313 6.37793,-0.23535 9.5625,-0.46887c1.01263,-0.07416 2.0209,-0.22296 3.03125,-0.3125l14,-46.37494c10.15869,-2.09686 20.0712,-5.1803 29.59375,-9.21869l39.375,29.59363c1.31567,-0.75366 2.63876,-1.46588 3.9375,-2.24994c2.71692,-1.63995 5.39172,-3.35431 8.03125,-5.125c2.63928,-1.77075 5.25653,-3.60016 7.8125,-5.50006c2.55606,-1.89978 5.06396,-3.87909 7.53125,-5.90613c0.98041,-0.80573 1.91156,-1.67145 2.875,-2.5zm-181.78125,-39.28137c-1.3598,-0.09418 -2.74118,-0.45148 -4.03125,-1.09369c-5.16028,-2.56885 -7.22305,-8.77081 -4.59375,-13.81244c2.6293,-5.04175 8.96472,-7.03772 14.125,-4.46875c5.16028,2.56885 7.22305,8.73956 4.59375,13.78125c-1.97198,3.78131 -6.0144,5.8764 -10.09375,5.59363zm148.875,-47.28113c-1.35977,-0.09424 -2.74118,-0.4516 -4.03125,-1.09375c-5.16037,-2.56897 -7.22308,-8.73962 -4.59375,-13.78125c2.62939,-5.04175 8.96469,-7.03772 14.125,-4.46875c5.16031,2.56882 7.22314,8.73944 4.59375,13.78119c-1.97202,3.78131 -6.01443,5.84518 -10.09375,5.56256z" id="path3767"/>
   </g>
   <path stroke="#000000" fill="#050202" fill-rule="nonzero" stroke-width="0" stroke-linejoin="round" stroke-miterlimit="4" stroke-dashoffset="0" id="path2327" d="m322.20111,149.69968c-51.38983,0 -93.33093,41.89944 -93.33093,93.28928c0,51.3898 41.9411,93.33093 93.33093,93.33093c51.38986,0 93.28928,-41.94113 93.28928,-93.33093c0,-51.38983 -41.89941,-93.28928 -93.28928,-93.28928zm0,21.30061c39.86197,0 71.98865,32.12669 71.98865,71.98866c0,39.86194 -32.12668,72.03033 -71.98865,72.03033c-39.86194,0 -72.0303,-32.1684 -72.0303,-72.03033c0,-39.86197 32.16837,-71.98866 72.0303,-71.98866z"/>
   <path stroke="#000000" fill="#050202" fill-rule="nonzero" stroke-width="0" stroke-linejoin="round" stroke-miterlimit="4" stroke-dashoffset="0" id="path3500" d="m322.20074,152.82602c-49.68298,0 -90.16299,40.479 -90.16299,90.16301c0,49.68401 40.48001,90.16301 90.16299,90.16301c49.68402,0 90.12201,-40.479 90.12201,-90.16301c0,-49.68401 -40.43799,-90.16301 -90.12201,-90.16301zm0,15.00601c41.56802,0 75.15701,33.589 75.15701,75.157c0,41.56804 -33.58899,75.15697 -75.15701,75.15697c-41.56799,0 -75.15601,-33.58893 -75.15601,-75.15697c0,-41.56799 33.58801,-75.157 75.15601,-75.157z"/>
  </g>
  <g id="svg_1">
 <animateTransform attributeName="transform" attributeType="XML" type="rotate"
	from="0, 315, 235" to="360, 315, 235"
	begin="0s" dur="24s"
	repeatCount="indefinite"/>
   <g id="svg_2">
    <path id="svg_3" stroke="#000000" fill="#526a6a" fill-rule="nonzero" stroke-width="0" stroke-linecap="round" marker-start="none" marker-mid="none" marker-end="none" stroke-miterlimit="4" stroke-dashoffset="0" d="m183.28125,94.07272l16.4375,45.1875c-0.03551,0.03839 -0.05829,0.08658 -0.09375,0.125l0.125,0.375c-6.91243,7.53391 -13.13052,15.84741 -18.5,24.90625l-49.5,-1.34375c-0.98158,2.22409 -1.98515,4.44559 -2.875,6.6875c-1.21228,3.05432 -2.33096,6.10504 -3.375,9.1875c-1.04366,3.08258 -2.02916,6.20715 -2.90625,9.3125c-0.78568,2.7821 -1.47246,5.5499 -2.125,8.34375l40.5,27.09375c-0.04924,0.44421 -0.0174,0.89896 -0.0625,1.34375l0.28125,0.1875c-0.4657,4.72357 -0.62151,9.44803 -0.625,14.15625l88.9375,0c0.01782,-2.83725 0.25076,-5.67804 0.65625,-8.46875c0.40546,-2.79071 1.00079,-5.54474 1.78125,-8.25c0.78046,-2.70526 1.73221,-5.35654 2.875,-7.9375c1.14279,-2.58096 2.47629,-5.08221 3.96875,-7.5c1.49246,-2.41779 3.13928,-4.75302 4.96875,-6.96875c1.82947,-2.21573 3.84616,-4.30646 6,-6.28125c2.15384,-1.97476 4.4407,-3.83627 6.90625,-5.53125c2.46555,-1.69495 5.11041,-3.24875 7.875,-4.625c1.9729,-0.98215 3.94766,-1.82794 5.96875,-2.59375c2.02109,-0.76581 4.07019,-1.44589 6.125,-2c2.05481,-0.55411 4.11346,-0.99677 6.1875,-1.34375c0.97446,-0.16302 1.96115,-0.22571 2.9375,-0.34375c0.33383,-0.04297 0.66531,-0.08713 1,-0.125c0.76926,-0.08099 1.54321,-0.22778 2.3125,-0.28125c0.75201,-0.05225 1.49866,-0.0051 2.25,-0.03125c0.85345,-0.03687 1.70621,-0.05905 2.5625,-0.0625c0.46866,0.00208 0.93835,-0.04333 1.40625,-0.03125c0.34445,0.00891 0.68732,0.04819 1.03125,0.0625c1.71768,0.05716 3.43723,0.21198 5.15625,0.40625c7.37845,0.83383 14.74649,2.85727 21.75,6.34375c22.11658,11.01007 34.82608,32.86462 34.96875,55.5625l89.03122,0c-0.00098,-4.72623 -0.21802,-9.47733 -0.6875,-14.21875l41.00003,-27.4375c-0.01196,-0.05289 -0.05042,-0.10336 -0.0625,-0.15625c-0.71216,-3.12265 -1.49805,-6.23837 -2.375,-9.34375c-0.87695,-3.10535 -1.8313,-6.19867 -2.875,-9.28125c-1.0437,-3.08258 -2.16272,-6.13318 -3.375,-9.1875c-0.88013,-2.21738 -1.84045,-4.42917 -2.8125,-6.625l-49.125,1.34375c-0.32849,-0.55521 -0.72672,-1.07364 -1.0625,-1.625l-0.3125,0c-2.40787,-3.95306 -4.96716,-7.77524 -7.6875,-11.4375c-2.72034,-3.66226 -5.58698,-7.16986 -8.59375,-10.53125l16.6875,-45.8125c-1.45001,-1.26461 -2.89124,-2.53091 -4.375,-3.75c-2.46719,-2.02713 -4.97525,-4.00642 -7.53125,-5.90625c-2.55603,-1.89984 -5.17328,-3.72924 -7.8125,-5.5c-2.63925,-1.77075 -5.31439,-3.48508 -8.03125,-5.125c-0.77728,-0.46918 -1.55521,-0.92767 -2.34375,-1.375l-39,29.34375c-0.56766,-0.2489 -1.14954,-0.4147 -1.71875,-0.65625l-0.09375,0.0625c-4.30518,-1.8309 -8.70319,-3.43737 -13.15625,-4.875c-4.45306,-1.43762 -8.95871,-2.68002 -13.53125,-3.71875l-0.0625,-0.15625c-0.02219,-0.00494 -0.04034,-0.02631 -0.0625,-0.03125l-14.03125,-46.56251c-1.97339,-0.20361 -3.92493,-0.44845 -5.90625,-0.59374c-3.18457,-0.23352 -6.39328,-0.3544 -9.59375,-0.4375c-2.14056,-0.05557 -4.28888,-0.0383 -6.4375,-0.03125c-1.07559,0.01142 -2.14496,-0.02786 -3.21875,0c-3.20038,0.0831 -6.37793,0.23523 -9.5625,0.46875c-1.01263,0.07422 -2.02094,0.22301 -3.03125,0.31249l-14,46.37501c-10.15869,2.09684 -20.0712,5.18036 -29.59375,9.21875l-39.375,-29.59375c-1.31567,0.75378 -2.63878,1.46593 -3.9375,2.25c-2.71692,1.6399 -5.39172,3.35434 -8.03125,5.125c-2.63927,1.77079 -5.25653,3.60013 -7.8125,5.5c-2.55606,1.8998 -5.06396,3.87912 -7.53125,5.90625c-0.98041,0.80563 -1.91158,1.67136 -2.875,2.5zm181.78125,39.28125c1.3598,0.09421 2.74118,0.45154 4.03125,1.09375c5.16028,2.56891 7.22305,8.77075 4.59375,13.8125c-2.62933,5.04172 -8.96472,7.03766 -14.125,4.46875c-5.16028,-2.56889 -7.22308,-8.7395 -4.59375,-13.78125c1.97195,-3.78131 6.01437,-5.87637 10.09375,-5.59375zm-148.875,47.28125c1.35977,0.09421 2.74118,0.45154 4.03125,1.09375c5.16037,2.56894 7.22308,8.73956 4.59375,13.78125c-2.62941,5.04172 -8.96469,7.03766 -14.125,4.46875c-5.16031,-2.56888 -7.22314,-8.73953 -4.59375,-13.78125c1.97203,-3.78128 6.0144,-5.84512 10.09375,-5.5625z"/>
    <path id="svg_4" stroke="#000000" fill="#526a6a" fill-rule="nonzero" stroke-width="0" stroke-linecap="round" marker-start="none" marker-mid="none" marker-end="none" stroke-miterlimit="4" stroke-dashoffset="0" d="m444.71875,383.92731l-16.4375,-45.1875c0.03549,-0.03845 0.05829,-0.08661 0.09375,-0.125l-0.125,-0.37506c6.91241,-7.53387 13.13052,-15.84741 18.5,-24.90619l49.5,1.34375c0.98157,-2.22418 1.98511,-4.44568 2.875,-6.6875c1.21228,-3.05432 2.33093,-6.1051 3.375,-9.18756c1.0437,-3.08258 2.02917,-6.20718 2.90625,-9.31244c0.78564,-2.78217 1.47241,-5.5499 2.125,-8.34381l-40.50003,-27.09369c0.04926,-0.44424 0.01746,-0.89899 0.0625,-1.34378l-0.28125,-0.1875c0.4657,-4.72357 0.62152,-9.44806 0.625,-14.15625l-88.93747,0c-0.01782,2.83725 -0.25079,5.67804 -0.65625,8.46875c-0.40549,2.79068 -1.00079,5.54471 -1.78125,8.24997c-0.78046,2.70526 -1.73221,5.35654 -2.875,7.93756c-1.14279,2.5809 -2.47629,5.08215 -3.96875,7.49994c-1.49246,2.41782 -3.13928,4.75305 -4.96875,6.96881c-1.82947,2.21564 -3.84616,4.3064 -6,6.28119c-2.15384,1.97476 -4.4407,3.83633 -6.90625,5.53131c-2.46555,1.69489 -5.11041,3.24866 -7.875,4.625c-1.9729,0.98206 -3.94766,1.82788 -5.96875,2.59369c-2.02109,0.76587 -4.07019,1.44589 -6.125,2c-2.05481,0.55414 -4.11346,0.99677 -6.1875,1.34381c-0.97446,0.16302 -1.96115,0.22565 -2.9375,0.34369c-0.33383,0.04297 -0.66531,0.08722 -1,0.12506c-0.76929,0.08093 -1.54321,0.22772 -2.3125,0.28125c-0.75201,0.05225 -1.49866,0.005 -2.25,0.03125c-0.85345,0.0368 -1.70621,0.05896 -2.5625,0.0625c-0.46866,-0.00214 -0.93835,0.04327 -1.40625,0.03125c-0.34445,-0.00897 -0.68732,-0.04828 -1.03125,-0.0625c-1.71768,-0.05725 -3.43723,-0.21204 -5.15625,-0.40625c-7.37845,-0.83392 -14.74649,-2.85733 -21.75,-6.34375c-22.11658,-11.01007 -34.82608,-32.86462 -34.96875,-55.56253l-89.03125,0c0.00101,4.7262 0.21806,9.47729 0.6875,14.21875l-41,27.43753c0.01202,0.05286 0.05045,0.10336 0.0625,0.15625c0.71211,3.12262 1.49802,6.23834 2.375,9.34369c0.877,3.10532 1.83127,6.19867 2.875,9.28125c1.04373,3.08258 2.16275,6.13324 3.375,9.18756c0.88008,2.21735 1.84045,4.42914 2.8125,6.625l49.125,-1.34375c0.32849,0.55511 0.72672,1.07361 1.0625,1.62494l0.3125,0c2.40785,3.95306 4.96716,7.77521 7.6875,11.43756c2.72032,3.6622 5.58696,7.16986 8.59375,10.53125l-16.6875,45.8125c1.45001,1.26459 2.89125,2.53088 4.375,3.75c2.46719,2.02704 4.97525,4.00635 7.53125,5.90613c2.55606,1.8999 5.17326,3.72931 7.8125,5.50006c2.63925,1.77075 5.31439,3.48505 8.03125,5.125c0.77728,0.46918 1.55518,0.92767 2.34375,1.37494l39,-29.34363c0.56766,0.24887 1.14954,0.41473 1.71875,0.65613l0.09375,-0.0625c4.30518,1.83093 8.70319,3.4375 13.15625,4.875c4.45306,1.43762 8.95871,2.68011 13.53125,3.71887l0.0625,0.15613c0.02216,0.00504 0.04031,0.02631 0.0625,0.03137l14.03125,46.5625c1.97339,0.20355 3.9249,0.44836 5.90625,0.59363c3.18457,0.2337 6.39328,0.35443 9.59375,0.43756c2.14056,0.05554 4.28888,0.03827 6.4375,0.03131c1.07559,-0.01147 2.14496,0.02783 3.21875,0c3.20038,-0.08313 6.37793,-0.23535 9.5625,-0.46887c1.01263,-0.07416 2.0209,-0.22296 3.03125,-0.3125l14,-46.37494c10.15869,-2.09686 20.0712,-5.1803 29.59375,-9.21869l39.375,29.59363c1.31567,-0.75366 2.63876,-1.46588 3.9375,-2.24994c2.71692,-1.63995 5.39172,-3.35431 8.03125,-5.125c2.63928,-1.77075 5.25653,-3.60016 7.8125,-5.50006c2.55606,-1.89978 5.06396,-3.87909 7.53125,-5.90613c0.98041,-0.80573 1.91156,-1.67145 2.875,-2.5zm-181.78125,-39.28137c-1.3598,-0.09418 -2.74118,-0.45148 -4.03125,-1.09369c-5.16028,-2.56885 -7.22305,-8.77081 -4.59375,-13.81244c2.6293,-5.04175 8.96472,-7.03772 14.125,-4.46875c5.16028,2.56885 7.22305,8.73956 4.59375,13.78125c-1.97198,3.78131 -6.0144,5.8764 -10.09375,5.59363zm148.875,-47.28113c-1.35977,-0.09424 -2.74118,-0.4516 -4.03125,-1.09375c-5.16037,-2.56897 -7.22308,-8.73962 -4.59375,-13.78125c2.62939,-5.04175 8.96469,-7.03772 14.125,-4.46875c5.16031,2.56882 7.22314,8.73944 4.59375,13.78119c-1.97202,3.78131 -6.01443,5.84518 -10.09375,5.56256z"/>
   </g>
   <path id="svg_5" stroke="#000000" fill="#526a6a" fill-rule="nonzero" stroke-width="0" stroke-linejoin="round" stroke-miterlimit="4" stroke-dashoffset="0" d="m314.20111,144.69968c-51.38983,0 -93.33093,41.89944 -93.33093,93.28928c0,51.3898 41.9411,93.33093 93.33093,93.33093c51.38986,0 93.28928,-41.94113 93.28928,-93.33093c0,-51.38983 -41.89941,-93.28928 -93.28928,-93.28928zm0,21.30061c39.86197,0 71.98865,32.12669 71.98865,71.98866c0,39.86194 -32.12668,72.03033 -71.98865,72.03033c-39.86194,0 -72.0303,-32.1684 -72.0303,-72.03033c0,-39.86197 32.16837,-71.98866 72.0303,-71.98866z"/>
   <path id="svg_6" stroke="#000000" fill="#526a6a" fill-rule="nonzero" stroke-width="0" stroke-linejoin="round" stroke-miterlimit="4" stroke-dashoffset="0" d="m314.20074,147.82602c-49.68298,0 -90.16299,40.479 -90.16299,90.16302c0,49.68399 40.48001,90.16299 90.16299,90.16299c49.68402,0 90.12201,-40.479 90.12201,-90.16299c0,-49.68402 -40.43799,-90.16302 -90.12201,-90.16302zm0,15.00601c41.56802,0 75.15701,33.589 75.15701,75.15701c0,41.56802 -33.58899,75.15695 -75.15701,75.15695c-41.56799,0 -75.15601,-33.58893 -75.15601,-75.15695c0,-41.56801 33.58801,-75.15701 75.15601,-75.15701z"/>
  </g>
 </g>
	<script>
		document.getElementById("gearGroup").addEventListener("click", sendClickToParentDocument, false);
		
		function sendClickToParentDocument(evt)
		{
			// SVGElementInstance objects aren't normal DOM nodes, so fetch the corresponding 'use' element instead
			var target = evt.target;
			if(target.correspondingUseElement)
				target = target.correspondingUseElement;

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
//						x : 10,
//						y : 200,
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
      // call a method in the parent document if it exists
      //if (window.parent.ShowTools)
		//		window.parent.ShowTools();
			//else
				//alert("You clicked '" + target.id + "' which is a " + target.nodeName + " element");
		}
	</script>
</svg>
</div>

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

    function DisplayData(objectToDisplay) {
        if (objectToDisplay.Type && objectToDisplay.Type == "AnnotatedSpectrum") 
                DisplaySpectrum(objectToDisplay);
    }

    function DisplaySpectrum(spectrum) {

    	$("#spectrum").empty();
        // render the spectrum with the given options 
        $("#spectrum").specview({ sequence: spectrum.sequence,
            scanNum: spectrum.scanNum,
            charge: spectrum.charge,
            precursorMz: spectrum.precursorMz,
            fileName: spectrum.fileName,
            staticMods: spectrum.staticMods,
            variableMods: spectrum.variableMods,
            ntermMod: spectrum.ntermMod,
            ctermMod: spectrum.ctermMod,
            peaks: spectrum.peaks
        });

        OpenWindow("spectrum");
    }//*/

</script>


<div id="msg-divC" class="msg" style="position:absolute; top:-600px;">
    
            <div id="spectrum" class="win" style="display:none;position:relative;"></div>
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
    
    function openTrinityConnection() {
        // uses global 'conn' object
        if (trinityConn.readyState === undefined || trinityConn.readyState > 1) {
        	trinityConn = new WebSocket('ws://localhost:81');
        	
        	trinityConn.onopen = function () {
//        		alert("Connected");
				logUser("admin");
            };

            trinityConn.onmessage = function (event) {
                var responseData = JSON.parse(event.data);
                if (responseData.Type) {
                    if (responseData.Type == 'Data' && responseData.Data)
                        DisplayData(responseData.Data);

                    if (responseData.Message)
                        Terminal.echo(responseData.Message);
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
    });//*/
</script>
</body>

</html>
