package graphDB.explore;

import java.io.IOException;
import java.util.*;

import javax.servlet.jsp.JspWriter;

import org.neo4j.graphdb.*;

public class DefaultNode 
{
	private Node theNode;

	public Node NODE() {
		return theNode;
	}


	public DefaultNode(String nodeID, String dataName) {
		theNode = DefaultTemplate.graphDb(dataName).getNodeById(Long.valueOf(nodeID));
	}

	public String getCommentsVariable(String varName) {
		return "var " + varName + " = " + NodeHelper.getComments(theNode) + ";\n";
	}

	public void printAttributeJSON(JspWriter out) 
	{
		try 
		{
			// EDITING THE STRING
			out.print("{");
			boolean first = true;
			for (String key : theNode.getPropertyKeys()) {
				if (DefaultTemplate.keepAttribute(key))
				{
					if(first)
					{
						out.print("'" + key + "': " + NodeHelper.MakeJSONFriendly(theNode.getProperty(key)));
						first = false;
					}
					else
						out.print(", '" + key + "': " + NodeHelper.MakeJSONFriendly(theNode.getProperty(key)));
				}
			}
			out.print("}");
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * Dynamically write javascript code to declare variables to fill the ExtJS
	 * panels
	 * 
	 * @param out
	 * @param key
	 */
	public void printGridDataJSON(JspWriter out) {
		try 
		{
			out.print("var gridColumns = new Object();\n");
			out.print("var gridFields = new Object();\n");
			out.print("var gridSorters = new Object();\n");
			out.print("var gridName = new Object();\n");
			computeGrid(NodeHelper.computeListOfAttributes( theNode ), theNode, out);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * Dynamically write javascript code to set variables to fill in the grid
	 * 
	 * @param relationsMap
	 * @param listOfAttributes
	 * @param dir
	 * @param theNode
	 * @param out
	 * @param key
	 */
	private static void computeGrid(HashMap<String, HashMap<String, String>> listOfAttributes, Node theNode, JspWriter out) 
	{
		try 
		{				
			for(String strType : DefaultTemplate.sortAttributes(listOfAttributes.keySet()))
			{
				HashMap<String, String> attribs = listOfAttributes.get(strType);
				List<String> sortedAttribs = DefaultTemplate.sortAttributes(attribs.keySet());
				
				out.print("gridColumns['" + strType + "'] = [");
				out.print("{text:'Link', flex:1, dataIndex:'Link'}");
				out.print(",{text:'Relation', flex:1, dataIndex:'Relation', hidden:true}");
				for (String attribute : sortedAttribs)
					out.print(",{text:'" + attribute
							+ "', flex:1, filtrable:true, filter:true, dataIndex:'" + attribute + "', editor: { allowBlank: true }}");
				out.print("];\n");

				out.print("gridFields['" + strType + "'] = [");
				out.print("'Link','Relation'");
				for (String attribute : sortedAttribs)
					out.print(",'" + attribute + "'");
				out.print("];\n");

				out.print("gridSorters['" + strType + "'] = [");
				out.print("'Link'");
				for (String attribute : sortedAttribs)
					out.print(",'" + attribute + "'");
				out.print("];\n");

				out.print("gridName['" + strType + "'] = '" + strType + "';\n");
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public String getType() {
		try {
			if(theNode.hasProperty("type"))
				return theNode.getProperty("type").toString();
			else
				if(theNode.hasProperty("Type"))
					return theNode.getProperty("Type").toString();
				else
					return "";
		} catch (Exception e) {
			return "";
		}
	}

	public long getId() {
		return theNode.getId();
	}
}
