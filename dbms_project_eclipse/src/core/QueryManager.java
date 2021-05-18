package core;

import java.sql.Statement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;

import model.Database;

public class QueryManager {

	private Database database;
	private Connection connection;

	public QueryManager(Database db) throws Exception {
		database = db;
		performConnection();
	}

	private void performConnection() throws Exception {
		System.out.println("\n--> Performing connection using port 5432...");
		try {
			connection = DriverManager.getConnection("jdbc:postgresql://" + database.getUrl() + ":5432/" + database.getName(), database.getUname(),database.getPassword());
			System.out.println("--> Connection was succesful...");
			System.out.print("--> Your database: ");
			System.out.println(connection.getMetaData().getDatabaseProductName() + " | "
					+ connection.getMetaData().getDatabaseProductVersion() + " | " + connection.getMetaData().getURL());

		} catch (Exception e) {
			throw new Exception("Error occured while trying to connect, please revise your settings ");
		}
	}
	
	
	public ResultSet performQuery(String query) {
		
		Statement st;
		try {
			st = connection.createStatement();
			ResultSet rs = st.executeQuery(query);
			return rs;
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return null;
	}
	
	
	
	
	
	

}
