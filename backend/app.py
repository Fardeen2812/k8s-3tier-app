import os
import redis
from flask import Flask, render_template, request, jsonify

# Initialize Flask app
app = Flask(__name__)

# Initialize Redis connection
# We use os.environ.get() to read the 'REDIS_HOST' environment variable.
# For local testing (Week 1), it defaults to 'localhost'.
# For Docker/Kubernetes (Week 2+), we will set REDIS_HOST='redis'.
redis_host = os.environ.get('REDIS_HOST', 'localhost')
try:
    # Set decode_responses=True to get strings back from Redis instead of bytes
    db = redis.StrictRedis(host=redis_host, port=6379, db=0, decode_responses=True)
    db.ping()
    print(f"Successfully connected to Redis at {redis_host}")
except Exception as e:
    print(f"Error connecting to Redis at {redis_host}: {e}")
    raise  # crash so you notice immediately
    db = None

@app.route('/')
def index():
    """Serves the main HTML page (our frontend)."""
    return render_template('index.html')

@app.route('/favicon.ico')
def favicon():
    """Serves the favicon.ico file."""
    return app.send_static_file('favicon.ico')

@app.route('/api/notes', methods=['GET'])
def get_notes():
    """API endpoint to get all notes."""
    if not db:
        return jsonify({"error": "Database connection failed"}), 500
        
    try:
        # Get all items from the 'notes' list in Redis
        notes = db.lrange('notes', 0, -1)
        # lrange returns items in insertion order (oldest to newest)
        # We reverse it to show newest notes first
        notes.reverse()
        return jsonify(notes)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/notes', methods=['POST'])
def add_note():
    """API endpoint to add a new note."""
    if not db:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        # Get the note from the posted JSON data
        data = request.get_json()
        note = data.get('note')

        if not note:
            return jsonify({"error": "Note content is missing"}), 400

        # Add the new note to the 'notes' list in Redis
        # rpush adds the new item to the end of the list
        db.rpush('notes', note)
        
        return jsonify({"success": True, "note": note}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # Run the Flask app
    # host='0.0.0.0' makes it accessible from outside the container
    app.run(host='0.0.0.0', port=5001, debug=True)