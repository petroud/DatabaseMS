package model;

public class Database {

	private String url;
	private String name;
	private String uname;
	private String password;

	public Database(String u, String n, String un, String pwd) {
		url = u;
		name = n;
		uname = un;
		password = pwd;
	}

	public Database() {

	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getUname() {
		return uname;
	}

	public void setUname(String uname) {
		this.uname = uname;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	@Override
	public String toString() {
		return "IP: " + url + "  | Name: " + name + "  | Username: " + uname + "  | Password: " + password;
	}
}
