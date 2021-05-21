package core;

import java.util.Scanner;

import model.Database;
@SuppressWarnings("unused")

public class Menu {

	private Scanner reader;
	private boolean isDBsetOk;
	private String selection;
	private QueryManager manager;

	public Menu() {
		printLogo();
		reader = new Scanner(System.in);
		isDBsetOk = false;
		runMenu();
	}

	public void runMenu() {
		System.out.println("\nNote:   At any time when asking for input\n\tgiving 0 will take you back to this menu");

		while (true) {
			try {
				printMenu();
				selection = askInput("Choose an option: ");

				switch (selection) {
				case "a":
					setupDB();
					break;
				case "b":
					if(!isDBsetOk) throw new Exception("There is no database connected! Please first connect a database");
					manager.hotelMenuController();
					break;
				case "c":
					System.out.println("\n--> Closing open connections and exiting....");
					if(isDBsetOk) manager.closeConnection();
					System.exit(0);
				default:
					System.out.println("--> '" + selection + "' is not an option...\n");
					break;
				}

			} 
			catch(InterruptedException ie) {
				continue;
			}
			catch (Exception e) {
				System.out.println("\n" + "-!- " + e.getMessage() + " -!-" + "\n");
			}
		}
	}

	public void setupDB() throws InterruptedException, Exception {

		String option;

		if (isDBsetOk) {
			System.out.println("--> WARNING: A database is already connected, do you want to connect a new one?");
			option = askInput("(y/n): ");

			switch (option) {
			case "y":
				System.out.println("--> Linking new database...");
				break;
			case "n":
				System.out.println("--> Leaving everything as it is");
				return;
			default:
				System.out.println("--> '" + option + "' is not an option...\n");
				return;
			}
		}

		System.out.println();
		String ip = askInput("Enter database IP address (or 'localhost' for LAN installations): ");
		String name = askInput("Enter database name: ");
		String uname = askInput("Enter username: ");
		String pwd = askInput("Enter password: ");

		Database db = new Database(ip, name, uname, pwd);
		System.out.println("--> The database info you entered are:   " + db);

		manager = new QueryManager(db);

		isDBsetOk = true;
	}

	public String askInput(String msg) throws InterruptedException {
		System.out.print("--> " + msg);
		
		String out = reader.next();
		if(out.equals("0")) { 
			throw new InterruptedException();
		}
		return out;
	}	

	public void printMenu() {
		System.out.println("\n-------------------- DBMS Menu -------------------");
		System.out.println("  a. Set up database connection");
		System.out.println("  b. Queries on Hotels");
		System.out.println("  c. Close connections and exit");
		System.out.println("--------------------------------------------------\n");
	}
	
	public void printLogo() {
		System.out.println("  _____          _                  _____  ____  _        _____  ____  __  __  _____ \r\n"
				+ " |  __ \\        | |                / ____|/ __ \\| |      |  __ \\|  _ \\|  \\/  |/ ____|\r\n"
				+ " | |__) |__  ___| |_ __ _ _ __ ___| (___ | |  | | |      | |  | | |_) | \\  / | (___  \r\n"
				+ " |  ___/ _ \\/ __| __/ _` | '__/ _ \\\\___ \\| |  | | |      | |  | |  _ <| |\\/| |\\___ \\ \r\n"
				+ " | |  | (_) \\__ \\ || (_| | | |  __/____) | |__| | |____  | |__| | |_) | |  | |____) |\r\n"
				+ " |_|   \\___/|___/\\__\\__, |_|  \\___|_____/ \\___\\_\\______| |_____/|____/|_|  |_|_____/ \r\n"
				+ "                     __/ |                                                           \r\n"
				+ "                    |___/                                                          ");
	}

	public static void main(String[] args) {
		Menu m = new Menu();
	}

}
