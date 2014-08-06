<%@ page import="graphDB.explore.*" %>
<%
String dbName = session.getAttribute("database").toString();
DefaultTemplate.removeAllTempElements(DefaultTemplate.graphDb(dbName));
%>