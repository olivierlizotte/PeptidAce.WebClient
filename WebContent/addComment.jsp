<%@page import="java.io.File" %>
<%@page import="org.neo4j.graphdb.PropertyContainer"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="org.neo4j.cypher.javacompat.ExecutionEngine" %>
<%@ page import="org.neo4j.cypher.javacompat.ExecutionResult" %>
<%@ page import="org.neo4j.graphdb.Direction" %>
<%@ page import="org.neo4j.graphdb.GraphDatabaseService" %>
<%@ page import="org.neo4j.graphdb.Node" %>
<%@ page import="org.neo4j.graphdb.DynamicRelationshipType" %>
<%@ page import="org.neo4j.graphdb.Relationship" %>
<%@ page import="org.neo4j.graphdb.RelationshipType" %>
<%@ page import="org.neo4j.graphdb.Transaction" %>
<%@ page import="org.neo4j.graphdb.index.Index" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="graphDB.explore.*" %>

<%
if(session.getAttribute("user") != null && session.getAttribute("database") != null)
{
	String dbName = session.getAttribute("database").toString();	
	//This jsp will add a comment and send back the new list of comments as a result
	String nodeID  = request.getParameter("id");
	String comment = request.getParameter("comment");
	String userID  = session.getAttribute("userNodeID").toString();

	
	try
	{				
		GraphDatabaseService graphDb = DefaultTemplate.graphDb(dbName);
		String text = DefaultTemplate.Sanitize(comment);

		try(Transaction tx = graphDb.beginTx())
		{		
		 	Node theNode = graphDb.getNodeById(Long.valueOf(nodeID));
			Node theUser = graphDb.getNodeById(Long.valueOf(userID));		
			text = DefaultTemplate.checkForHashTags(text, theNode, theUser, graphDb);
			RelationshipType relType = DynamicRelationshipType.withName( "Comment" );	
			theNode.createRelationshipTo(theUser, relType).setProperty("Text", text);
			out.println("{" + NodeHelper.getComments(theNode) + "}");	
			tx.success();
		}
		
	}
	catch(Exception e)
	{
		e.printStackTrace();
		//out.println("-=" + userID + "=-");	
	}
}
%>