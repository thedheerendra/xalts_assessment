from flask import Flask, jsonify
#import requests

app = Flask(__name__)

@app.route('/health', methods=['GET'])
def health():
    response = {
        "result": "Healthy",
        "error": False
    }
    return jsonify(response), 200
    
if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=3000)
