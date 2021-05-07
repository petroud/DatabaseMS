package core;

import java.util.Scanner;

import model.Database;

public class Menu {

	private Scanner reader;
	private boolean isDBsetOk;
	private String selection;
	private QueryManager manager;

	public Menu() {
		reader = new Scanner(System.in);
		isDBsetOk = false;
		runMenu();
	}

	public void runMenu() {

		while (true) {
			try {
				printMenu();
				selection = askInput("Choose an option: ");

				switch (selection) {
				case "a":
					setupDB();
					break;
				case "b":
					System.out.println("\nrunning queries...\n\n");
					break;
				case "c":
					System.out.println("\n--> Closing open connections and exiting....");
					System.exit(0);
				default:
					System.out.println("--> '" + selection + "' is not an option...\n");
					break;
				}

			} catch (Exception e) {
				System.out.println("\n" + " -!- " + e.getMessage() + "-!-" + "\n");
			}
		}
	}

	public void setupDB() throws Exception {

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
		manager.performConnection();

		isDBsetOk = true;
	}

	public String askInput(String msg) {
		System.out.print("--> " + msg);
		return reader.next();
	}

	public void printMenu() {
		System.out.println("\n-------------------- DBMS Menu -------------------");
		System.out.println("  a. Set up database connection");
		System.out.println("  b. Queries");
		System.out.println("  c. Close connections and exit");
		System.out.println("--------------------------------------------------\n");
	}

	public static void main(String[] args) {
		Menu m = new Menu();
	}

}
