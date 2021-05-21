package core;

import java.sql.Statement;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Scanner;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;

import model.Database;

@SuppressWarnings("unused")
public class QueryManager {

	private Database database;
	private Connection connection;
	private Scanner reader;
	
	private HashMap<Integer,Integer> hotels;
	private HashMap<Integer,Integer> clients;
	private HashMap<Integer,Integer> hotelAvailRooms;
	private HashMap<Integer,Integer> clientBookings;
	private Integer chosenHotelID;


	public QueryManager(Database db) throws Exception {
		database = db;
		performConnection();
		reader = new Scanner(System.in);
		hotels = new HashMap<Integer,Integer>();
		clients = new HashMap<Integer,Integer>();
		hotelAvailRooms = new HashMap<Integer,Integer>();
		clientBookings = new HashMap<Integer,Integer>();
	}

	private void performConnection() throws Exception {
		System.out.println("\n--> Performing connection using port 5432...");
		try {
			connection = DriverManager.getConnection("jdbc:postgresql://" + database.getUrl() + ":5432/" + database.getName(), database.getUname(),database.getPassword());
			System.out.println("--> Connection was succesful...");
			System.out.print("--> Your database: \n    ");
			System.out.println(connection.getMetaData().getDatabaseProductName() + " | "
					+ connection.getMetaData().getDatabaseProductVersion() + " | URL: " + connection.getMetaData().getURL() + " | Driver: "
					+ connection.getMetaData().getDriverName() +" "+ connection.getMetaData().getDriverVersion() + " | Username: " + connection.getMetaData().getUserName() + " | ");

		} catch (Exception e) {
			throw new Exception("Error occured while trying to connect, please revise your settings ");
		}
	}
	
	public void closeConnection() throws SQLException {
		this.connection.close();
	}
	
	
	public ResultSet performQuery(String query) {	
		Statement st;
		try {
			st = connection.createStatement();
			ResultSet rs = st.executeQuery(query);
			return rs;
		} catch (SQLException e) {
		}
		return null;
	}
	
	
	public void showHotelList(String prefix) throws Exception {
		hotels.clear();
		ResultSet rs = performQuery("SELECT * FROM hotel WHERE name LIKE CONCAT('"+prefix+"','%') ORDER by name");
		
		System.out.println("\n\n------------------ Hotels ------------------");
		System.out.println("        Hotel Name    |     Hotel ID");
		int counter = 1;

		while(rs.next()) {
			System.out.println(counter +") "+rs.getString("name")+" | " +rs.getString("idHotel"));
			hotels.put(counter, rs.getInt("idHotel"));
			counter++;
		}
		System.out.println("--------------------------------------------");
	}
	
	
	public void showHotelClients(String prefix) throws Exception {
		String query = "SELECT * FROM find_hotel_clients_prefix("+chosenHotelID+",'"+prefix+"');";
		ResultSet rs = performQuery(query);
		
		System.out.println("\n\n------------------ Hotel Clients ------------------");
		System.out.println("          Client Name    |     Client ID");
		int counter = 1;

		while(rs.next()) {
			System.out.println(counter++ +") "+rs.getString("clientname")+" | " +rs.getString("clientid"));
		}
		System.out.println("---------------------------------------------------");
	}
	
	
	public void showClientBookings(String idclient, int idhotel) throws Exception {
		clientBookings.clear();
		String query = "SELECT * FROM find_bookings_of_client("+Integer.parseInt(idclient)+","+idhotel+")";
		ResultSet rs = performQuery(query);
		
		System.out.println("\n\n--------------------------------- Client Bookings ---------------------------------");
		System.out.println("    Hotel Booking ID   |   Room ID   |  Chekin Date  |  Checkout Date |  Room rate ");
		int counter = 1;

		while(rs.next()) {
			System.out.println(counter +")     "+rs.getInt("idbooking")+"     |     " +rs.getInt("idroom")+"     |     " +rs.getDate("checkin")+"     |     " +rs.getDate("checkout")+"     |     " +rs.getFloat("rate"));
			clientBookings.put(counter,rs.getInt("idbooking"));
			counter++;
		}
		System.out.println("-----------------------------------------------------------------------------------");
		editClientBookings(Integer.parseInt(idclient));
	}
	
	
	public void editClientBookings(int idclient) throws InterruptedException, Exception {
		String bookingNO = askInput("Select a booking from above to edit dates and room rate by giving its number: ");
		int bookingID = clientBookings.get(Integer.parseInt(bookingNO));
		
		String dateIn = askInput("Enter a checkin date (yyyy-mm-dd): ");
		String dateOut = askInput("Enter a chekout date (yyyy-mm-dd): ");
		float rate = Float.parseFloat((askInput("Enter a rate for the room (n.n): ")));
		
		String query = "SELECT * FROM update_roombooking("+bookingID+",'"+dateIn+"'::date,'"+dateOut+"'::date,"+rate+","+idclient+")";
		performQuery(query);
		
	}
	
	public void showAvailableRooms() throws InterruptedException, Exception {
		hotelAvailRooms.clear();
		String sdate = askInput("Enter a starting date (yyyy-mm-dd): ");
		String edate = askInput("Enter an end date (yyyy-mm-dd): ");
		String query = "SELECT * FROM find_available_rooms_of_hotel('"+sdate+"','"+edate+"',"+chosenHotelID+");";
	
		ResultSet rs = performQuery(query);
		int counter = 1;
		
		System.out.println("\n\n------------------ Available Rooms Through "+sdate+" ~ "+edate+" -------------------");
		System.out.println("  Room ID  |  Room Number |  Type Of Room");
		while(rs.next()) {
			System.out.println(counter+") "+rs.getInt("idroom")+"  |  "+rs.getString("roomnumber")+"  |  "+rs.getString("typeroom"));
			hotelAvailRooms.put(counter, rs.getInt("idroom"));
			counter++;
		}
		System.out.println("--------------------------------------------------------------------------------------");
		newReservationForClient(sdate,edate);
	}
	
	public void newReservationForClient(String sdate, String edate) throws InterruptedException, Exception{
		String rid = askInput("Select the index of a room from above to add new reservation for these dates: ");
		String clid = askInput("Enter a client id for the new booking: ");
		
		int roomid = hotelAvailRooms.get(Integer.parseInt(rid));
		int clientid = Integer.parseInt(clid);
		
		String query1 = "INSERT INTO hotelbooking VALUES(nextval('idhbooking'),(SELECT CURRENT_DATE),(SELECT CURRENT_DATE)+20,NULL,"+clientid+",false,null,'confirmed')";
		String query2 = "INSERT INTO roombooking VALUES(currval('idhbooking'),"+roomid+","+clientid+",'"+sdate+"','"+edate+"',(SELECT find_rate_of_room("+chosenHotelID+","+roomid+")))";
		
		performQuery(query1);
		performQuery(query2);
	}
	
	
	public void hotelMenuController() throws Exception {
	
		String prefix = askInput("Enter a prefix, so hotels with a name starting with that can be showed: ");
		showHotelList(prefix);
		String chosenHotel = askInput("Choose a Hotel from above by giving its number: ");
		chosenHotelID = hotels.get(Integer.parseInt(chosenHotel));
		
		String selection = null;
		System.out.println("\nNote: At any time when asking for input\n\tgiving 0 will take you back to this menu");

		while (true) {
			try {
				printHotelMenu();
				selection = askInput("Choose an option: ");

				switch (selection) {
				case "1":
					String	hotelprefix = askInput("Enter a prefix, so hotels with a name starting with that can be showed: ");
					showHotelList(hotelprefix);
					String chosenHotel0 = askInput("Choose a Hotel from above by giving its number: ");
					chosenHotelID = hotels.get(Integer.parseInt(chosenHotel0));
					break;
				case "i":
					String clientPrefix = askInput("Enter a prefix, so clients with a last name starting with that can be showed: ");
					showHotelClients(clientPrefix);
					break;
				case "ii":
					String clientID = askInput("Enter a client ID, so bookings made by him in the chosen hotel can be showed: ");
					showClientBookings(clientID,chosenHotelID);
					break;				
				case "iii":
					showAvailableRooms();
					break;
				case "2":
					return;					
				default:
					System.out.println("--> '" + selection + "' is not an option...\n");
					break;
				}

			}
			catch (InterruptedException ie) {
				continue;
			}
			catch (Exception e) {
				System.out.println("\n" + " -!- " + e.getMessage() + "-!-" + "\n");
			} 
		}
	}
	
	public void printHotelMenu() {
		System.out.println("\n\n-------------------- Hotel Action Menu ------------------");
		System.out.println("  1. Choose Hotel");
		System.out.println("    |");
		System.out.println("    |i. Search clients using last name prefix");
		System.out.println("    |ii. Search for bookings of a client");
		System.out.println("    |iii. Show Available Rooms");
		System.out.println("    |_____________________________________________");
		System.out.println("\n  2. Return to main menu");
		System.out.println("----------------------------------------------------------\n");
	}
	
	
	public String askInput(String msg) throws InterruptedException {
		System.out.print("--> " + msg);
		
		String out = reader.next();
		if(out.equals("0")) { 
			throw new InterruptedException();
		}
		return out;
	}	
	
	
	
	

}
