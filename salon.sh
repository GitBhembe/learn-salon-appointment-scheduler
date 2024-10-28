#! /bin/bash

# Connect to the salon database with the freecodecamp user
PSQL="psql --username=freecodecamp --dbname=salon -t -c"

# Function to display available services with correct formatting
display_services() {
    echo -e "\nHere are the services we offer:"
    $PSQL "SELECT service_id, name FROM services ORDER BY service_id" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done
}

# Display services before any input
display_services

# Prompt for service selection and validate input
while true; do
    echo -e "\nEnter the service ID of your choice:"
    read SERVICE_ID_SELECTED

    # Check if entered service ID is valid
    SERVICE_EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_EXISTS ]]; then
        echo -e "\nInvalid selection. Please choose a valid service from the list."
        display_services
    else
        break
    fi
done

# Prompt for phone number
echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

# Check if customer exists by phone number
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_ID ]]; then
    # If the customer does not exist, prompt for name and insert customer
    echo -e "\nNew customer! Please enter your name:"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
else
    # If the customer exists, get their name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
fi

# Prompt for appointment time
echo -e "\nEnter your preferred appointment time:"
read SERVICE_TIME

# Insert the appointment into the appointments table
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Fetch the service name for confirmation message
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

# Display confirmation message
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
