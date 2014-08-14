package graphDB.explore;

import graphDB.explore.tools.AlphanumComparator;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.PriorityQueue;

import javax.servlet.jsp.JspWriter;

import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Relationship;
import org.neo4j.helpers.Pair;
import org.neo4j.shell.util.json.*;


public class Grid 
{
	private static PriorityQueue<Pair<Node, Relationship>> GetValues(String sort, String nodeID, String nodeType, String filter, String dbName)
	{
		return GetValues(sort, nodeID, nodeType, filter, dbName, 0, Integer.MAX_VALUE);
	}
	
	private static PriorityQueue<Pair<Node, Relationship>> GetValues(String sort, String nodeID, String nodeType, String filter, String dbName, int start, int limit)
	{		
		try 
		{			
			//Sort params	
			JSONArray array = new JSONArray(sort);
			JSONObject obj  = array.getJSONObject(0);
			if(sort == null || sort.length() == 0)
				sort = null;
			else
				sort = obj.getString("property");
			final String property	= sort;
			
			//Filter params 
			//Encoded : (field / value / comparison / type)
			//not encoded: (field / data->value / data->comparison / data->type)
			String[] strFilter   = null;
			String[] strProperty = null;
			if(filter != null && !filter.isEmpty())
			{
				JSONArray arrayFi = new JSONArray(filter);
				strFilter = new String[arrayFi.length()];
				strProperty = new String[arrayFi.length()];
				for(int i = 0; i < arrayFi.length(); i++)
				{
					JSONObject objFilter  = arrayFi.getJSONObject(i);				
					strFilter[i] = objFilter.getString("value");
					strProperty[i] = objFilter.getString("field");
				}
			}
			final String[] filterWords = strFilter;
			final String[] filterProperty = strProperty;
			
			String direction= obj.getString("direction");
			final boolean dir = ("ASC".equals(direction) ? true : false);

			final AlphanumComparator alNum = new AlphanumComparator();
			Comparator<Pair<Node, Relationship>> comparator = new Comparator<Pair<Node, Relationship>>()
            {
                public int compare( Pair<Node, Relationship> n1, Pair<Node, Relationship> n2 )
                {
                	if(property == null)
                		return 0;
                	int result = 0;
                	Object r1 = null;
                	Object r2 = null;	                    	
                	
                	if(n1.other().hasProperty(property))
                		r1 = n1.other().getProperty(property);
                	else if (n1.first().hasProperty(property))
                		r1 = n1.first().getProperty(property);
                	
                	if(r1 != null)
                	{
                		result = 1;
                		if(n2.other().hasProperty(property))
                			r2 = n2.other().getProperty(property);
                		else if (n2.first().hasProperty(property))
                			r2 = n2.first().getProperty(property);
                		
                		if(r2 != null)
                		{
                    		if(r1 instanceof Number && r2 instanceof Number)		                    			
                    			result = Double.compare((Double)r1, (Double) r2);
                    		else if(r1 instanceof String && r2 instanceof String)
                    			result = alNum.compare((String)r1, (String)r2);
                    		else
                    			result = alNum.compare(r1.toString(), r2.toString());
                		}
                	}
                	if(dir)
                		return result;
                	else
                		return -result;
                }
            };//*/

            PriorityQueue<Pair<Node, Relationship>> nodes = new PriorityQueue<Pair<Node, Relationship>>(100, comparator);
    		
			Node head = DefaultTemplate.graphDb(dbName).getNodeById(Long.parseLong(nodeID)); 
			int maxSize = limit;
			if(maxSize < Integer.MAX_VALUE)
				maxSize += start;
			//Cycle through the list of relations to find them 
			for(Relationship relation : head.getRelationships())
			{
				String strRelation = relation.getType().name();
				if(DefaultTemplate.keepRelation(strRelation))
				{
					Node theOtherNode = relation.getOtherNode(head);
					if(nodeType.equals(NodeHelper.getType(theOtherNode)))
					{
						boolean keep = true;
						if(filterWords != null)
						{
							for(int i = 0; i < filterWords.length; i++)
							{
								if(theOtherNode.hasProperty(filterProperty[i]))							
								{
									Object myValue = theOtherNode.getProperty(filterProperty[i]);
									String strComp = "";
		                    		if(myValue instanceof Number)
		                    			strComp = ((Double) myValue).toString();
		                    		else if(myValue instanceof String)
		                    			strComp = (String)myValue;
		                    		if(strComp.indexOf(filterWords[i]) < 0)
		                    			keep = false;
								}
								else
									keep = false;
							}														
						}
						if(keep)
						{
							Pair<Node, Relationship> pair = Pair.of(theOtherNode, relation);
							//if(highestPair == null) highestPair = pair;
							//if(nodes.size() < maxSize || comparator.compare(pair, highestPair) <= 0)
							//{
								nodes.add(pair);
							//	highestPair = nodes.last();
							//}
						}
					}
				}
			}

			return nodes;
			/*
			Pair<Node, Relationship> lowestPair = nodes.first();			
			for(Pair<Node, Relationship> pair : nodes)
			{
				if(start == 0 )
				{
					lowestPair = pair;
				}
				if(start <= 0)
				{
					limit--;
					if(limit < 0)
					{
						highestPair = pair;
						break;
					}
				}
				start--;
			}			
			return nodes.subSet(lowestPair, highestPair);//*/
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		return null;
	}
	/*
	private static List<Pair<Node, Relationship>> GetValuesBKP(String sort, String nodeID, String nodeType, String filter, String dbName)
	{
		List<Pair<Node, Relationship>> nodes = new LinkedList<Pair<Node, Relationship>>();
		try 
		{
			//Sort params
			JSONArray array = new JSONArray(sort);
			JSONObject obj  = array.getJSONObject(0);
			final String property	= obj.getString("property");
			
			//Filter params 
			//Encoded : (field / value / comparison / type)
			//not encoded: (field / data->value / data->comparison / data->type)
			String[] strFilter   = null;
			String[] strProperty = null;
			if(filter != null && !filter.isEmpty())
			{
				JSONArray arrayFi = new JSONArray(filter);
				strFilter = new String[arrayFi.length()];
				strProperty = new String[arrayFi.length()];
				for(int i = 0; i < arrayFi.length(); i++)
				{
					JSONObject objFilter  = arrayFi.getJSONObject(i);				
					strFilter[i] = objFilter.getString("value");
					strProperty[i] = objFilter.getString("field");
				}
			}
			final String[] filterWords = strFilter;
			final String[] filterProperty = strProperty;
			
			String direction= obj.getString("direction");
			final boolean dir = ("ASC".equals(direction) ? true : false);
					
			Node head = DefaultTemplate.graphDb(dbName).getNodeById(Long.parseLong(nodeID)); 
			
			//Cycle through the list of relations to find them 
			for(Relationship relation : head.getRelationships())
			{
				String strRelation = relation.getType().name();
				if(DefaultTemplate.keepRelation(strRelation))
				{
					Node theOtherNode = relation.getOtherNode(head);
					if(nodeType.equals(NodeHelper.getType(theOtherNode)))
					{
						if(filterWords != null)
						{
							boolean allProp = true;
							for(int i = 0; i < filterWords.length; i++)
							{
								if(theOtherNode.hasProperty(filterProperty[i]))							
								{
									Object myValue = theOtherNode.getProperty(filterProperty[i]);
									String strComp = "";
		                    		if(myValue instanceof Number)
		                    			strComp = ((Double) myValue).toString();
		                    		else if(myValue instanceof String)
		                    			strComp = (String)myValue;
		                    		if(strComp.indexOf(filterWords[i]) < 0)
		                    			allProp = false;
								}
								else
									allProp = false;
							}
							if(allProp)
								nodes.add(Pair.of(theOtherNode, relation));														
						}
						else
							nodes.add(Pair.of(theOtherNode, relation));
					}
				}
			}
			
			final AlphanumComparator alNum = new AlphanumComparator();
	        Collections.sort( nodes, 
	        		new Comparator<Pair<Node, Relationship>>()
	                {
	                    public int compare( Pair<Node, Relationship> n1, Pair<Node, Relationship> n2 )
	                    {
	                    	int result = 0;
	                    	Object r1 = null;
	                    	Object r2 = null;	                    	
	                    	
	                    	if(n1.first().hasProperty(property))
	                    		r1 = n1.first().getProperty(property);
	                    	else if (n1.other().hasProperty(property))
	                    		r1 = n1.other().getProperty(property);
	                    	
	                    	if(r1 != null)
	                    	{
	                    		if(n2.first().hasProperty(property))
	                    			r2 = n2.first().getProperty(property);
	                    		else if (n2.other().hasProperty(property))
	                    			r2 = n2.other().getProperty(property);
	                    		
	                    		if(r2 != null)
	                    		{
		                    		if(r1 instanceof Number && r2 instanceof Number)		                    			
		                    			result = Double.compare((Double)r1, (Double) r2);
		                    		else if(r1 instanceof String && r2 instanceof String)
		                    			result = alNum.compare((String)r1, (String)r2);
	                    		}
	                    	}
	                    	if(dir)
	                    		return result;
	                    	else
	                    		return -result;
	                    }
	                } );
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		return nodes;
	}//*/
	
	public static boolean GetList(JspWriter out, int start, int limit, String sort, String nodeID, String nodeType, String filter, String dbName)
	{		
		try
		{
			out.println("{root:[");
			long nbPrinted = 0;
			PriorityQueue<Pair<Node, Relationship>> nodes = GetValues(sort, nodeID, nodeType, filter, dbName, start, limit);
			int index = 0;
			
			while(!nodes.isEmpty())
			{
				Pair<Node, Relationship> aPair = nodes.poll();
				if(index >= start)
				{
					if(index - start > limit)
						break;
					
					Node aNode = aPair.first();
					Relationship relation = aPair.other();
					
					nbPrinted++;
					if(nbPrinted > 1)
						out.print(",");
				
					out.println("{" + 
							"'Link':'<a href=\"index.jsp?id="
							+ aNode.getId() + "&db=" + dbName + "\">" + aNode.getId() + "</a>'");
	
					//Add the properties of the node
					for(String key : aNode.getPropertyKeys())
						if(DefaultTemplate.keepAttribute(key) && !DefaultTemplate.isNameAttribute(key))
								out.print(",'" + key + "':'" + NodeHelper.MakeHtmlFriendly(aNode.getProperty(key)) + "'");
	
					//Add the properties of the relation
					for(String key : relation.getPropertyKeys())
						if(DefaultTemplate.keepAttribute(key))
							out.print(",'" + key + "':'" + NodeHelper.MakeHtmlFriendly(relation.getProperty(key)) + "'");
					
					out.print(",Relation:'" + relation.getType().name() + "',Type:'" + NodeHelper.getType(aNode) + "'}");
				}
				index++;
			}
			
			out.println("],total:" + nodes.size() + "}");
			return true;
		} 
		catch (Exception e) 
		{
			e.printStackTrace();
		}
		return false;
	}
	
	public static boolean GetListAsCsv(JspWriter out, String sort, String nodeID, String nodeType, String dbName)
	{		
		try 
		{
			//Get list of attributes
			Node head = DefaultTemplate.graphDb(dbName).getNodeById(Long.parseLong(nodeID));
			List<String> allAttribs = DefaultTemplate.sortAttributes(NodeHelper.computeListOfAttributes( head ).get(nodeType).keySet());
			
			List<String> attribs = new ArrayList<String>();
			for(String key : allAttribs)
				if(!"Request".equals(key))
					attribs.add(key);
			
			out.print(nodeType);
			//Print title line
			for(String key : attribs)
				out.print("," + key);
			out.println();
				
			//Get all the nodes and relations
			PriorityQueue<Pair<Node, Relationship>> nodes = GetValues(sort, nodeID, nodeType, "", dbName);

			while(!nodes.isEmpty())
			{
				Pair<Node, Relationship> aPair = nodes.poll();
				Node aNode = aPair.first();
				Relationship relation = aPair.other();

				out.print(DefaultTemplate.MainSiteAdress +"index.jsp?id=" + aNode.getId() + "&db=" + dbName);
				//Use the sorted attributes to print node and relation properties
				for(String key : attribs)
				{
					String str = "";				
					if(relation.hasProperty(key))
						str = relation.getProperty(key).toString();
					else
						if(aNode.hasProperty(key))
							str = aNode.getProperty(key).toString();
					if(str.length() > 256)
						str = "";
					
					out.print("," + str.replace(',', ';'));
				}
				out.println();
			}
			return true;
		} 
		catch (Exception e) 
		{
			e.printStackTrace();
		}
		return false;
	}
	
}
