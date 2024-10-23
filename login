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
