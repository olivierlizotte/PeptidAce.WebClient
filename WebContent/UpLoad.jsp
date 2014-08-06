<%@page import="com.ibm.wsdl.util.StringUtils"%>
<%@page import="org.neo4j.graphdb.DynamicRelationshipType"%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.io.output.*" %>
<%@ page import="org.neo4j.graphdb.PropertyContainer"%>
<%@ page import="org.neo4j.cypher.javacompat.ExecutionEngine"%>
<%@ page import="org.neo4j.cypher.javacompat.ExecutionResult"%>
<%@ page import="org.neo4j.graphdb.Direction"%>
<%@ page import="org.neo4j.graphdb.GraphDatabaseService"%>
<%@ page import="org.neo4j.graphdb.Node"%>
<%@ page import="org.neo4j.graphdb.Relationship"%>
<%@ page import="org.neo4j.graphdb.RelationshipType"%>
<%@ page import="org.neo4j.graphdb.Transaction"%>
<%@ page import="org.neo4j.graphdb.index.Index"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<%@ page import="graphDB.explore.*"%>

<%
   File file ;
   int maxMemSize = 500 * 1024 * 1024;//500MB
   int maxFileSize = 5000 * 1024 * 1024;//5000MB
   ServletContext context = pageContext.getServletContext();
   String filePath = context.getInitParameter("file-upload");

   // Verify the content type
   String contentType = request.getContentType();
   if ((contentType.indexOf("multipart/form-data") >= 0)) {

      DiskFileItemFactory factory = new DiskFileItemFactory();
      // maximum size that will be stored in memory
      factory.setSizeThreshold(maxMemSize);
      // Location to save data that is larger than maxMemSize.
      factory.setRepository(new File(System.getProperty("java.io.tmpdir")));

      // Create a new file upload handler
      ServletFileUpload upload = new ServletFileUpload(factory);
      // maximum file size to be uploaded.
      upload.setSizeMax( maxFileSize );
      try{ 
         // Parse the request to get file items.
         List<FileItem> fileItems = upload.parseRequest(request);

         // Process the uploaded file items
         Iterator<FileItem> iter = fileItems.iterator();

         while ( iter.hasNext () ) 
         {
            FileItem fi = iter.next();
            if ( !fi.isFormField () )	
            {
	            // Get the uploaded file parameters
	            String fieldName = fi.getFieldName();
	            String fileName = fi.getName();
	            boolean isInMemory = fi.isInMemory();
	            long sizeInBytes = fi.getSize();
	            InputStream uploadedStream = fi.getInputStream();
	            InputStreamReader is = new InputStreamReader(uploadedStream);	            
	            BufferedReader br = new BufferedReader(is);
	        	String dbName = null;

	              //Structure is
	              //DB:dbname
	              //HeaderForNodes:h1,h2,h3,h4,h5...
	              //HeaderForLinks:SOURCEINDEX,DESTINATIONINDEX,TYPE,h4,h5...
	              //Nodes:NBNODES
				  //v1,v2,v3,v4,v5...
				  //v1,v2,v3,v4,v5...
				  //...
				  //Links:NBLINKS
				  //v1,v2,v3,v4,v5...
				  //v1,v2,v3,v4,v5...
				  //...
	            		  
                //DbName:
	            String read = br.readLine();
            	dbName = read.substring(3);
                //Node headers:
                read = br.readLine();
                String[] headerNodes = read.split(":")[1].split(",");
                //Link headers
                read = br.readLine();
                String[] headerLinks = read.split(":")[1].split(",");
                //Number of nodes
                read = br.readLine();
                int nbNodes = Integer.parseInt(read.substring(6));
	                
                HashMap<Integer, Long> dicOfIDs = new HashMap<Integer, Long>();
	            GraphDatabaseService graphDb = DefaultTemplate.graphDb(dbName);
	            try(Transaction tx = graphDb.beginTx())
	            {
	            	//Read all nodes
	                read = br.readLine();
	            	int nodesDoneIndex = 0;
	            	while(read != null && nodesDoneIndex < nbNodes) {
	                    String[] splits = read.split(",");
		                Node node = graphDb.createNode();
		                for(int i = 0; i < splits.length; i++)
		                	if(splits[i].length() > 0)
		                		node.setProperty(headerNodes[i], splits[i]);	

		                dicOfIDs.put(nodesDoneIndex, node.getId());
		                out.println(nodesDoneIndex + ":" + node.getId());
		                nodesDoneIndex++;
		                read = br.readLine();		                
		            }
		            tx.success();
	            }
                int nbLinks = Integer.parseInt(read.substring(6));
	            try(Transaction tx = graphDb.beginTx())
	            {
	            	//Read all links
	            	int linksDoneIndex = 0;
	            	while(read != null && linksDoneIndex < nbLinks) {
	                    String[] splits = read.split(",");
	                    int indexNodeSource = Integer.parseInt(splits[0]);
		                Node source = graphDb.getNodeById(dicOfIDs.get(indexNodeSource));
	                    int indexNodeDestination = Integer.parseInt(splits[1]);
		                Node destination = graphDb.getNodeById(dicOfIDs.get(indexNodeDestination));
		                String typeOfLink = splits[2];
		    			RelationshipType relType = DynamicRelationshipType.withName( typeOfLink );	
		    			Relationship currentRelationship = source.createRelationshipTo(destination, relType);
		                for(int i = 3; i < splits.length; i++)
		                	if(splits[i].length() > 0)
		                		currentRelationship.setProperty(headerLinks[i], splits[i]);		

		                linksDoneIndex++;
		                read = br.readLine();		                
		            }
		            tx.success();
	            }
	            uploadedStream.close();
            }
         }
      }catch(Exception ex) {
         System.out.println(ex);
      }
   }else{
   }
%>