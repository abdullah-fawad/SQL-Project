from flask import Flask, render_template, request, redirect, url_for, session,flash
from sqlalchemy import text
from db import get_db_connection, call_db_procedure

app = Flask(__name__)
app.secret_key = 'your_secret_key'

@app.route('/login', methods=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        with get_db_connection() as conn:
            query = text("SELECT * FROM Librarian WHERE Username = :username AND Password = :password")
            result = conn.execute(query, {"username": username, "password": password})
            librarian = result.fetchone()

        if librarian:
            session['librarian'] = librarian.Username
            return redirect(url_for('dashboard')) 
        else:
            error = "You are not a registered librarian."

    return render_template('login.html', error=error)

@app.route('/')
def index():
    return redirect(url_for('login'))

@app.route('/dashboard')
def dashboard():
    if 'librarian' not in session:
        return redirect(url_for('login'))
    return render_template('index.html')

@app.route('/add-book', methods=['GET', 'POST'])
def add_book():
    if request.method == 'POST':
        title = request.form['title']
        isbn = request.form['isbn']
        genre = request.form['genre']
        author = request.form['author']
        publisher = request.form['publisher']
        contact = request.form['contact']
        address = request.form['address']
        availability = request.form['availability']

        try:
            with get_db_connection() as conn:
                conn.execute(
                    text("CALL Add_Book(:title, :isbn, :genre, :author, :publisher, :contact, :address, :availability)"),
                    {
                        "title": title,
                        "isbn": isbn,
                        "genre": genre,
                        "author": author,
                        "publisher": publisher,
                        "contact": contact,
                        "address": address,
                        "availability": availability
                    }
                )
                flash("Book added successfully!", "success")
        except Exception as e:
            flash(f"Error adding book: {str(e)}", "danger")

        return redirect(url_for('add_book'))

    return render_template('add_book.html')

@app.route('/delete-book', methods=['GET', 'POST'])
def delete_book_page():
    with get_db_connection() as conn:
        books = conn.execute(text("SELECT BookID, Title FROM Book")).fetchall()

    if request.method == 'POST':
        book_id = request.form.get('book_id')
        try:
            with get_db_connection() as conn:
                conn.execute(text("CALL Delete_Book(:book_id)"), {"book_id": book_id})
            flash("Book deleted successfully!", "success")
        except Exception as e:
            flash(f"Delete failed: {str(e)}", "danger")
        return redirect(url_for('view_books'))

    return render_template('delete_book.html', books=books)

@app.route('/books')
def view_books():
    with get_db_connection() as conn:
        result = conn.execute(text('SELECT * FROM Book_Details')).fetchall()
    return render_template('view_books.html', books=result)


@app.route('/add-member', methods=['GET', 'POST'])
def add_member():
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        phone = request.form['phone']

        try:
            with get_db_connection() as conn:
                conn.execute(
                    text("CALL AddMember(:name, :email, :phone)"),
                    {
                        "name": name,
                        "email": email,
                        "phone": phone
                    }
                )
                flash("Member added successfully!", "success")
        except Exception as e:
            flash(f"Error adding member: {str(e)}", "danger")

        return redirect(url_for('add_member'))

    return render_template('add_member.html')

@app.route('/delete-member', methods=['GET', 'POST'])
def delete_member():
    with get_db_connection() as conn:
        members = conn.execute(text("SELECT MemberID, Name FROM Member")).fetchall()

    if request.method == 'POST':
        member_id = request.form['member_id']
        with get_db_connection() as conn:
            conn.execute(text("CALL DeleteMember(:member_id)"), {"member_id": member_id})
        flash("Member deleted successfully!")
        return redirect(url_for('view_members'))

    return render_template('delete_member.html', members=members)

@app.route('/update-member', methods=['GET', 'POST'])
def update_member():
    with get_db_connection() as conn:
        members = conn.execute(text("SELECT MemberID, Name FROM Member")).fetchall()

    if request.method == 'POST':
        member_id = request.form['member_id']
        name = request.form['name']
        email = request.form['email']
        phone = request.form['phone']

        try:
            with get_db_connection() as conn:
                conn.execute(text("CALL Update_Member_Details(:member_id, :name, :email, :phone)"), {
                    "member_id": member_id,
                    "name": name,
                    "email": email,
                    "phone": phone
                })
            flash("Member updated successfully!", "success")
        except Exception as e:
            flash(f"Failed to update member: {str(e)}", "error")
        
        return redirect(url_for('update_member'))

    return render_template('update_member.html', members=members)


@app.route('/members')
def view_members():
    with get_db_connection() as conn:
        result = conn.execute(text("SELECT * FROM View_Members"))
        members = result.fetchall()
    return render_template('view_member.html', members=members)


@app.route('/borrow-book', methods=['GET', 'POST'])
def borrow_book():
    if request.method == 'POST':
        book_id = request.form['book_id']
        member_id = request.form['member_id']
        borrow_date = request.form['borrow_date']
        due_date = request.form['due_date']

        try:
            with get_db_connection() as conn:
                conn.execute(
                    text("CALL Borrow_Book(:book_id, :member_id, :borrow_date, :due_date)"),
                    {
                        'book_id': book_id,
                        'member_id': member_id,
                        'borrow_date': borrow_date,
                        'due_date': due_date
                    }
                )
                flash("Book borrowed successfully!", "success")
        except Exception as e:
            flash(f"Failed to borrow book: {str(e)}", "danger")

        return redirect(url_for('borrow_book'))

    return render_template('borrow_book.html')

@app.route('/return-book', methods=['GET', 'POST'])
def return_book():
    if request.method == 'POST':
        transaction_id = request.form['transaction_id']
        return_date = request.form['return_date']

        try:
            with get_db_connection() as conn:
                conn.execute(text("CALL ReturnBook(:transaction_id, :return_date)"), {
                    "transaction_id": transaction_id,
                    "return_date": return_date
                })
            flash("Book returned successfully!", "success")
        except Exception as e:
            flash(f"Failed to return book: {str(e)}", "danger")

        return redirect(url_for('return_book'))

    return render_template('return_book.html')


@app.route('/borrowed')
def view_borrowed_books():
    with get_db_connection() as conn:
        result = conn.execute(text("SELECT * FROM View_BorrowedBooks"))
        borrowed_books = result.fetchall()
    return render_template('view_borrowedbook.html', borrowed_books=borrowed_books)

@app.route('/logout')
def logout():
    session.pop('librarian', None)
    return redirect(url_for('login'))

if __name__ == '__main__':
    app.run(debug=True)




