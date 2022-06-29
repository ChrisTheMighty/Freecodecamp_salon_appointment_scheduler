#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~~~~~~Hairdresser's~~~~~~~~~~\n"

MENU()
{
  echo -e "\nWelcome to the hairdresser's. Take a look at our services:\n"
  # get services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  # display services
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo -e "$SERVICE_ID) "$SERVICE""
  done
  echo -e "\nWhich service would you like today?"
  read SERVICE_ID_SELECTED
# get service
SELECTED_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
# if service doesn't exist
if [[ -z $SELECTED_SERVICE ]]
then
  # send to main menu
  echo -e "\nThat is not a valid service."
  MENU
else
  GET_DETAILS
fi
}

GET_DETAILS()
{
# get phone number
echo -e "\nWhat is your phone number?"
read CUSTOMER_PHONE
# if customer doesn't exist
EXISTING_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [[ -z $EXISTING_CUSTOMER_NAME ]]
then
  # get customer name
  echo -e "\nIt seems you have not visited us before. Welcome! What is your name?"
  read CUSTOMER_NAME
  # insert customer
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
else
EXISTING_CUSTOMER_NAME_FORMATTED=$(echo $EXISTING_CUSTOMER_NAME | sed -r 's/^ *| *$//g')
  echo -e "\nWelcome back, $EXISTING_CUSTOMER_NAME_FORMATTED." 
fi

MAKE_APPO
}

MAKE_APPO()
{
echo -e "\nWhat time would you like to come in?"
read SERVICE_TIME
# get customer_id
CUST_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
# add appointment
ADD_APPO_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUST_ID, $SELECTED_SERVICE, '$SERVICE_TIME')")
# get service name
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SELECTED_SERVICE")
SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')
# get customer name
CUST_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUST_ID")
CUST_NAME_FORMATTED=$(echo $CUST_NAME | sed -r 's/^ *| *$//g')
echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUST_NAME_FORMATTED."
}

MENU