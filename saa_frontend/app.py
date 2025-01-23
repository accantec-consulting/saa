import streamlit as st
import json
import pandas as pd
import requests

def send_to_api(input_data):
    api_url = "https://zu6hdf0rye.execute-api.us-east-1.amazonaws.com/dev/"

    data = {
        "input": input_data.get("question", ""),
        "sessionId": input_data.get("sessionId", "DEFAULT_SESSION_ID")
    }

    if not data["input"]:
        print("Error: Input text is required but missing!")
        return {"statusCode": 400, "body": '"Input text is required"'}

    try:
        response = requests.post(api_url, json=data)
        response.raise_for_status() 
        return response.json() 
    except requests.exceptions.RequestException as e:
        print(f"API-Call failed: {e}")
        return {"statusCode": 500, "body": f"Error: {str(e)}"}


# Streamlit page configuration
st.set_page_config(page_title="accantec chatbot", page_icon=":speech_balloon:", layout="wide")

# Title
st.title("Dein Chatbot") 

# Display a text box for input
prompt = st.text_input("Frage",max_chars=2000, placeholder="Stellen Sie hier eine Frage.", label_visibility="collapsed")
prompt = prompt.strip()

# Display a primary button for submission
submit_button = st.button("Fragen", type="primary")

# Display a button to end the session
end_session_button = st.button("Beenden")

# Session State Management
if 'history' not in st.session_state:
    st.session_state['history'] = []

# Function to parse and format response
def format_response(response_body):
    try:
        # Try to load the response as JSON
        data = json.loads(response_body)
        # If it's a list, convert it to a DataFrame for better visualization
        if isinstance(data, list):
            return pd.DataFrame(data)
        else:
            return response_body
    except json.JSONDecodeError:
        # If response is not JSON, return as is
        return response_body

# User input and responses
if submit_button and prompt:

    event = {
        "sessionId": "MYSESSION",
        "question": prompt
    }

    # Validierung der Eingabe
    if not prompt:
        st.error("Bitte geben Sie eine Frage ein!")
    else:
         # API-Call
        try:
            with st.spinner('Bitte warten, Anfrage wird verarbeitet...'):
                response_data = send_to_api({
                    "sessionId": "MYSESSION",
                    "question": prompt
                })
            
            if response_data and response_data.get('statusCode') != 200:
                st.error(f"API-Fehler: {response_data.get('body', 'Keine Details verfügbar')}")
        except Exception as e:
            st.error(f"Ein unerwarteter Fehler ist aufgetreten: {e}")
            response_data = None
        
        # Verarbeitung der API-Antwort
        try:
            if response_data and 'body' in response_data and response_data['body']:
                # Wenn 'body' JSON enthält, verarbeite es
                try:
                    response_body = json.loads(response_data['body'])
                except json.JSONDecodeError:
                    # Wenn 'body' kein JSON ist, behandle es als Text
                    response_body = response_data['body']

                print("TRACE & RESPONSE DATA -> ", response_body)
            else:
                response_body = "Invalid or empty response received."
        except Exception as e:
            st.error(f"Fehler beim Verarbeiten der API-Antwort: {e}")
            response_body = None 
        
        # Extrahiere Antwortdaten
        try:
            if isinstance(response_body, dict):
                all_data = format_response(response_body.get('response', {}).strip("\n"))
                the_response = response_body.get('response', "No trace data available.").strip("\n")
            else:
                all_data = response_body.strip("\n")
                the_response = response_body.strip("\n")
        except Exception as e:
            print(f"Fehler beim Extrahieren der Antwortdaten: {e}")
            all_data = "..."
            the_response = "Entschuldigung, es ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut."
        
        # Verwendung der Antwort
        st.session_state['history'].append({"question": prompt, "answer": the_response})
        st.session_state['trace_data'] = the_response
  

if end_session_button:
    st.session_state['history'].append({"question": "Session Ended", "answer": "Thank you for using AnyCompany Support Agent!"})
    event = {
        "sessionId": "MYSESSION",
        "question": "placeholder to end session",
        "endSession": True
    }
    #agenthelper.lambda_handler(event, None)
    st.session_state['history'].clear()

# Display conversation history
st.write("## Antworten")

for index, chat in enumerate(reversed(st.session_state['history'])):
    # Display the Question
    st.text_area(
        "Frage", 
        value=chat["question"], 
        height=68, 
        key=f"question_{index}", 
        disabled=True
    )

    # Display the Answer
    if isinstance(chat["answer"], pd.DataFrame):
        st.dataframe(chat["answer"], key=f"answer_df_{index}")
    else:
        st.text_area(
            "Antwort", 
            value=chat["answer"], 
            height=150, 
            key=f"answer_{index}",
            disabled=True
        )