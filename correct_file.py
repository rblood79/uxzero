import os
import requests

API_KEY = os.getenv('OPENAI_API_KEY')
FILE_PATH = 'test.txt'

def correct_file(file_content):
    response = requests.post(
        'https://api.openai.com/v1/chat/completions',
        headers={
            'Authorization': f'Bearer {API_KEY}',
            'Content-Type': 'application/json',
        },
        json={
            'model': 'gpt-4',
            'messages': [
                {'role': 'system', 'content': 'You are a code fixer bot.'},
                {'role': 'user', 'content': f'Correct the following code:\n\n{file_content}'}
            ],
            'temperature': 0.7,
        },
    )
    return response.json()['choices'][0]['message']['content']

with open(FILE_PATH, 'r') as file:
    content = file.read()

corrected_content = correct_file(content)

with open(FILE_PATH, 'w') as file:
    file.write(corrected_content)
