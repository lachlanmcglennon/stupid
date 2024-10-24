def handle_login(sock, message):
    try:
        # Split the message into components and strip any extra spaces
        parts = message.split(":")
        if len(parts) != 3:
            # Invalid format, should be exactly 3 parts: "LOGIN:<username>:<password>"
            return "LOGIN:ACKSTATUS:3"  # Invalid format message
        
        _, username, password = parts
        username = username.strip()
        password = password.strip()

        # Check if the username exists in the users database
        if username not in users:
            return f"LOGIN:ACKSTATUS:1"  # User not found message

        # Check if the password matches the stored bcrypt hash
        if bcrypt.checkpw(password.encode('utf-8'), users[username]):
            authenticated_clients[sock] = username  # Mark the user as authenticated
            return f"LOGIN:ACKSTATUS:0"  # Success, authenticated
        else:
            return f"LOGIN:ACKSTATUS:2"  # Password mismatch message

    except Exception as e:
        print(f"Error handling login: {e}")  # Log the error on the server side
        return "LOGIN:ACKSTATUS:3"  # Invalid format or unexpected error


USER_DATA_FILE = "users.json"

# Function to load user data from JSON
def load_users():
    if os.path.exists(USER_DATA_FILE):
        with open(USER_DATA_FILE, 'r') as file:
            return json.load(file)
    else:
        return []  # Return an empty list if the file doesn't exist
def save_users(users):
    with open(USER_DATA_FILE, 'w') as file:
        json.dump(users, file, indent=4)
def user_exists(username, users):
    for user in users:
        if user['username'] == username:
            return True
    return False
def handle_register(sock, message):
    try:
        parts = message.split(":")
        if len(parts) != 3:
            return "REGISTER:ACKSTATUS:3"  # Invalid format

        _, username, password = parts
        username = username.strip()
        password = password.strip()

        # Load the current user data from JSON
        users = load_users()

        # Check if the username already exists
        if user_exists(username, users):
            return f"REGISTER:ACKSTATUS:1"  # Username already exists

        # Hash the password
        hashed_pw = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

        # Add the new user to the list
        new_user = {
            "username": username,
            "password": hashed_pw.decode('utf-8')  # Store as string
        }
        users.append(new_user)

        # Save the updated users list back to the JSON file
        save_users(users)

        return f"REGISTER:ACKSTATUS:0"  # Registration successful

    except Exception as e:
        print(f"Error during registration: {e}")
        return "REGISTER:ACKSTATUS:3"  # Invalid format or other error
