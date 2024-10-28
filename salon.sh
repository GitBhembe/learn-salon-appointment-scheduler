#! /bin/bash

# Function to display available services
display_services() {
    echo "Here are the services we offer:"
    psql --username=freecodecamp --dbname=salon -t -c "SELECT service_id, name FROM services;" | nl -w2 -s') '
}

# Display the services initially
display_services

# Prompt user for input
while true; do
    read -p "Enter service ID: " SERVICE_ID_SELECTED

    # Check if the service_id exists
    SERVICE_EXISTS=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
    
    if [[ -z $SERVICE_EXISTS ]]; then
        echo "That service does not exist. Please try again."
        display_services
    else
        break
    fi
done

# Read phone number, customer name (if needed), and appointment time
read -p "Enter your phone number: " CUSTOMER_PHONE

# Check if the customer already exists
CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

if [[ -z $CUSTOMER_ID ]]; then
    # If the customer doesn't exist, ask for their name
    read -p "Enter your name: " CUSTOMER_NAME
    # Add the new customer to the database
    psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
    # Get the new customer_id
    CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
else
    # If the customer exists, retrieve their name
    CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;")
fi

# Prompt for appointment time
read -p "Enter the appointment time: " SERVICE_TIME

# Insert the appointment into the appointments table
psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

# Output confirmation message
SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
