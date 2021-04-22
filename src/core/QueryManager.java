package core;

import java.sql.Connection;
import java.sql.DriverManager;

public class QueryManager {

	private Database database;
	private Connection connection;

	public QueryManager(Database db) {
		database = db;

	}

	public void performConnection() throws Exception {
		System.out.println("\n--> Performing connection using port 5432...");
		try {
			connection = DriverManager.getConnection(
					"jdbc:postgresql://" + database.getUrl() + ":5432/" + database.getName(), database.getUname(),
					database.getPassword());
			System.out.println("--> Connection was succesful...");
			System.out.print("--> Your database: ");
			System.out.println(connection.getMetaData().getDatabaseProductName() + " | "
					+ connection.getMetaData().getDatabaseProductVersion() + " | " + connection.getMetaData().getURL());

		} catch (Exception e) {
			throw new Exception("Error occured while trying to connect, please revise your settings ");
		}
	}

}
