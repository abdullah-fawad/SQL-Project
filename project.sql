CREATE database library_system;

use library_system;

CREATE TABLE Author (
    AuthorID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Bio TEXT
);

CREATE TABLE Genre (
    GenreID INT AUTO_INCREMENT PRIMARY KEY,
    GenreName VARCHAR(100) NOT NULL
);

CREATE TABLE Publisher (
    PublisherID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Contact VARCHAR(100),
    Address TEXT
);

CREATE TABLE Member (
    MemberID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(20),
    MembershipDate DATE DEFAULT (SYSDATE())
);

ALTER TABLE Member
MODIFY MembershipDate DATE;


CREATE TABLE Librarian (
    LibrarianID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Username VARCHAR(50) UNIQUE,
    Password VARCHAR(255) NOT NULL
);

CREATE TABLE Book (
    BookID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    ISBN VARCHAR(20) UNIQUE NOT NULL,
    GenreID INT,
    AuthorID INT,
    PublisherID INT,
    AvailabilityStatus ENUM('Available', 'Issued') DEFAULT 'Available',
    FOREIGN KEY (GenreID) REFERENCES Genre(GenreID),
    FOREIGN KEY (AuthorID) REFERENCES Author(AuthorID),
    FOREIGN KEY (PublisherID) REFERENCES Publisher(PublisherID)
);

CREATE TABLE BorrowedBooks (
    TransactionID INT AUTO_INCREMENT PRIMARY KEY,
    BookID INT,
    MemberID INT,
    BorrowDate DATE,
    DueDate DATE,
    ReturnDate DATE,
    Status ENUM('Issued', 'Returned', 'Overdue') DEFAULT 'Issued',
    Penalty DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (BookID) REFERENCES Book(BookID),
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID)
);

INSERT INTO Author (Name, Bio) 
VALUES
('J.K. Rowling', 'British author, best known for writing the Harry Potter series.'),
('George Orwell', 'English novelist, essayist, journalist, and critic, famous for works like 1984 and Animal Farm.'),
('J.R.R. Tolkien', 'English writer, best known for The Hobbit and The Lord of the Rings.'),
('Agatha Christie', 'British writer known for her detective novels, especially those featuring Hercule Poirot.'),
('Isaac Asimov', 'American author and professor, known for his works in science fiction and popular science.'),
('Stephen King', 'American author known for horror, supernatural fiction, suspense, and fantasy.'),
('Jane Austen', 'English novelist known for her six major novels including Pride and Prejudice.'),
('Mark Twain', 'American writer, best known for The Adventures of Tom Sawyer and Adventures of Huckleberry Finn.'),
('Charles Dickens', 'English writer and social critic, famous for works like Oliver Twist and A Tale of Two Cities.'),
('F. Scott Fitzgerald', 'American novelist, best known for writing The Great Gatsby.');

INSERT INTO Genre (GenreName)
VALUES
('Fantasy'),
('Science Fiction'),
('Mystery'),
('Romance'),
('Historical Fiction'),
('Thriller'),
('Adventure'),
('Non-Fiction'),
('Biography'),
('Young Adult');

INSERT INTO Publisher (Name, Contact, Address)
VALUES
('Bloomsbury', 'contact@bloomsbury.com', '50 Bedford Square, London, UK'),
('Penguin Books', 'info@penguin.com', '80 Strand, London, UK'),
('HarperCollins', 'support@harpercollins.com', '195 Broadway, New York, NY, USA'),
('Macmillan', 'help@macmillan.com', '120 Broadway, New York, NY, USA'),
('Simon & Schuster', 'contact@simonandschuster.com', '1230 Avenue of the Americas, New York, NY, USA'),
('Random House', 'info@randomhouse.com', '1745 Broadway, New York, NY, USA'),
('Hachette Livre', 'contact@hachette.com', '58 Rue Jean-Baptiste Pigalle, Paris, France'),
('Oxford University Press', 'support@oup.com', 'Great Clarendon Street, Oxford, UK'),
('Pearson Education', 'customer.service@pearson.com', '80 Strand, London, UK'),
('University of Chicago Press', 'press@press.uchicago.edu', '1427 E 60th St, Chicago, IL, USA');

INSERT INTO Book (Title, ISBN, GenreID, AuthorID, PublisherID, AvailabilityStatus)
VALUES
('Harry Potter and the Sorcerer\'s Stone', '9780747532699', 1, 1, 1, 'Available'),
('1984', '9780451524935', 2, 2, 2, 'Available'),
('The Hobbit', '9780618968633', 1, 3, 1, 'Available'),
('Murder on the Orient Express', '9780062693662', 3, 4, 2, 'Available'),
('Foundation', '9780553293357', 2, 5, 3, 'Available'),
('The Shining', '9780385121675', 6, 6, 4, 'Available'),
('Pride and Prejudice', '9781503290563', 4, 7, 5, 'Available'),
('Adventures of Tom Sawyer', '9780486280615', 5, 8, 6, 'Available'),
('A Tale of Two Cities', '9781853260391', 5, 9, 7, 'Available'),
('The Great Gatsby', '9780743273565', 9, 10, 8, 'Available');

INSERT INTO Member (Name, Email, Phone, MembershipDate)
VALUES
('Taha', 'taha@example.com', '123-456-7890', '2024-04-10'),
('Omais', 'omais@example.com', '234-567-8901', '2025-03-22'),
('Ayaan', 'ayaan@example.com', '345-678-9012', '2024-02-15'),
('Ali', 'ali@example.com', '456-789-0123', '2024-01-10'),
('Rana', 'rana@example.com', '567-890-1234', '2025-03-28');

INSERT INTO Librarian (Name, Email, Username, Password)
VALUES
('Abdullah', 'abdullah@example.com', 'abdullah123', 'fast123'),
('Sami', 'sami@example.com', 'sami456', 'fast456');

INSERT INTO BorrowedBooks (BookID, MemberID, BorrowDate, DueDate)
VALUES
(1, 1, '2025-04-17', '2025-05-17'), 
(2, 2, '2025-04-15', '2025-05-15'), 
(3, 3, '2025-04-10', '2025-05-10'),  
(4, 4, '2025-04-05', '2025-05-05'),  
(5, 5, '2025-04-12', '2025-05-12');  

select * from borrowedbooks;

-- checking the author before adding the book 

DELIMITER $$

CREATE PROCEDURE Add_Author_If_Not_Exists(IN author_name VARCHAR(255), IN author_bio TEXT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Author WHERE Name = author_name) THEN
        INSERT INTO Author (Name, Bio)
        VALUES (author_name, author_bio);
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE Add_Publisher_If_Not_Exists(IN publisher_name VARCHAR(255), IN publisher_contact VARCHAR(100), IN publisher_address TEXT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Publisher WHERE Name = publisher_name) THEN
        INSERT INTO Publisher (Name, Contact, Address)
        VALUES (publisher_name, publisher_contact, publisher_address);
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE Add_Genre_If_Not_Exists(IN genre_name VARCHAR(255))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Genre WHERE GenreName = genre_name) THEN
        INSERT INTO Genre (GenreName)
        VALUES (genre_name);
    END IF;
END$$

DELIMITER ;

drop procedure if exists Add_Book;

DELIMITER $$

CREATE PROCEDURE Add_Book(
    IN book_title VARCHAR(255),
    IN book_isbn VARCHAR(50),
    IN genre_name VARCHAR(100),
    IN author_name VARCHAR(255),
    IN publisher_name VARCHAR(255),
    IN publisher_contact VARCHAR(100),
    IN publisher_address TEXT,
    IN availability_status VARCHAR(50)
)
BEGIN
    DECLARE author_id INT;
    DECLARE publisher_id INT;
    DECLARE genre_id INT;

    CALL Add_Author_If_Not_Exists(author_name, '');
    CALL Add_Publisher_If_Not_Exists(publisher_name, publisher_contact, publisher_address);
	CALL Add_Genre_If_Not_Exists(genre_name);

    SELECT AuthorID INTO author_id FROM Author WHERE Name = author_name;
    SELECT PublisherID INTO publisher_id FROM Publisher WHERE Name = publisher_name;
    SELECT GenreID INTO genre_id FROM Genre WHERE GenreName = genre_name;

    INSERT INTO Book (Title, ISBN, GenreID, AuthorID, PublisherID, AvailabilityStatus)
    VALUES (book_title, book_isbn, genre_id, author_id, publisher_id, availability_status);
    
    commit;
END$$

DELIMITER ;

-- basically this is same as view books.

SELECT 
    Book.BookID,
    Book.Title,
    Book.ISBN,
    Genre.GenreName,
    Author.Name AS Author,
    Publisher.Name AS Publisher,
    Book.AvailabilityStatus
FROM Book
JOIN Genre ON Book.GenreID = Genre.GenreID
JOIN Author ON Book.AuthorID = Author.AuthorID
JOIN Publisher ON Book.PublisherID = Publisher.PublisherID;


-- stored procedure for adding members in the members table 

DELIMITER $$

CREATE PROCEDURE AddMember(
    IN member_name VARCHAR(255),
    IN member_email VARCHAR(255),
    IN member_phone VARCHAR(20)
)
BEGIN
    
    START TRANSACTION;
    
    INSERT INTO Member (Name, Email, Phone, MembershipDate)
    VALUES (member_name, member_email, member_phone, CURDATE());

    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER after_borrow
AFTER INSERT ON BorrowedBooks
FOR EACH ROW
BEGIN
    UPDATE Book
    SET AvailabilityStatus = 'Borrowed' 
    WHERE BookID = NEW.BookID;
END$$

DELIMITER ;

ALTER TABLE Book 
MODIFY AvailabilityStatus ENUM('Available', 'Borrowed', 'Reserved') DEFAULT 'Available';


DELIMITER $$

CREATE TRIGGER MarkBookAsAvailable
AFTER UPDATE ON BorrowedBooks
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Returned' THEN
        UPDATE Book
        SET AvailabilityStatus = 'Available'
        WHERE BookID = NEW.BookID;
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE Borrow_Book(
    IN input_book_id INT,
    IN input_member_id INT,
    IN input_borrow_date DATE,
    IN input_due_date DATE
)
BEGIN
    DECLARE book_status VARCHAR(50);

    SELECT AvailabilityStatus INTO book_status
    FROM Book
    WHERE BookID = input_book_id;

    IF book_status = 'Available' THEN
        INSERT INTO BorrowedBooks (BookID, MemberID, BorrowDate, DueDate)
        VALUES (input_book_id, input_member_id, input_borrow_date, input_due_date);
        
        COMMIT;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Book is not available for borrowing.';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE ReturnBook(
    IN input_transaction_id INT,
    IN input_return_date DATE
)
BEGIN
    DECLARE due DATE;
    DECLARE book_id INT;
    DECLARE days_late INT;
    DECLARE fine DECIMAL(10,2) DEFAULT 0.00;

    SELECT DueDate, BookID INTO due, book_id
    FROM BorrowedBooks
    WHERE TransactionID = input_transaction_id;

    SET days_late = DATEDIFF(input_return_date, due);

    IF days_late > 0 THEN
        SET fine = days_late * 5;
    END IF;

    UPDATE BorrowedBooks
    SET ReturnDate = input_return_date,
        Status = 'Returned',
        Penalty = fine
    WHERE TransactionID = input_transaction_id;

    UPDATE Book
    SET AvailabilityStatus = 'Available'
    WHERE BookID = book_id;

    COMMIT;
END$$

DELIMITER ;

DELIMITER //

CREATE PROCEDURE Delete_Book(IN input_book_id INT)
BEGIN
    START TRANSACTION;
    
    DELETE FROM BorrowedBooks WHERE BookID = input_book_id;
    DELETE FROM Book WHERE BookID = input_book_id;

    COMMIT;
END;
//

DELIMITER ;


DELIMITER //
CREATE PROCEDURE DeleteMember(IN input_member_id INT)
BEGIN
	START TRANSACTION;
    
    DELETE FROM Member WHERE MemberID = input_member_id;
    
    COMMIT;
END;
//
DELIMITER ;

DELIMITER //

CREATE PROCEDURE Update_Member_Details(
    IN input_member_id INT,
    IN input_name VARCHAR(255),
    IN input_email VARCHAR(255),
    IN input_phone VARCHAR(50)
)
BEGIN
    START TRANSACTION;

    UPDATE Member
    SET
        Name = input_name,
        Email = input_email,
        Phone = input_phone
    WHERE MemberID = input_member_id;

    COMMIT;
END;
//

DELIMITER ;


CREATE VIEW Book_Details AS
SELECT 
    b.BookID,
    b.Title,
    b.ISBN,
    a.Name AS AuthorName,
    g.GenreName,
    p.Name AS PublisherName,
    b.AvailabilityStatus
FROM 
    Book b
JOIN Author a ON b.AuthorID = a.AuthorID
JOIN Genre g ON b.GenreID = g.GenreID
JOIN Publisher p ON b.PublisherID = p.PublisherID;


CREATE VIEW View_Members AS
SELECT 
    MemberID,
    Name,
    Email,
    Phone,
    MembershipDate
FROM 
    Member;

CREATE VIEW View_BorrowedBooks AS
SELECT 
		BorrowedBooks.TransactionID,
		BorrowedBooks.BookID,
		BorrowedBooks.MemberID,
		BorrowedBooks.BorrowDate,
		BorrowedBooks.DueDate,
		BorrowedBooks.ReturnDate,
		BorrowedBooks.Status,
		BorrowedBooks.Penalty,
		Book.Title,
		Member.Name AS MemberName
		FROM BorrowedBooks
		JOIN Book ON BorrowedBooks.BookID = Book.BookID
		JOIN Member ON BorrowedBooks.MemberID = Member.MemberID;
        