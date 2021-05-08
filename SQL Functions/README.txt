------------------------------------------------------------------------------------------------
Ομάδα 126
Τσιπουράκη Αλεξάνδρα - 2018030089
Πέτρου Δημήτριος - 2018030070
------------------------------------------------------------------------------------------------

Σε αυτό το αρχείο υπάρχουν διάφορες πληροφορίες σχετικά με την υλοποιήση της Α'φάσης του project 
του μαθήματος ΠΛΗ303-Βάσεις Δεδομένων. 



------------------------------------------ Παρατηρήσεις ----------------------------------------

1) Στη βάση επιλέχθηκε οι ζητούμενες συναρτήσεις να κατατμηθούν σε μικρότερες συναρτήσεις για 
   πιο οργανωμένη και ευανάγνωστη συγγραφή κώδικα. Οι βοηθητικές συναρτήσεις αυτές δεν αντιστοι-
   χίζονται σε ερωτήματα και μια λίστα αυτών υπάρχει παρακάτω.

2) Οι συναρτήσεις που απαντούν στα ερωτήματα της εκφώνησης ονομάστηκαν σύμφωνα με το πρότυπο:
    function_name_X_X(args) όπου Χ,Χ ο αριθμός του ερωτήματος.

3) Για την κλήση μιας συνάρτησης μπορεί να χρησιμοποιηθεί το query:
    SELECT * FROM function_name_X_X(args);

4) Στο directory που παραδόθηκε εντός του φακέλου 'SQL Functions' υπάρχουν αρχεία .sql για κάθε 
   ερώτημα που απαντήθηκε το source code της εκάστοτε συνάρτησης, συνοδευόμενα από αντίστοιχα 
   queries. 

------------------------------------------------------------------------------------------------



--------------------------------------- Συνθήκες Υλοποιήσης ------------------------------------

Παρατηρήθηκαν ή έγιναν τα εξής:

1) Στη βάση που διατέθηκε υπήρχαν tuples του πίνακα "hotelbooking" τα οποία δεν είχαν κανένα 
   "roombooking" προς αντιστοίχιση (πχ 897)

2) Oρισμένοι εργαζόμενοι μπορούν να λάβουν και ρόλο client όχι απαραίτητα στο ίδιο ξενοδοχείο.

3) Εισήχθησαν μερικές εκατοντάδες tuples στον πίνακα "activity" που για το κάθε ένα υπάρχει
   1 employee που το κάνει reserve και 1 responsible employee που κάνει participate σε αυτό.    
   Κάθε ξενοδόχειο έχει 3 activities, εκ των οποίων 1 δεν έχει participants, προκειμένου 
   να γίνουν οι απαραίτητες δοκιμές για τα ζητούμενα queries. Αξίζει να σημειωθεί πως επειδή
   οι χρόνοι διεξαγωγής του κάθε activity παρήχθησαν τυχαία ενδεχόμενως να μην υπάρχει απόλυτη
   ομοιομορφία και λογική στη διάρκεια.

4) Με σκοπό να δοκιμαστεί το trigger του 5.1 ερωτήματος επιλέχθηκαν τυχαία 2000 tuples του
   "hotelbooking" να γίνουν payed=TRUE

------------------------------------------------------------------------------------------------



---------------------------------------- Λίστα Συναρτήσεων -------------------------------------

Α) Συναρτήσεις Ερωτημάτων 

    --- 2.1 ---
    edit_client_2_1(actionArg varchar, docClient varchar, fnamee varchar, lnamee varchar, sexx character, dateofbirthh date, addresss varchar, cityy varchar, countryy varchar, cardtypee varchar, cardnumberr varchar, holderr varchar, expirationn date) 

    insert_client_2_1(docClient varchar, fname varchar, lname varchar, sex character, dateofbirth date, address varchar, city varchar, country varchar, cardtype varchar, cardnumber varchar, holder varchar, expiration date) 
    delete_client_2_1(docClient varchar, lastname varchar, cardnumber varchar) 
    update_client_2_1(docClient varchar, fnamee varchar, lnamee varchar, sexx character, dateofbirthh date, addresss varchar, cityy varchar, countryy varchar, cardtypee varchar, cardnumberr varchar, holderr varchar, expirationn date)



    --- 3.1 ---
    find_discounts_3_1()

    --- 3.2 ---
    find_hotel_amenities_3_2(hname varchar, hasstars varchar)

    --- 3.3 ---
    find_max_discount_rooms_of_hotels_3_3()

    --- 3.4 ---
    find_hotel_bookings_3_4(hotelIDarg integer)

    --- 3.5 ---
    find_hotel_empty_activities_3_5(idhot integer)




    --- 4.1 ---
    calculate_activities_ofclient_4_1(hotelid integer)

    --- 4.2 ---
    calculate_avg_age_4_2(roomtypearg varchar)

    --- 4.3 ---
    calculate_cheapest_rate_for_country_4_3(countryname varchar) 

    --- 4.4 ---
    calculate_best_hotels_byincome_4_4()

    --- 4.5 ---
    calculate_completeness_4_5(hotelid integer,yearArg integer)



    --- 5.0 ---
    Τα headers των συναρτήσεων για τα triggers βρίσκονται εντός της βάσης σε περίπτωση που χρειαστούν





Β) Βοηθητικές συναρτήσεις

    add_activity(args) : Εισαγωγή νέου activity με βάση τα arguments 

    checkifclient(args) : Έλεγχος αν ένα id ανήκει σε πελάτη του ξενοδοχείου

    convertinttoday(args) : Μετατροπή ακεραίου σε ημέρα της εβδομάδας (πχ 1->Δευτέρα)

    find_booking_whomanages(args) : Έυρεση του εργαζομένου που διαχειρίζεται μια κράτηση

    find_cancel_date_of_booking(args) : Εύρεση της ημερομηνίας ακύρωσης μιας κράτηση

    find_hotel_manager(args) : Εύρεση του διευθυντή ενός ξενοδοχείου

    find_hotel_ofbookings(args) :  Εύρεση του ξενοδοχείο στο οποίο ανήκει μια κράτηση

    generate_manages() : Ανάθεση των κράτησεων κάθε ξενοδοχείου σε τυχαίο εργαζόμενο του

    get_hotel_rooms(args) : Εύρεση των ids των δωματίων ενός ξενοδοχείου

    get_name_by_id(args) : Εύρεση του ονόματος ενός person με βάση το id του.

    gethotelclients(args) : Eύρεση των πελατών ενός ξενοδοχείο

    gethotelemployees(args) : Εύρεση των εργαζομένων ενός ξενοδοχείου

    selectrandomhotelclient(args) : Επιλογή ενός τυχαίου πελάτη ενός ξενοδοχείου

    selectrandomhotelemployees(args) : Επιλογή ενός τυχαίου εργαζομένου ενός ξενοδοχείου

    show_allclients() : Εμφάνιση όλων των πελατών της βάσης

    show_allemployees() : Εμφάνιση όλων των εργαζομένων της βάσης.

------------------------------------------------------------------------------------------------














   





