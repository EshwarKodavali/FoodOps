from flask import Flask, render_template, request, redirect, url_for, session

app = Flask(__name__)

app.secret_key = "devops-login-secret-key"


@app.route("/", methods=["GET", "POST"])
def home():

    if request.method == "POST":

        email = request.form["email"]

        session["email"] = email
        session["cart"] = []

        return redirect(url_for("menu"))

    return render_template("login.html")


@app.route("/menu")
def menu():

    email = session.get("email")
    cart = session.get("cart", [])

    return render_template(
        "menu.html",
        email=email,
        cart_count=len(cart)
    )


@app.route("/add/<item>")
def add_to_cart(item):

    cart = session.get("cart", [])

    cart.append(item)

    session["cart"] = cart

    return redirect(url_for("menu"))


@app.route("/cart")
def cart():

    cart = session.get("cart", [])

    return render_template(
        "cart.html",
        cart=cart
    )

@app.route("/place-order", methods=["POST"])
def place_order():

    cart = session.get("cart", [])

    if not cart:
        return redirect(url_for("menu"))

    session["cart"] = []

    return render_template("order_success.html")
    
if __name__ == "__main__":
    app.run(debug=True)