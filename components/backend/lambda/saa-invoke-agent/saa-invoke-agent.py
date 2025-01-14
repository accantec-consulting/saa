import boto3
import json
import os

def lambda_handler(event, context):
    # Initialize the Bedrock Agent Runtime client
    bedrock_agent_runtime = boto3.client('bedrock-agent-runtime')
    
    # Get agent and alias IDs from environment variables
    agent_id = os.environ['AGENT_ID']
    agent_alias_id = os.environ['AGENT_ALIAS_ID']
    
    try:
        # Generate a unique session ID
        session_id = context.aws_request_id
        
        # Parse the input text from the event directly
        input_text = event.get('input', '')  # Directly access 'input' in event, not inside 'body'
        
        # Check if the input_text is empty
        if not input_text:
            # Include the full event in the error message
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'error': 'Input text is required'
                }, ensure_ascii=False)
            }
        
        # Invoke the agent
        response = bedrock_agent_runtime.invoke_agent(
            agentId=agent_id,
            agentAliasId=agent_alias_id,
            sessionId=session_id,
            inputText=input_text
        )
        
        # Process the completion stream
        completion = ''
        for chunk_event in response.get('completion', []):
            chunk = chunk_event.get('chunk', {})
            if 'bytes' in chunk:
                completion += chunk.get('bytes', b'').decode('utf-8')
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'response': completion,
                'sessionId': session_id
            }, ensure_ascii=False)
        }
        
    except bedrock_agent_runtime.exceptions.ValidationException as e:
        return {
            'statusCode': 400,
            'body': json.dumps(f'Validation error: {str(e)}')
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error invoking agent: {str(e)}')
        }